#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Coupons
mkdir -p $d/Controllers $d/Services $d/Composers
cat > $d/Umbraco.Community.Coupons.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Umbraco.Community.Coupons</PackageId>
    <Version>4.0.2</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > CHANGELOG.md <<'EOF'
# Changelog

## 4.0.0
- Management API controllers are now public and their actions virtual, so sites can
  inherit from them to add their own checks.
EOF
cat > $d/Services/Coupons.cs <<'EOF'
namespace Umbraco.Community.Coupons.Services;

public sealed record Coupon(Guid Key, string Code, decimal Discount, bool Active);

public sealed record CouponUpdateModel(string Code, decimal Discount, bool Active);

public interface ICouponService
{
    Task<Coupon?> GetAsync(Guid key);
    Task<Coupon> UpdateAsync(Guid key, CouponUpdateModel model);
    Task DeleteAsync(Guid key);
}

internal sealed class CouponService : ICouponService
{
    public Task<Coupon?> GetAsync(Guid key) => Task.FromResult<Coupon?>(null); // storage omitted
    public Task<Coupon> UpdateAsync(Guid key, CouponUpdateModel model) => Task.FromResult(new Coupon(key, model.Code, model.Discount, model.Active));
    public Task DeleteAsync(Guid key) => Task.CompletedTask;
}
EOF
cat > $d/Composers/CouponsComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Coupons.Services;

namespace Umbraco.Community.Coupons.Composers;

public sealed class CouponsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.Services.AddScoped<ICouponService, CouponService>();
}
EOF
cat > $d/Controllers/CouponController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.Coupons.Services;

namespace Umbraco.Community.Coupons.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("coupons")]
[ApiExplorerSettings(GroupName = "Coupons")]
public class CouponController : ManagementApiControllerBase
{
    private readonly ICouponService _couponService;

    public CouponController(ICouponService couponService)
        => _couponService = couponService;

    [HttpGet("{key:guid}")]
    public virtual async Task<IActionResult> Get(Guid key)
    {
        Coupon? coupon = await _couponService.GetAsync(key);
        return coupon is null ? NotFound() : Ok(coupon);
    }

    [HttpPut("{key:guid}")]
    public virtual async Task<IActionResult> Update(Guid key, CouponUpdateModel model)
    {
        if (await _couponService.GetAsync(key) is null)
        {
            return NotFound();
        }

        return Ok(await _couponService.UpdateAsync(key, model));
    }

    [HttpDelete("{key:guid}")]
    public virtual async Task<IActionResult> Delete(Guid key)
    {
        if (await _couponService.GetAsync(key) is null)
        {
            return NotFound();
        }

        await _couponService.DeleteAsync(key);
        return Ok();
    }
}
EOF
