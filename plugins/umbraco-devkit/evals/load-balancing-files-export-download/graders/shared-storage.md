---
type: llm
weight: 2
---
Context: on a load-balanced site each request can land on a different server, and each
server has its own disk. The start, status and download requests are separate requests.

PASS if the finished export, and the export's status, live somewhere every server can read:
Umbraco's file system (`MediaFileManager`, an `IFileSystem`), blob storage, or the database;
or the download endpoint generates and streams the CSV itself in that request, so nothing is
kept between requests.

FAIL if the export is written to the server's own disk (`App_Data`, a temp folder,
`wwwroot`, `Path.GetTempPath()`) and a later request reads it from there, or the export's
status or file path is kept only in memory (a static or singleton dictionary,
`IMemoryCache`), so a status or download request on another server can't find it.
