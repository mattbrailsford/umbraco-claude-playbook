---
type: llm
---
PASS if the review flags that UploadLogo writes the logo to the local web root, so other
servers (or a redeploy, or a scaled-out instance) won't have the file, and suggests a
shared store such as Umbraco's media file system (MediaFileManager / IFileSystem, which can
be blob storage), the Umbraco media library, or the database.

FAIL if the review does not raise local-disk storage as a problem for other servers.
