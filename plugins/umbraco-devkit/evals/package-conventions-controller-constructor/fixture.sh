#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Items
mkdir -p $d/Controllers $d/Services $d/Composers
cat > $d/Umbraco.Community.Items.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Umbraco.Community.Items</PackageId>
    <Version>3.1.0</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Services/IItemService.cs <<'EOF'
namespace Umbraco.Community.Items.Services;

public sealed record Item(Guid Key, string Name, Guid OwnerKey);

public interface IItemService
{
    Task<Item?> GetAsync(Guid key);
    Task DeleteAsync(Guid key);
}
EOF
cat > $d/Services/IItemPermissionChecker.cs <<'EOF'
namespace Umbraco.Community.Items.Services;

/// <summary>New in 3.2.0. Decides whether a backoffice user may change an item.</summary>
public interface IItemPermissionChecker
{
    Task<bool> CanDeleteAsync(Item item, Guid userKey);
}
EOF
cat > $d/Services/ItemService.cs <<'EOF'
namespace Umbraco.Community.Items.Services;

internal sealed class ItemService : IItemService
{
    public Task<Item?> GetAsync(Guid key) => Task.FromResult<Item?>(null); // storage omitted
    public Task DeleteAsync(Guid key) => Task.CompletedTask;
}
EOF
cat > $d/Services/OwnerItemPermissionChecker.cs <<'EOF'
namespace Umbraco.Community.Items.Services;

/// <summary>Only the item's owner may delete it.</summary>
internal sealed class OwnerItemPermissionChecker : IItemPermissionChecker
{
    public Task<bool> CanDeleteAsync(Item item, Guid userKey) => Task.FromResult(item.OwnerKey == userKey);
}
EOF
cat > $d/Composers/ItemsComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Items.Services;

namespace Umbraco.Community.Items.Composers;

public sealed class ItemsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<IItemService, ItemService>();
        builder.Services.AddScoped<IItemPermissionChecker, OwnerItemPermissionChecker>();
    }
}
EOF
cat > $d/Controllers/ItemController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.Items.Services;

namespace Umbraco.Community.Items.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("items")]
[ApiExplorerSettings(GroupName = "Items")]
public class ItemController : ManagementApiControllerBase
{
    private readonly IItemService _itemService;

    public ItemController(IItemService itemService)
        => _itemService = itemService;

    [HttpGet("{key:guid}")]
    public virtual async Task<IActionResult> Get(Guid key)
    {
        Item? item = await _itemService.GetAsync(key);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpDelete("{key:guid}")]
    public virtual async Task<IActionResult> Delete(Guid key)
    {
        Item? item = await _itemService.GetAsync(key);
        if (item is null)
        {
            return NotFound();
        }

        await _itemService.DeleteAsync(key);
        return Ok();
    }
}
EOF
