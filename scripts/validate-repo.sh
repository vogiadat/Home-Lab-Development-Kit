#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "README.md"
  "CHANGELOG.md"
  "LICENSE"
  "docs/00-Bill-of-Materials.md"
  "docs/01-System-Overview.md"
  "docs/02-DIY-Cooling.md"
  "docs/03-Windows-Host-Optimization.md"
  "docs/04-Hyper-V-Deployment.md"
  "docs/05-Ubuntu-Server.md"
  "docs/06-Docker-Platform.md"
  "docs/07-Tailscale-Remote-Access.md"
  "docs/08-Operations-and-Maintenance.md"
  "docs/Appendix.md"
  "docs/RELEASE_NOTES_v1.0.md"
  "docs/RELEASE_PROCESS.md"
  "docs/metadata.yml"
  "docs/pdf-style.tex"
  "scripts/Deploy.ps1"
  "scripts/Config/HomeLab.config.psd1"
  "scripts/build-pdf.sh"
  "scripts/render-diagrams.sh"
  "scripts/create-release-tag.sh"
  "templates/release-checklist.md"
)

for file in "${required_files[@]}"; do
  if [ ! -f "${ROOT_DIR}/${file}" ]; then
    echo "Missing required file: ${file}" >&2
    exit 1
  fi
done

while IFS= read -r script; do
  bash -n "${script}"
done < <(find "${ROOT_DIR}/scripts" -type f -name '*.sh' | sort)

while IFS= read -r diagram; do
  if ! grep -qE '^(flowchart|graph|sequenceDiagram|classDiagram|stateDiagram|erDiagram|journey|gantt|pie)' "${diagram}"; then
    echo "Mermaid diagram may be invalid or empty: ${diagram}" >&2
    exit 1
  fi
done < <(find "${ROOT_DIR}/diagrams" -type f -name '*.mmd' | sort)

echo "Repository validation passed."
