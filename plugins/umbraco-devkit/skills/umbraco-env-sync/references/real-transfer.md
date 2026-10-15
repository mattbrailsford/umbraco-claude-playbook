# A real transfer between two local sites

Unit tests prove a connector maps what it's given. Only a real transfer proves the whole
chain: registration, export on save, the file, the restore passes, the target's database.
Both routes below run on one machine with two SQLite test sites and no license.

## Set up two sites

1. Create site A from the project's test site (or `dotnet new umbraco` with
   `--development-database-type SQLite` and unattended install settings), referencing the
   package and its sync package.
2. Copy it to site B, leaving out `umbraco/Data`, `umbraco/Deploy`, `uSync`, and logs, so B
   starts with an empty database.
3. Run each on its own port. Use HTTPS (`ASPNETCORE_URLS=https://localhost:<port>`): the
   backoffice login refuses plain HTTP.

## Create test data on site A

Create the entities through the package's own service or Management API, not by writing
to the database, so the save notifications fire and the export is written. From a logged-in
backoffice page, `fetch` the package's Management API with the header
`Authorization: Bearer [redacted]` and `credentials: 'include'`; Umbraco swaps in the real
token from its cookie.

Give a secret field a recognizable fake value (`sk-TEST-SECRET-123`), and include at least
one entity that links to another.

## uSync route

1. On site A, set `uSync:Settings:ExportAtStartup` to `All` (or rely on `ExportOnSave`),
   and run it. The files appear under `uSync/v<major>/<handler folder>/`.
2. Copy A's `uSync` folder to site B.
3. On site B, set `uSync:Settings:ImportAtStartup` to `All`, and run it. The log reports
   `uSync Import: ... changes`.

## Deploy route (files on disk)

Deploy's disk import runs on `localhost` without a license key.

1. On site A, save the entities. Deploy writes
   `umbraco/Deploy/Revision/<entity-type>__<id>.uda`.
2. Copy the `.uda` files to site B's `umbraco/Deploy/Revision/`.
3. Create an empty file `umbraco/Deploy/deploy` on site B, with B running. Deploy picks it
   up and leaves `deploy-complete` or `deploy-failed` (with the exception inside) next to
   it.
4. If B is starting for the first time, the import can run before the package's own
   migrations finish and fail with "no such table". Wait for startup, then create the
   trigger file again.

Over-the-wire transfer needs the two sites configured as Deploy environments of each
other; this route doesn't cover it.

## Check the result

- **The export:** grep it for the fake secret. If it's there, the default exclusions don't
  work, however the value is stored at rest.
- **Site B's database:** the entities exist, with the same keys as on A, every field
  carried over, and links resolved.
- **Run it twice.** A second import should report no changes. If it does, the export isn't
  stable.

## SQLite and a package with its own data access

If the package reads and writes through its own EF Core `DbContext` and the site runs on
SQLite, Deploy's restore can fail with "database is locked" or "database table is locked":
Deploy holds a transaction on one connection while the package opens another. Give the
package its own SQLite file when Umbraco runs on SQLite (a separate connection string), and
document it. SQL Server doesn't have the problem.
