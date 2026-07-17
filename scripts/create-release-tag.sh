#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"

if [ -z "${TAG}" ]; then
  echo "Usage: $0 v1.0.0" >&2
  exit 2
fi

if ! [[ "${TAG}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid tag format: ${TAG}" >&2
  echo "Expected semantic version format like v1.0.0" >&2
  exit 2
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean. Commit or stash changes before creating a release tag." >&2
  exit 1
fi

git fetch --tags origin

if git rev-parse "${TAG}" >/dev/null 2>&1; then
  echo "Tag already exists locally: ${TAG}" >&2
  exit 1
fi

if git ls-remote --tags origin "${TAG}" | grep -q "${TAG}"; then
  echo "Tag already exists on origin: ${TAG}" >&2
  exit 1
fi

git tag -a "${TAG}" -m "Home Lab Development Kit ${TAG}"
git push origin "${TAG}"

echo "Pushed release tag: ${TAG}"
echo "The GitHub Release workflow should start automatically."
