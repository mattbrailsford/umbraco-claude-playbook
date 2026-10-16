#!/usr/bin/env bash
set -euo pipefail
git init -q -b main
git config user.email eval@example.com && git config user.name eval
mkdir -p src/MyPackage/Branding src/MyPackage/Reports
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
    }
}
EOF
git add -A && git commit -q -m "chore: package skeleton"

cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<IBrandingSettingsService, BrandingSettingsService>();
        builder.Services.AddRecurringBackgroundJob<WeeklyReportJob>();
        builder.Services.Configure<WeeklyReportOptions>(builder.Config.GetSection("MyPackage:WeeklyReport"));
    }
}
EOF
cat > src/MyPackage/Branding/BrandingSettings.cs <<'EOF'
namespace MyPackage.Branding;

public sealed class BrandingSettings
{
    public string PrimaryColor { get; set; } = "#3544b1";
    public string? LogoPath { get; set; }
    public string FooterText { get; set; } = string.Empty;
}
EOF
cat > src/MyPackage/Branding/BrandingSettingsService.cs <<'EOF'
namespace MyPackage.Branding;

internal sealed class BrandingSettingsService : IBrandingSettingsService
{
    private const string CacheKey = "MyPackage_BrandingSettings";
    private readonly IDbContextFactory<MyPackageDbContext> _dbFactory;
    private readonly IAppPolicyCache _runtimeCache;

    public BrandingSettingsService(IDbContextFactory<MyPackageDbContext> dbFactory, AppCaches appCaches)
    {
        _dbFactory = dbFactory;
        _runtimeCache = appCaches.RuntimeCache;
    }

    public BrandingSettings Get()
        => _runtimeCache.GetCacheItem(CacheKey, Load, TimeSpan.FromHours(12))!;

    public async Task SaveAsync(BrandingSettings settings, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var row = await db.Branding.SingleOrDefaultAsync(ct) ?? db.Branding.Add(new BrandingRow()).Entity;
        row.PrimaryColor = settings.PrimaryColor;
        row.LogoPath = settings.LogoPath;
        row.FooterText = settings.FooterText;
        await db.SaveChangesAsync(ct);

        _runtimeCache.ClearByKey(CacheKey);
    }

    private BrandingSettings Load()
    {
        using var db = _dbFactory.CreateDbContext();
        var row = db.Branding.AsNoTracking().SingleOrDefault();
        return row is null
            ? new BrandingSettings()
            : new BrandingSettings { PrimaryColor = row.PrimaryColor, LogoPath = row.LogoPath, FooterText = row.FooterText };
    }
}
EOF
cat > src/MyPackage/Branding/BrandingController.cs <<'EOF'
namespace MyPackage.Branding;

[VersionedApiBackOfficeRoute("my-package/branding")]
[ApiExplorerSettings(GroupName = "My Package")]
public sealed class BrandingController : ManagementApiControllerBase
{
    private readonly IBrandingSettingsService _settings;
    private readonly IWebHostEnvironment _env;

    public BrandingController(IBrandingSettingsService settings, IWebHostEnvironment env)
    {
        _settings = settings;
        _env = env;
    }

    [HttpGet]
    public IActionResult Get() => Ok(_settings.Get());

    [HttpPut]
    public async Task<IActionResult> Save(BrandingSettings model, CancellationToken ct)
    {
        await _settings.SaveAsync(model, ct);
        return Ok();
    }

    [HttpPost("logo")]
    [RequestSizeLimit(2_000_000)]
    public async Task<IActionResult> UploadLogo(IFormFile file, CancellationToken ct)
    {
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (ext is not (".png" or ".svg" or ".jpg")) return BadRequest("Unsupported file type");

        var folder = Path.Combine(_env.WebRootPath, "my-package", "branding");
        Directory.CreateDirectory(folder);
        var fileName = $"logo-{Guid.NewGuid():N}{ext}";
        await using (var stream = System.IO.File.Create(Path.Combine(folder, fileName)))
        {
            await file.CopyToAsync(stream, ct);
        }

        var settings = _settings.Get();
        settings.LogoPath = $"/my-package/branding/{fileName}";
        await _settings.SaveAsync(settings, ct);
        return Ok(new { settings.LogoPath });
    }
}
EOF
cat > src/MyPackage/Reports/WeeklyReportOptions.cs <<'EOF'
namespace MyPackage.Reports;

public sealed class WeeklyReportOptions
{
    public bool Enabled { get; set; } = true;
    public string[] Recipients { get; set; } = [];
}
EOF
cat > src/MyPackage/Reports/WeeklyReportJob.cs <<'EOF'
namespace MyPackage.Reports;

// Emails a summary of last week's activity to the configured recipients.
public sealed class WeeklyReportJob : RecurringBackgroundJobBase
{
    private readonly IEmailSender _emailSender;
    private readonly ReportBuilder _reportBuilder;
    private readonly IOptionsMonitor<WeeklyReportOptions> _options;
    private readonly ILogger<WeeklyReportJob> _logger;

    public WeeklyReportJob(
        IEmailSender emailSender,
        ReportBuilder reportBuilder,
        IOptionsMonitor<WeeklyReportOptions> options,
        ILogger<WeeklyReportJob> logger)
        : base(TimeSpan.FromDays(7))
    {
        _emailSender = emailSender;
        _reportBuilder = reportBuilder;
        _options = options;
        _logger = logger;
    }

    public override async Task RunJobAsync(CancellationToken cancellationToken)
    {
        var options = _options.CurrentValue;
        if (!options.Enabled || options.Recipients.Length == 0) return;

        var body = await _reportBuilder.BuildLastWeekAsync(cancellationToken);
        foreach (var recipient in options.Recipients)
        {
            var message = new EmailMessage(null, recipient, "Weekly site report", body, true);
            await _emailSender.SendAsync(message, emailType: "MyPackageWeeklyReport");
        }
        _logger.LogInformation("Sent weekly report to {Count} recipients", options.Recipients.Length);
    }
}
EOF

# git can't run inside the eval sandbox, so hand the reviewer the diff as a file.
git add -A && git diff --cached > CHANGE.diff && git reset -q
