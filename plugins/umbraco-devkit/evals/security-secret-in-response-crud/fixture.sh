#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Shipping
mkdir -p $d/Carriers $d/Composers
cat > $d/Umbraco.Community.Shipping.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Carriers/CarrierAccount.cs <<'EOF'
namespace Umbraco.Community.Shipping.Carriers;

/// <summary>A shipping carrier account a site has connected (DHL, UPS, ...).</summary>
public class CarrierAccount
{
    public Guid Key { get; set; }
    public string Name { get; set; } = "";
    public string CarrierAlias { get; set; } = "";
    public string AccountNumber { get; set; } = "";
    public string ClientId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    /// <summary>Used to verify tracking webhooks the carrier sends us.</summary>
    public string WebhookSigningSecret { get; set; } = "";
    public bool IsSandbox { get; set; }
    public DateTime UpdatedUtc { get; set; }
}
EOF
cat > $d/Carriers/ICarrierAccountService.cs <<'EOF'
namespace Umbraco.Community.Shipping.Carriers;

public interface ICarrierAccountService
{
    Task<IReadOnlyList<CarrierAccount>> GetAllAsync();
    Task<CarrierAccount?> GetAsync(Guid key);
    Task<CarrierAccount> CreateAsync(CarrierAccount account);
    Task UpdateAsync(CarrierAccount account);
    Task<bool> DeleteAsync(Guid key);
}
EOF
cat > $d/Carriers/CarrierAccountService.cs <<'EOF'
namespace Umbraco.Community.Shipping.Carriers;

// Persistence is in CarrierAccountRepository (not shown); the service adds timestamps.
internal sealed class CarrierAccountService(CarrierAccountRepository repository) : ICarrierAccountService
{
    public Task<IReadOnlyList<CarrierAccount>> GetAllAsync() => repository.GetAllAsync();
    public Task<CarrierAccount?> GetAsync(Guid key) => repository.GetAsync(key);

    public async Task<CarrierAccount> CreateAsync(CarrierAccount account)
    {
        account.Key = Guid.NewGuid();
        account.UpdatedUtc = DateTime.UtcNow;
        await repository.InsertAsync(account);
        return account;
    }

    public Task UpdateAsync(CarrierAccount account)
    {
        account.UpdatedUtc = DateTime.UtcNow;
        return repository.UpdateAsync(account);
    }

    public Task<bool> DeleteAsync(Guid key) => repository.DeleteAsync(key);
}
EOF
cat > $d/Composers/ShippingComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Shipping.Carriers;

namespace Umbraco.Community.Shipping.Composers;

public class ShippingComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<CarrierAccountRepository>();
        builder.Services.AddScoped<ICarrierAccountService, CarrierAccountService>();
    }
}
EOF
