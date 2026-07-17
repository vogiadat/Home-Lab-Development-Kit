# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Validate PowerShell scripts on a real Windows 11 Pro host.
- Validate Ubuntu scripts and Docker Compose templates inside the Ubuntu VM.
- Attach the generated PDF to a GitHub Release.

## [1.0.0] - 2026-07-17

### Added

- Added the full v1.0 deployment manual from Chapter 00 through Chapter 08 plus Appendix.
- Added PowerShell deployment stages for Windows host optimization, Hyper-V, Ubuntu VM creation, Tailscale guidance, monitoring, and backup.
- Added Ubuntu-side scripts for Docker installation and `/opt/homelab` bootstrap.
- Added Docker Compose baseline templates for Nginx, PostgreSQL, and Redis.
- Added Mermaid diagrams for cooling, Hyper-V NAT, Ubuntu VM, Docker, Tailscale, and operations.
- Added GitHub Actions workflow to render diagrams and build the PDF manual.
- Added Pandoc metadata and LaTeX styling for the PDF.
