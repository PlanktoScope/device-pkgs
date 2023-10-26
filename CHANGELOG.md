# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project uses [Calendar Versioning](https://calver.org/) with a `YYYY.MM.patch` scheme.
All dates in this file are given in the [UTC time zone](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

## Unreleased

### Added

- Added a `dev-mock` feature flag to the `core/apps/planktoscope/device-portal` allowing that package to be run on non-Raspberry Pi OS Docker hosts with a fake hardcoded machine name (`metal-slope-23501`, corresponding to serial number `0xdeadc0de`) instead of looking up a machine serial number from `/sys/firmware/devicetree/base/serial-number`.

### Changed

- (Breaking change) Moved the `core/apps/planktoscope/device-portal` package's Compose App configuration related to Raspberry Pi OS integration (e.g. for deployment on PlanktoScopes) into a new feature flag named `deploy-rpi`. The machine name determined with this feature flag is overridden by the `dev-mock` feature flag, though if th `deploy-rpi` feature flag is enabled then the app will still require the existence of the `/sys/firmware/devicetree/base/serial-number` file on the Docker host.
- (Breaking change) Updated files for use with v0.4.0 of the Forklift tool. Previous versions must be used with forklift v0.3.
- Upgraded core/apps/planktoscope/project-docs's container image from v2023.9.0-beta.1 to v2023.9.0-beta.2

### Removed

- Removed the `testing/nodered-sandbox` package.
- Removed the default Docker Compose network from most Compose apps.

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
