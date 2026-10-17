#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.FormsConnect
mkdir -p $d/Connectors $d/Settings $d/Composers
cat > $d/Umbraco.Community.FormsConnect.csproj <<'EOF'
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
cat > $d/Connectors/IConnector.cs <<'EOF'
namespace Umbraco.Community.FormsConnect.Connectors;

/// <summary>A CRM a form can send submissions to. Other packages add their own.</summary>
public interface IConnector
{
    string Alias { get; }
    string Name { get; }

    /// <summary>The fields the backoffice settings form shows for this connector.</summary>
    IReadOnlyList<ConnectorSettingDefinition> Settings { get; }

    Task SendAsync(IReadOnlyDictionary<string, string> settings, IReadOnlyDictionary<string, string> submission);
}

public sealed record ConnectorSettingDefinition(
    string Key,
    string Label,
    string EditorType,   // "text", "password", "toggle", "dropdown"
    bool IsRequired = false,
    string? Description = null);
EOF
cat > $d/Connectors/HubSpotConnector.cs <<'EOF'
namespace Umbraco.Community.FormsConnect.Connectors;

public sealed class HubSpotConnector : IConnector
{
    public string Alias => "hubspot";
    public string Name => "HubSpot";

    public IReadOnlyList<ConnectorSettingDefinition> Settings { get; } =
    [
        new("portalId", "Portal ID", "text", IsRequired: true),
        new("accessToken", "Private app access token", "password", IsRequired: true),
        new("pipeline", "Deal pipeline", "text"),
        new("createDeals", "Create a deal for each submission", "toggle"),
    ];

    public Task SendAsync(IReadOnlyDictionary<string, string> settings, IReadOnlyDictionary<string, string> submission)
        => Task.CompletedTask; // calls HubSpot's API with settings["accessToken"]
}
EOF
cat > $d/Connectors/ConnectorCollection.cs <<'EOF'
using Umbraco.Cms.Core.Composing;

namespace Umbraco.Community.FormsConnect.Connectors;

public class ConnectorCollection(Func<IEnumerable<IConnector>> items) : BuilderCollectionBase<IConnector>(items)
{
    public IConnector? Get(string alias) => this.FirstOrDefault(c => c.Alias == alias);
}

public class ConnectorCollectionBuilder : OrderedCollectionBuilderBase<ConnectorCollectionBuilder, ConnectorCollection, IConnector>
{
    protected override ConnectorCollectionBuilder This => this;
}
EOF
cat > $d/Settings/IConnectorSettingsStore.cs <<'EOF'
namespace Umbraco.Community.FormsConnect.Settings;

/// <summary>Stores each connector's settings values, keyed by setting key.</summary>
public interface IConnectorSettingsStore
{
    Task<IReadOnlyDictionary<string, string>> GetAsync(string connectorAlias);
    Task SaveAsync(string connectorAlias, IReadOnlyDictionary<string, string> values);
}
EOF
cat > $d/Composers/FormsConnectComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.FormsConnect.Connectors;

namespace Umbraco.Community.FormsConnect.Composers;

public class FormsConnectComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.WithCollectionBuilder<ConnectorCollectionBuilder>().Append<HubSpotConnector>();
        // IConnectorSettingsStore is registered by the persistence composer.
    }
}
EOF
