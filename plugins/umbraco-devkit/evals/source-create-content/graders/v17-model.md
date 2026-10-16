---
type: llm
weight: 2
focus: trace
---
PASS if the code written in this run matches Umbraco 17's API:
- builds a ContentCreateModel with ContentTypeKey and ParentKey
- sets the name through Variants (a VariantModel with Name, Culture null for invariant)
- sets bodyText through Properties (a PropertyValueModel with Alias and Value)
- calls CreateAsync(model, userKey) with a Guid user key, using
  Constants.Security.SuperUserKey (not the obsolete int SuperUserId)
- checks the returned Attempt's Success/Status

FAIL if it uses InvariantName or InvariantProperties (removed in v16), passes an int user
id, or calls IContentService.Create/Save instead of IContentEditingService.
