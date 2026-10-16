#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco 17 package (C# plus a Lit backoffice client). Trunk branch: `main`.

## Feature workflow

Each feature gets a plan folder at `docs/plans/<feature-slug>/`.
EOF
mkdir -p docs/plans/tag-reports tests/Umbraco.Community.TagCloud.Tests
cat > docs/plans/tag-reports/BRIEF.md <<'EOF'
# Tag reports: brief

## Problem
Editors can't see which tags are used where, so the tag list grows messy.

## Who
Content editors with access to the Settings section.
EOF
cat > docs/plans/tag-reports/STORIES.md <<'EOF'
# Tag reports: stories

## STORY-1: See tag usage
As a content editor with Settings access,
I want a dashboard listing every tag with how many items use it,
so that I can spot tags nobody uses.

AC1 — lists tags
  Given the tags "news" (used 4 times) and "old" (used 0 times)
  When  I open the Tag Reports dashboard
  Then  both tags are listed with their counts

## STORY-2: Open the items for a tag
As a content editor with Settings access,
I want to click a tag in the report and see the items that use it,
so that I can retag them.

AC1 — shows items
  Given "news" is used by "Home" and "About"
  When  I click "news"
  Then  "Home" and "About" are listed
EOF
cat > tests/Umbraco.Community.TagCloud.Tests/TagUsageReportTests.cs <<'EOF'
// STORY-1 — See tag usage
namespace Umbraco.Community.TagCloud.Tests;

public class TagUsageReportTests { }
EOF
