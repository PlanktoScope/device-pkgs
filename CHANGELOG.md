# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project uses [Calendar Versioning](https://calver.org/) with a `YYYY.minor.patch` scheme.
All dates in this file are given in the [UTC time zone](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

## Unreleased

### Added

- Added a new `core/apps/dozzle` package for viewing Docker container logs.
- Added a new `core/infra/prometheus` package for handling all Prometheus metrics.
- Added a new `core/apps/node-exporter` package for generating Prometheus metrics about the state of the host system.
- Added a new `core/apps/grafana` package for visualizing Prometheus metrics, including a dashboard summarizing the state of the host system.
- Exposed the `/ps/node-red-v2/api/*` path for prototyping HTTP API endpoints.
- Added `requires-grafana-host-summary-dashboard` and `requires-filebrowser-datasets` feature flags to `/core/apps/planktoscope/node-red-dashboard` to express resource requirements for apps embedded in the Node-RED dashboard.
- Added scripts for the PlanktoScope distro in `core/host/networking/autohotspot`, `core/host/interface-forwarding`, `core/host/planktoscope/gpio-init`, and `core/host/planktoscope/machine-name`.
- Added the Node-RED settings file to `core/apps/planktoscope/node-red-dashboard`.

### Changed

- Upgraded `core/apps/planktoscope/device-portal`'s container image from v0.1.12 to v0.1.14.
- Upgraded all packages which use the `alpine` container image from 3.18.3 to 3.19.0.
- Upgraded all packages which use the `filebrowser/filebrowser` container image from v2.24.2 to v2.27.0.
- Upgraded `core/apps/portainer`'s container image from 2.18.4 to 2.19.4.
- Upgraded `core/infra/caddy-ingress`'s container image from 2.8.6 to 2.8.10.
- Upgraded `core/infra/mosquitto`'s container image from 2.0.17 to 2.0.18.
- Changed some package resource dependency relationships to be nonblocking for `plt apply` and `dev plt apply`.
- (Breaking change) Reorganized packages in `core/host`.

### Fixed

- Removed unnamed volumes created by the packages for filebrowser instances and for mosquitto.
- Changed underscores to hyphens in Docker volume names, for consistency with Docker network names.

## v2023.9.0 - 2023-12-30

(this release involves no changes from v2023.9.0-beta.2; it's just a promotion of v2023.9.0-beta.2 to a stable release)

## v2023.9.0-beta.2 - 2023-12-02

### Added

- Added a `dev-mock` feature flag to the `core/apps/planktoscope/device-portal` package allowing that package to be run on non-Raspberry Pi OS Docker hosts with a fake hardcoded machine name (`metal-slope-23501`, corresponding to serial number `0xdeadc0de`) instead of looking up a machine serial number from `/sys/firmware/devicetree/base/serial-number`.
- Added a `full-site` feature flag to the `core/apps/planktoscope/docs` package which provides the entire documentation site, including hardware setup guides.

### Changed

- (Breaking change) Moved the `core/apps/planktoscope/device-portal` package's Compose App configuration related to Raspberry Pi OS integration (e.g. for deployment on PlanktoScopes) into a new feature flag named `deploy-rpi`. The machine name determined with this feature flag is overridden by the `dev-mock` feature flag, though if th `deploy-rpi` feature flag is enabled then the app will still require the existence of the `/sys/firmware/devicetree/base/serial-number` file on the Docker host.
- (Breaking change) Updated files for use with v0.4.0 of the Forklift tool. Previous versions must be used with forklift v0.3.
- Upgraded core/apps/planktoscope/docs's container images from v2023.9.0-beta.1 to v2023.9.0-beta.2.
- Upgraded core/apps/planktoscope/device-portal's container image from v0.1.11 to v0.1.12.

### Removed

- Removed the `testing/nodered-sandbox` package.
- Removed the default Docker Compose network from most Compose apps.
- Removed the hardware setup guides from the default configuration of the `core/apps/planktoscope/docs` package. They can be added back using that package's `full-site` feature flag.

## v2023.9.0-beta.1 - 2023-09-14

### Changed

- Upgraded core/apps/planktoscope/device-portal's container image from v0.1.10 to v0.1.11
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
