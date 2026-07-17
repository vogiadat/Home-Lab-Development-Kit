#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/assets/images"
PUPPETEER_CONFIG="${ROOT_DIR}/diagrams/puppeteer-config.json"

if ! command -v mmdc >/dev/null 2>&1; then
  echo "mmdc is required to render Mermaid diagrams." >&2
  echo "Install @mermaid-js/mermaid-cli or run this through the GitHub Actions workflow." >&2
  exit 127
fi

mkdir -p "${OUTPUT_DIR}"

for diagram in "${ROOT_DIR}"/diagrams/*.mmd; do
  [ -e "${diagram}" ] || continue

  name="$(basename "${diagram}" .mmd)"
  output="${OUTPUT_DIR}/${name}.png"

  echo "Rendering ${diagram} -> ${output}"
  mmdc \
    --input "${diagram}" \
    --output "${output}" \
    --puppeteerConfigFile "${PUPPETEER_CONFIG}" \
    --backgroundColor white \
    --scale 2
done

echo "Rendered diagrams to ${OUTPUT_DIR}"
