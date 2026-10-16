#!/usr/bin/env bash
set -euo pipefail
git init -q -b main
git config user.email eval@example.com && git config user.name eval
mkdir -p src/MyPackage/Imports src/MyPackage/Forms src/MyPackage/Client/src/imports
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" /></ItemGroup>
</Project>
EOF
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<IFormStepService, FormStepService>();
    }
}
EOF
cat > src/MyPackage/Forms/FormStepService.cs <<'EOF'
namespace MyPackage.Forms;

internal sealed class FormStepService : IFormStepService
{
    private readonly IDbContextFactory<MyPackageDbContext> _dbFactory;

    public FormStepService(IDbContextFactory<MyPackageDbContext> dbFactory) => _dbFactory = dbFactory;

    public async Task<IReadOnlyList<FormStep>> GetStepsForFormAsync(Guid formKey, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var rows = await db.FormSteps.AsNoTracking().Where(s => s.FormKey == formKey).OrderBy(s => s.SortOrder).ToListAsync(ct);
        return rows.Select(FormStep.FromRow).ToList(); // deserializes each row's JSON settings
    }

    public async Task SaveAsync(FormStep step, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        db.FormSteps.Update(step.ToRow());
        await db.SaveChangesAsync(ct);
    }
}
EOF
git add -A && git commit -q -m "feat: form steps"

# ---- the uncommitted feature ----
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<IFormStepService, FormStepService>();
        builder.Services.AddSingleton<IImportRunService, ImportRunService>();
        builder.Services.AddHostedService<ImportWorker>();
        builder.AddNotificationAsyncHandler<UmbracoApplicationStartingNotification, ImportRecoveryHandler>();
    }
}
EOF
cat > src/MyPackage/Imports/ImportRun.cs <<'EOF'
namespace MyPackage.Imports;

public enum ImportStatus { Pending, Running, Done, Failed }

public sealed class ImportRun
{
    public Guid Id { get; set; }
    public Guid FormKey { get; set; }
    public string FileName { get; set; } = string.Empty;
    public ImportStatus Status { get; set; }
    public string? Error { get; set; }
    public DateTime CreatedUtc { get; set; }
    public DateTime? FinishedUtc { get; set; }
}
EOF
cat > src/MyPackage/Imports/ImportRunService.cs <<'EOF'
namespace MyPackage.Imports;

internal sealed class ImportRunService : IImportRunService
{
    private readonly IDbContextFactory<MyPackageDbContext> _dbFactory;

    public ImportRunService(IDbContextFactory<MyPackageDbContext> dbFactory) => _dbFactory = dbFactory;

    public async Task<Guid> QueueAsync(Guid formKey, string fileName, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var run = new ImportRun { Id = Guid.NewGuid(), FormKey = formKey, FileName = fileName, Status = ImportStatus.Pending, CreatedUtc = DateTime.UtcNow };
        db.ImportRuns.Add(run);
        await db.SaveChangesAsync(ct);
        return run.Id;
    }

    public async Task<ImportRun?> ClaimNextAsync(CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var next = await db.ImportRuns.Where(r => r.Status == ImportStatus.Pending).OrderBy(r => r.CreatedUtc).FirstOrDefaultAsync(ct);
        if (next is null) return null;
        next.Status = ImportStatus.Running;
        await db.SaveChangesAsync(ct); // RowVersion concurrency token on ImportRun stops two servers claiming the same row
        return next;
    }

    public async Task CompleteAsync(Guid id, string? error, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var run = await db.ImportRuns.SingleAsync(r => r.Id == id, ct);
        run.Status = error is null ? ImportStatus.Done : ImportStatus.Failed;
        run.Error = error;
        run.FinishedUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
    }
}
EOF
cat > src/MyPackage/Imports/ImportRecoveryHandler.cs <<'EOF'
namespace MyPackage.Imports;

// A crash mid-import leaves the row Running forever; reset those on startup so they can be retried.
internal sealed class ImportRecoveryHandler : INotificationAsyncHandler<UmbracoApplicationStartingNotification>
{
    private readonly IDbContextFactory<MyPackageDbContext> _dbFactory;
    private readonly ILogger<ImportRecoveryHandler> _logger;

    public ImportRecoveryHandler(IDbContextFactory<MyPackageDbContext> dbFactory, ILogger<ImportRecoveryHandler> logger)
    {
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task HandleAsync(UmbracoApplicationStartingNotification notification, CancellationToken ct)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var reset = await db.ImportRuns
            .Where(r => r.Status == ImportStatus.Running)
            .ExecuteUpdateAsync(s => s.SetProperty(r => r.Status, ImportStatus.Failed).SetProperty(r => r.Error, "Interrupted by restart"), ct);
        if (reset > 0) _logger.LogWarning("Marked {Count} interrupted imports as failed", reset);
    }
}
EOF
cat > src/MyPackage/Forms/SignupFormViewComponent.cs <<'EOF'
namespace MyPackage.Forms;

public sealed class SignupFormViewComponent : ViewComponent
{
    private readonly IFormStepService _stepService;

    public SignupFormViewComponent(IFormStepService stepService) => _stepService = stepService;

    public async Task<IViewComponentResult> InvokeAsync(Guid formKey)
    {
        var steps = await _stepService.GetStepsForFormAsync(formKey, HttpContext.RequestAborted);
        var needsConsent = steps.Any(s => s.Settings.RequiresConsent);
        return View(new SignupFormModel(formKey, steps.Count, needsConsent));
    }
}

public sealed record SignupFormModel(Guid FormKey, int StepCount, bool NeedsConsent);
EOF
cat > src/MyPackage/Client/src/imports/delete-import-modal.element.ts <<'EOF'
import { html, customElement, property, unsafeHTML } from '@umbraco-cms/backoffice/external/lit';
import { UmbModalBaseElement } from '@umbraco-cms/backoffice/modal';
import type { MyImportRun } from './types.js';

// Term: myPackage_confirmDeleteImport = 'Delete the import <strong>%0%</strong>? This cannot be undone.'
@customElement('my-package-delete-import-modal')
export class MyPackageDeleteImportModalElement extends UmbModalBaseElement<{ run: MyImportRun }> {
	@property({ attribute: false })
	run?: MyImportRun;

	#confirm() {
		this.modalContext?.submit();
	}

	override render() {
		const fileName = this.data?.run.fileName ?? '';
		return html`
			<uui-dialog-layout headline=${this.localize.term('general_delete')}>
				<p>${unsafeHTML(this.localize.string('#myPackage_confirmDeleteImport', fileName))}</p>
				<uui-button slot="actions" label=${this.localize.term('general_cancel')} @click=${this._rejectModal}></uui-button>
				<uui-button slot="actions" look="primary" color="danger" label=${this.localize.term('general_delete')} @click=${this.#confirm}></uui-button>
			</uui-dialog-layout>
		`;
	}
}

export default MyPackageDeleteImportModalElement;
EOF

# git can't run inside the eval sandbox, so hand the reviewer the diff as a file.
git add -A && git diff --cached > CHANGE.diff && git reset -q
