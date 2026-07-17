# Release Checklist

Use this checklist before publishing a tagged release.

## Documentation

- [ ] All planned chapters are present.
- [ ] Appendix is current.
- [ ] README roadmap reflects release status.
- [ ] CHANGELOG includes the release entry.
- [ ] Release notes are written.

## PDF

- [ ] GitHub Actions PDF build passes.
- [ ] Diagrams render correctly.
- [ ] Table of contents is present.
- [ ] Page numbers are present.
- [ ] Code blocks do not visibly overflow.
- [ ] PDF artifact is downloaded and reviewed.

## Scripts

- [ ] `Deploy.ps1 -Stage Check` runs on Windows.
- [ ] `Deploy.ps1 -Stage System` is reviewed before use.
- [ ] `Deploy.ps1 -Stage HyperV` is reviewed before use.
- [ ] `Deploy.ps1 -Stage VM` is reviewed before use.
- [ ] `Deploy.ps1 -Stage Tailscale` is reviewed before use.
- [ ] `Deploy.ps1 -Stage Monitoring` is reviewed before use.
- [ ] `Deploy.ps1 -Stage Backup` is reviewed before use.
- [ ] Ubuntu scripts are tested inside the Ubuntu VM.

## Release

- [ ] `./scripts/create-release-tag.sh v1.0.0` succeeds, or the `Release` workflow is run manually for an existing tag.
- [ ] Release workflow succeeds.
- [ ] GitHub Release is created automatically.
- [ ] PDF artifact is attached automatically.
- [ ] Known limitations are included in the release notes.
