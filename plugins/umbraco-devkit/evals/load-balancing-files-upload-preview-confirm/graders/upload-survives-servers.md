---
type: llm
weight: 2
---
Context: the upload-and-preview request and the confirm request are separate, and on a
load-balanced site they can reach different servers, each with its own disk and memory.

PASS if the confirm step can get the uploaded data on any server: Umbraco's temporary file
API (`ITemporaryFileService`, the backoffice temporary-file upload), Umbraco's file system
(`MediaFileManager`/`IFileSystem`) or other shared storage, the parsed rows stored in the
database, or the client sending the file or the parsed rows again with Confirm.

FAIL if the upload is saved to a folder of the package's own on local disk (`App_Data`,
`Path.GetTempPath()`, `wwwroot`) and the confirm request reads it from there, or the
parsed rows are kept in one server's memory (static or singleton dictionary,
`IMemoryCache`) between the two requests.
