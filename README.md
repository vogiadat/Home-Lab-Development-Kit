# Home Lab Development Kit

> A practical deployment kit for building a reliable 24/7 home lab on a repurposed laptop.

This repository is the source project for a Vietnamese technical deployment manual, PowerShell automation scripts, diagrams, checklists, and release artifacts for a low-power home lab based on:

- Lenovo ThinkPad T14 Gen 2
- Windows 11 Pro
- Hyper-V
- Ubuntu Server LTS
- Docker and Docker Compose
- Tailscale remote access
- DIY cooling and battery protection

## Goals

- Build a stable 24/7 home lab without exposing services directly to the public internet.
- Keep the host cool, quiet, and safe for long-running operation.
- Use Hyper-V Internal Switch plus NAT for isolated VM networking.
- Use Tailscale for secure remote access.
- Keep the documentation, scripts, diagrams, and release PDF in one versioned project.

## Repository Structure

```text
.
├── .github/workflows/       # CI jobs for linting and PDF builds
├── docs/                    # Markdown source for the deployment manual
├── scripts/                 # PowerShell deployment and operations scripts
├── diagrams/                # Editable architecture diagrams
├── assets/                  # Images, icons, and rendered diagram assets
├── templates/               # Checklist and document templates
├── release/                 # Generated PDF and packaged releases
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Contribution guidance
└── README.md
```

## Documentation Plan

The v1.0 manual targets roughly 50-70 pages:

| Chapter | Topic |
| --- | --- |
| 00 | Bill of Materials |
| 01 | System Overview |
| 02 | DIY Cooling and Battery Protection |
| 03 | Windows Host Optimization |
| 04 | Hyper-V Deployment |
| 05 | Ubuntu Server |
| 06 | Docker Platform |
| 07 | Tailscale Remote Access |
| 08 | Operations and Maintenance |
| Appendix | PowerShell, troubleshooting, and checklists |

## Automation Plan

Scripts are organized by operational area:

```text
scripts/
├── Config/
├── Modules/
│   ├── 01-System/
│   ├── 02-HyperV/
│   ├── 03-VM/
│   ├── 04-Tailscale/
│   ├── 05-Monitoring/
│   └── 06-Backup/
└── Deploy.ps1
```

The deployment scripts are designed to be modular and repeatable. The project intentionally avoids a single opaque "do everything" script so each step can be verified and rerun safely.

## Roadmap

- [x] Bootstrap repository structure
- [x] Write Deployment Manual v1.0
- [x] Add PowerShell deployment framework
- [x] Add editable architecture diagrams
- [x] Add rendered diagram assets
- [x] Add PDF build pipeline
- [ ] Publish v1.0 release artifact

## Release Status

v1.0.0 is release-prep ready. The manual source, scripts, diagrams, templates, and PDF workflow are present.

Before publishing the GitHub Release:

- Review the generated PDF artifact.
- Validate scripts on the target Windows and Ubuntu systems.
- Create the `v1.0.0` tag.
- Attach the PDF to the GitHub Release.

## Create Release

Pushing a version tag triggers the release workflow:

```bash
./scripts/create-release-tag.sh v1.0.0
```

The workflow builds the PDF and attaches it to the GitHub Release.

See [docs/RELEASE_PROCESS.md](docs/RELEASE_PROCESS.md) for the full process, including how to handle an existing tag.

## Build PDF

Install Pandoc, XeLaTeX, Node.js, and Mermaid CLI, then run:

```bash
npm install -g @mermaid-js/mermaid-cli
./scripts/render-diagrams.sh
./scripts/build-pdf.sh
```

The generated PDF is written to:

```text
release/Home-Lab-Development-Kit-v1.0.pdf
```

## License

This project is licensed under the MIT License.
