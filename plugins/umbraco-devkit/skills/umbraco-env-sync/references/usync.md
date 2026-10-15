# uSync

How the rules in `SKILL.md` map onto uSync's API. Check names against the uSync source and
docs for the version matching the project's CMS major; uSync's major follows Umbraco's.

Sources: [uSync source](https://github.com/KevinJump/uSync),
[uSync.Complete extending docs](https://docs.jumoo.co.uk/usync/complete/extending/flow).
Public implementations to read: [uSync.Umbraco.Commerce](https://github.com/Jumoo/uSync.Umbraco.Commerce)
(ordered handlers, second pass, post-import), [SeoToolkit.Umbraco](https://github.com/patrickdemooij9/SeoToolkit.Umbraco)
and [Umbraco-CSP-manager](https://github.com/Matthew-Wise/Umbraco-CSP-manager) (small
settings handlers, push/pull menu items).

## How it differs from Deploy

- One XML file per item under `uSync/v<major>/<folder>`. Free uSync reads and writes these
  files. Push and pull between servers (Publisher, in the licensed uSync.Complete) zips the
  same files and imports them on the target. So there's no separate transfer API: the same
  serializer serves disk and wire.
- Order comes from a fixed priority number per handler, not from a dependency graph.
- Saving the file when an entity is saved is wired up by hand.
- uSync.Complete's People Edition can sync users and members. Most sites don't run it, so
  still link to them by alias.

## The pieces

| Piece | What it is |
|---|---|
| Serializer | Entity to XML and back. Subclass `SyncSerializerRoot<T>` (or `SyncSerializerBase<T>` when `T : IEntity`), carries `[SyncSerializer("<guid>", "Name", "ItemType")]`. Implements `SerializeCoreAsync`, `DeserializeCoreAsync`, `FindItemAsync(Guid)`, `FindItemAsync(string alias)`, `SaveItemAsync`, `DeleteItemAsync`, `ItemKey`, `ItemAlias`. |
| Handler | Reads and writes the files for one type. Subclass `SyncHandlerRoot<T, TContainer>` (or `SyncHandlerBase<T>`), carries `[SyncHandler(alias, name, folder, priority, Icon = ..., EntityType = ...)]`, overrides `Group` (for example `"Settings"`). |
| Mapper | Translates a property editor's stored value. Implements `ISyncMapper` (base `SyncValueMapperBase`), lists `Editors`. |
| Dependency checker | `ISyncDependencyChecker<T>.GetDependenciesAsync(item, flags)`. Free uSync collects these; Publisher uses them to build what it sends. |
| Item manager | `ISyncItemManager` with `[SyncItemManager(entityType)]`. Needed for an entity to appear in Publisher's push and pull menus. |

Handlers, serializers, mappers, and dependency checkers are found by type scanning. A
composer is still needed for `UdiParser.RegisterUdiType` and for the notification handlers
that export on save.

The optional `uSync.Extend` package has simpler bases (`SyncObjectHandler`,
`SyncObjectSerializer`) for plain objects.

## The export shape

Every file's root element carries `Key`, `Alias`, and `Level` attributes. `FindItemAsync(XElement)`
looks up by key first, then by alias, so the key-then-alias rule in `SKILL.md` comes
built in, as long as `FindItemAsync(string alias)` is implemented.

## Restore order

- **Priority.** Handlers run in `priority` order. Core uses 1000 to 2000 (languages 1005,
  data types 1010, content types 1030, media 1200, content 1210). Put a package handler
  above 2000 to run after core, or in a gap below the core type that needs it (a package
  whose entities content links to runs before 1200). Document your handlers' numbers and
  why in one constants file.
- **Second pass.** Set `IsTwoPass = true` on the serializer and handler attributes, then
  fill in links in `DeserializeSecondPassAsync(item, node, options)`, which runs once every
  item of that handler exists.
- **After every handler.** Links across handlers that the priority order can't satisfy go
  in `ISyncPostImportHandler.ProcessPostImportAsync(actions, settings)`, which runs after
  all handlers.

## Export on save

`SyncHandlerRoot` handles `SavedNotification<T>`, `DeletedNotification<T>`, and
`MovedNotification<T>`, but nothing subscribes it for you. In the composer, register the
handler for your package's saved and deleted notifications
(`builder.AddNotificationAsyncHandler<ExampleSavedNotification, ExampleHandler>()`). If your
notifications don't derive from those, write a `HandleAsync` that calls `ExportAsync` and
then `CleanUpAsync`, guarded by `ShouldProcessEvent()`.

## Secrets

uSync has no general way to leave fields out. Its `DoNotSerialize` setting covers content
and media property aliases only, and `uSync.Extend` skips properties marked
`[IgnoreDataMember]`. So the package supplies the exclusions itself, read from its own
configuration section, following `SKILL.md`'s "Keep secrets out".

## Push and pull menu items

With uSync.Complete installed, an entity appears in Publisher's menus when it has an
`ISyncItemManager` (its `GetTreeType` returns `Settings` or `Content`) and backoffice
`entityAction` manifests of `kind: "publisher-push"` and `kind: "publisher-pull"` with
`forEntityTypes` listing your entity types. Keep these in their own package (`MyPackage.uSync.Complete`) so the free package
doesn't need Complete.

Not verified: Publisher is closed source, so how it uses a dependency's `Order` and `Level`
is not documented.
