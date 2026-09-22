# Diagram conventions for a PR description

Pick the smallest view that makes the key point clear. Skip any view that doesn't apply — a
one-file bug fix might use none of these and just need "Why" and "Special things to note."

Use a `diff` block when the point is what changed and the surrounding shape already exists.
Show the whole block, undiffed, when most of it is new, or when trimming context would hide
who owns what or in what order things happen.

## Pseudocode — a changed algorithm or business rule

```diff
 on(PublishContent)
-  save content
+  save content
+  if content has scheduled unpublish date
+    queue unpublish job
```

## Call chain — changed control flow

```diff
 ContentController.PublishContent
   ContentService.Save
+    ScheduledPublishService.QueueUnpublish
   ContentService.Publish
```

## Shallow file tree — changed responsibilities

```diff
 src/
 ├── Services/
+│   └── ScheduledPublishService.cs   # queues/cancels scheduled unpublish jobs
 ├── Notifications/
-└── ContentPublishedHandler.cs
+└── ContentPublishedHandler.cs        # now also cancels a pending unpublish
```

## EF Core / SQL — a table or migration change

```diff
 CREATE TABLE ScheduledUnpublish (
   Id INT PRIMARY KEY,
   ContentKey UNIQUEIDENTIFIER NOT NULL,
+  UnpublishDate DATETIME2 NOT NULL,
+  CONSTRAINT FK_ScheduledUnpublish_Content FOREIGN KEY (ContentKey)
+    REFERENCES umbracoNode(uniqueID)
 )
```

Show the whole `CREATE TABLE`/entity when the table is new; diff it when adding or changing a
column on an existing one.

## Lit component tree — changed backoffice UI

```diff
 <my-package-workspace-view> (client/src/workspace)
   @state() private _content
+  @state() private _scheduledUnpublishDate
   <uui-box>
+    <uui-input type="datetime-local">
```

Note properties/state and package boundaries that matter to the change, not every attribute.

## Manifest / composer registration — a changed extension point

Umbraco-specific: most backoffice extensions and server-side pipeline hooks register through a
manifest entry or a `Composer`/`IComposer`, not through code a reviewer will stumble onto by
reading top to bottom. Show the registration diff explicitly — it's easy to miss in a large
diff otherwise.

```diff
 {
   "type": "workspaceView",
   "alias": "MyPackage.WorkspaceView.ScheduledUnpublish",
+  "name": "Scheduled Unpublish Workspace View",
+  "js": "/App_Plugins/MyPackage/workspace-view.js",
+  "conditions": [
+    { "alias": "Umb.Condition.WorkspaceAlias", "match": "Umb.Workspace.Document" }
+  ]
 }
```

## Data structure / contract — a new or changed type

Show the complete shape when it's new or central to the change; diff it when adding to an
existing one.

```csharp
public record ScheduledUnpublishRequest(Guid ContentKey, DateTime UnpublishDate);
```

## Rule of thumb

Tell the story in the order a reader needs it — a data structure or contract usually comes
before the code that consumes it, a table before the query that reads it. All views are
optional; use only the ones that carry weight for this specific PR.
