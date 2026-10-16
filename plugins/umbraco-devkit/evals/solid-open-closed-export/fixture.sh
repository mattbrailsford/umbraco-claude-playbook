#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Export
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<ISubmissionExporter, SubmissionExporter>();
    }
}
EOF
cat > src/MyPackage/Export/Submission.cs <<'EOF'
namespace MyPackage.Export;

public sealed record Submission(Guid Id, DateTime CreatedUtc, IReadOnlyDictionary<string, string> Fields);
EOF
cat > src/MyPackage/Export/SubmissionExporter.cs <<'EOF'
using System.Text;
using System.Text.Json;
using System.Xml.Linq;

namespace MyPackage.Export;

public interface ISubmissionExporter
{
    (byte[] Content, string ContentType, string Extension) Export(IEnumerable<Submission> submissions, string format);
}

internal sealed class SubmissionExporter : ISubmissionExporter
{
    public (byte[] Content, string ContentType, string Extension) Export(IEnumerable<Submission> submissions, string format)
    {
        switch (format)
        {
            case "json":
                return (JsonSerializer.SerializeToUtf8Bytes(submissions), "application/json", "json");
            case "xml":
                var doc = new XElement("submissions",
                    submissions.Select(s => new XElement("submission",
                        new XAttribute("id", s.Id),
                        new XAttribute("created", s.CreatedUtc),
                        s.Fields.Select(f => new XElement("field", new XAttribute("name", f.Key), f.Value)))));
                return (Encoding.UTF8.GetBytes(doc.ToString()), "application/xml", "xml");
            default:
                throw new NotSupportedException($"Unknown export format '{format}'.");
        }
    }
}
EOF
