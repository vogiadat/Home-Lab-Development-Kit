#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="${ROOT_DIR}/release"
COMBINED_MD="${RELEASE_DIR}/Home-Lab-Development-Kit-v1.0.md"
OUTPUT_PDF="${RELEASE_DIR}/Home-Lab-Development-Kit-v1.0.pdf"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc is required to build the PDF." >&2
  echo "Install pandoc and a XeLaTeX distribution, then re-run this script." >&2
  exit 127
fi

if ! command -v xelatex >/dev/null 2>&1; then
  echo "xelatex is required to build the PDF." >&2
  echo "Install a LaTeX distribution with XeLaTeX support, then re-run this script." >&2
  exit 127
fi

mkdir -p "${RELEASE_DIR}"

cat \
  "${ROOT_DIR}/docs/00-Bill-of-Materials.md" \
  "${ROOT_DIR}/docs/01-System-Overview.md" \
  "${ROOT_DIR}/docs/02-DIY-Cooling.md" \
  "${ROOT_DIR}/docs/03-Windows-Host-Optimization.md" \
  "${ROOT_DIR}/docs/04-Hyper-V-Deployment.md" \
  "${ROOT_DIR}/docs/05-Ubuntu-Server.md" \
  "${ROOT_DIR}/docs/06-Docker-Platform.md" \
  "${ROOT_DIR}/docs/07-Tailscale-Remote-Access.md" \
  "${ROOT_DIR}/docs/08-Operations-and-Maintenance.md" \
  "${ROOT_DIR}/docs/Appendix.md" \
  > "${COMBINED_MD}"

pandoc \
  "${ROOT_DIR}/docs/metadata.yml" \
  "${COMBINED_MD}" \
  --from markdown+yaml_metadata_block \
  --pdf-engine=xelatex \
  --toc \
  --toc-depth=2 \
  --number-sections \
  --include-in-header="${ROOT_DIR}/docs/pdf-style.tex" \
  -o "${OUTPUT_PDF}"

echo "Built ${OUTPUT_PDF}"
