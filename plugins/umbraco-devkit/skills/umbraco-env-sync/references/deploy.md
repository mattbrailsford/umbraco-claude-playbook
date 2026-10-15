# Umbraco Deploy

How the rules in `SKILL.md` map onto Umbraco Deploy's API. Check names against the Deploy
docs and the `Umbraco.Deploy.Infrastructure` version for the project's major; the API
moves between majors.

Source: [Extend Deploy](https://docs.umbraco.com/umbraco-deploy/extending/extending).
Public implementations to read: [Umbraco.Commerce.Deploy](https://github.com/umbraco/Umbraco.Commerce.Deploy)
(disk and transfer entities, four restore passes, value connectors) and the `*.Deploy`
packages in [Umbraco.AI](https://github.com/umbraco/Umbraco.AI) (disk entities, secret
filtering, unit tests).

## The pieces

| Piece | What it is |
|---|---|
| Entity type | A string unique across every package, prefixed with yours: `"mypackage-example"`. |
| UDI | The typed id: `new GuidUdi("mypackage-example", entity.Id).EnsureClosed()`. Register the type once with `UdiParser.RegisterUdiType("mypackage-example", UdiType.GuidUdi)` in a composer. |
| Artifact | The exported item. Inherits `DeployArtifactBase<GuidUdi>`, which carries `Udi`, `Name`, `Alias`, and `Dependencies`. Serialized to JSON in `.uda` files and in transfers. |
| Service connector | Maps entity to artifact and back. Inherits `ServiceConnectorBase<TArtifact, GuidUdi, TEntity>`, carries `[UdiDefinition("mypackage-example", UdiType.GuidUdi)]`. Found by type scanning; no DI registration. |
| Value connector | Translates a property editor's stored value. Inherits `ValueConnectorBase`, lists `PropertyEditorAliases`. Found by type scanning. |

A package with several entities usually writes one connector base of its own over
`ServiceConnectorBase` (shared range handling, `ProcessInitAsync`, key-then-alias lookup)
and keeps each entity's connector to its mapping and passes.

## Dependencies

```csharp
dependencies.Add(new ArtifactDependency(currency.GetUdi(), ordering: false, ArtifactDependencyMode.Exist));
```

- `ordering`: when `true`, Deploy puts the dependency in its dependency tree and deploys it
  first. When pass numbers already order the restore, `false` is common.
- `Exist`: the dependency must exist on the target. `Match`: it must exist and match in
  all properties. Use `Match` when this entity is wrong without the current version of the
  other one.
- A dependency on a type Deploy can't move blocks the transfer and tells the user why. So
  don't declare dependencies on users or user groups; link to them by alias (see
  `SKILL.md`).

Serialization: Deploy writes dates and numbers with the invariant culture. For fixed
decimal places, `[JsonConverter(typeof(RoundingDecimalJsonConverter), 2)]` from
`Umbraco.Deploy.Serialization`.

## Restore passes

```csharp
protected override int[] ProcessPasses => [1, 4];

public override async Task<ArtifactDeployState<ExampleArtifact, Example>> ProcessInitAsync(
    ExampleArtifact artifact, IDeployContext context, CancellationToken cancellationToken = default)
{
    // Key first, then alias: an entity made by hand on both sites has two keys.
    var entity = await _service.GetAsync(artifact.Udi.Guid, cancellationToken)
        ?? await _service.GetByAliasAsync(artifact.Alias, cancellationToken);
    return CreateInitState(artifact, entity);
}

public override async Task ProcessAsync(
    ArtifactDeployState<ExampleArtifact, Example> state, IDeployContext context, int pass,
    CancellationToken cancellationToken = default)
{
    state.NextPass = GetNextPass(pass);

    switch (pass)
    {
        case 1: await CreateOrUpdateAsync(state, cancellationToken); break; // scalars only
        case 4: await FillLinksAsync(state, cancellationToken); break;      // links to other entities
        default: throw new ArgumentOutOfRangeException(nameof(pass));
    }
}
```

- `ProcessPasses` lists the passes this connector runs in. `ProcessInitAsync` runs first and
  starts the state at the first one.
- **Set `state.NextPass = GetNextPass(pass)` on every pass**, or the later passes never run.
- New entity: create it with the source key (`Id = artifact.Udi.Guid`). Assign the saved
  entity to `state.Entity` so later passes update it.
- Fill-in pass: resolve each linked UDI on the target. Missing and optional: set it empty and
  log. Missing and required: throw with a message naming it.
- `IContextCache` (passed to `GetArtifactAsync`) caches lookups for the length of one deploy
  operation. Use it for repeated lookups like "does the parent exist".

## Disk entities (`.uda` files)

1. **Register the type** with `IDiskEntityService.RegisterDiskEntityType("mypackage-example")`,
   from an `UmbracoApplicationStartingNotification` handler (or an `IAsyncComponent`) that
   returns early unless `IRuntimeState.Level == RuntimeLevel.Run`.
2. **Write the file on every save, delete it on every delete.** Publish a saved and a deleted
   notification from the package's own service, and handle them with
   `EntitySavedDeployRefresherNotificationAsyncHandlerBase<TEntity, TNotification>` and
   `EntityDeletedDeployRefresherNotificationAsyncHandlerBase<TEntity, TNotification>`.
   They write or delete the artifact and refresh its signature (a hash Deploy caches per
   environment to skip unchanged items).
   - When your notifications don't fit those bases (they carry only an id, or come from your
     own event system), do the same by hand: `IServiceConnectorFactory` to get the artifact,
     `IDiskEntityService.WriteArtifactsAsync` / `DeleteArtifacts`, then
     `ISignatureService.SetSignatures` / `ClearSignatures`.
3. **Name it for the schema comparison dashboard** (Settings > Deploy): a
   `deploy_entityTypes_mypackage-example` localization key. Without one, the raw entity type
   shows.

## Transfer entities (queue for transfer)

1. **Register the type** with `ITransferEntityService.RegisterTransferEntityType`, in the
   same kind of startup handler, instead of the disk service:

   ```csharp
   _transferEntityService.RegisterTransferEntityType(
       "mypackage-example",
       new DeployRegisteredEntityTypeDetailOptions
       {
           SupportsQueueForTransfer = true,
           SupportsQueueForTransferOfDescendents = true,
           SupportsRestore = true,
           PermittedToRestore = true,
           SupportsPartialRestore = true,
           SupportsImportExport = true,
       });
   ```

2. **Refresh signatures on save** with the saved refresher base and
   `HandleDiskArtifacts = false`.
3. **Add the menu items in the backoffice.** In a `backofficeEntryPoint`, register:
   - a `deployEntityActionRegistrar` with `actionAlias: "Deploy.EntityAction.Queue"` and
     `forEntityTypes` listing your backoffice entity types (item and collection)
   - a `deployEntityTypeMapping` from each backoffice entity type to the Deploy entity type,
     when they differ (`"mypkg:example"` → `"mypackage-example"`)
   - a `localization` with `deploy_entityTypes` names.
4. **Partial restore tree** (Deploy 18.2+): implement `ITreeServiceConnector` on the
   connector so editors can pick remote items from a real tree. Without it, Deploy shows a
   flat list from `ExpandRangeAsync`.

## Secrets

Read the exclusions from configuration under the package's section
(`Umbraco:MyPackage:Deploy`), bound in the composer. Filter when the artifact is built, and
again on restore, then merge into the target's settings rather than replace them. A layered
setup that works:

- `IgnoreSettings`: field names always left out.
- `IgnoreSensitive`: leave out fields the package marks sensitive.
- `IgnoreEncrypted` (default on): leave out encrypted values. Not enough on its own: if
  the service decrypts on read, the connector never sees the encrypted form.
- Config references (`$...`) always pass.

## SQLite

A package with its own EF Core `DbContext` needs its own SQLite file when the site runs on
SQLite, or Deploy's restore fails with "database is locked". Umbraco.Commerce.Deploy does
this in `ConfigureUmbracoCommerceDeployConnectionString`. See
[real-transfer.md](real-transfer.md).

## Tests

Connectors are plain classes: construct one with mocked services, call `GetArtifactAsync`,
check the artifact and its dependencies, then run `ProcessInitAsync` and each pass in order
against an empty mocked store and check what was saved.
