# Release Process

This document describes how to publish a Home Lab Development Kit release.

## Normal Release

Use the helper script from a clean `main` branch:

```bash
./scripts/create-release-tag.sh v1.0.0
```

The script:

1. Confirms the tag format.
2. Confirms the working tree is clean.
3. Confirms the tag does not already exist locally or remotely.
4. Creates an annotated tag.
5. Pushes the tag to GitHub.

Pushing the tag starts the `Release` GitHub Actions workflow.

## Existing Tag Before Release Workflow

If the tag already existed before `.github/workflows/release.yml` was added, do not force-move the tag unless you intentionally want to rewrite release history.

Use the GitHub UI instead:

```text
GitHub
  -> Actions
  -> Release
  -> Run workflow
  -> tag: v1.0.0
```

The workflow supports manual dispatch with a tag input.

## Release Artifacts

The workflow builds and attaches:

```text
release/Home-Lab-Development-Kit-v<version>.pdf
```

Example:

```text
release/Home-Lab-Development-Kit-v1.0.0.pdf
```

## Release Notes

Release notes are selected by minor version.

For tag:

```text
v1.0.0
```

The workflow uses:

```text
docs/RELEASE_NOTES_v1.0.md
```

## Do Not Force Tags By Default

Avoid:

```bash
git tag -f v1.0.0
git push --force origin v1.0.0
```

Force-moving tags can confuse users and release automation. Use a new patch version such as `v1.0.1` if the release content materially changes after `v1.0.0`.
