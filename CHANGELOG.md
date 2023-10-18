# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project uses [Calendar Versioning](https://calver.org/) with a `YYYY.MM.patch` scheme.
All dates in this file are given in the [UTC time zone](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

## Unreleased

### Changed

- (Breaking change) Updated files for use with v0.4.0 of the Forklift tool. Previous versions must be used with forklift v0.3.

### Removed

- Removed the `testing/nodered-sandbox` package.

## v2023.9.0-beta.1 - 2023-09-14

### Changed

- Upgraded core/apps/planktoscope/device-backend's container image from v0.1.10 to v0.1.11
- Upgraded core/apps/planktoscope/project-docs's container image from v2023.9.0-alpha.2 to v2023.9.0-beta.1

## v2023.9.0-beta.0 - 2023-09-02

### Added

- Deployments of various host-only packages for host resources.

### Changed

- (Breaking change) Updated files for use with v0.3.1 of the Forklift tool. Previous versions must be used with forklift v0.1.
- (Breaking change) Reorganized deployment definitions with a directory tree structure.

## v2023.9.0-alpha.0 - 2023-05-30

### Added

- Basic packages for the v2023.9.0 release of the PlanktoScope software distro.
