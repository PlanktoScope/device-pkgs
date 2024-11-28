# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project uses [Calendar Versioning](https://calver.org/) with a `YYYY.minor.patch` scheme.
All dates in this file are given in the [UTC time zone](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

## Unreleased

### Changed

- `core/apps/planktoscope/device-portal`: the `ghcr.io/planktoscope/device-portal` container is upgraded from v0.2.3 to v0.2.4.
- `core/apps/planktoscope/docs`: the `ghcr.io/planktoscope/project-docs` container is upgraded.

## v2024.0.0-beta.2 - 2024-09-19

### Added

- `core/apps/grafana`: added a `cpu-limit` feature flag to limit the CPU usage of the Grafana dashboard, to prevent CPU starvation for other processes.
- `core/host/prepare-custom-image`: added a script overlaid into `/usr/libexec/prepare-custom-image` which can be run to reset the filesystem in preparation for cloning the filesystem as an SD card image.

## v2024.0.0-beta.1 - 2024-06-24

### Changed

- `core/apps/planktoscope/device-portal`: the `ghcr.io/planktoscope/device-portal` container is upgraded from v0.2.2 to v0.2.3.

### Fixed

- `core/host/machine-name` no longer declares provided fileset resources which (as of v2024.0.0-beta.0) are no longer provided.

## v2024.0.0-beta.0 - 2024-06-07

### Added

- `core/host/machine-name` now exports the `machine-name` binary into the PlanktoScope OS's overlay for `/usr`. The machine-name binary with the correct CPU architecture target for the host is selected when Forklift's downloads cache is populated.

### Changed

- `core/apps/filebrowser-root`: the `filebrowser/filebrowser` container image is upgraded from v2.27.0 to v2.30.0.
- `core/apps/planktoscope/filebrowser-backend-logs`: the `filebrowser/filebrowser` container image is upgraded from v2.27.0 to v2.30.0.
- `core/apps/planktoscope/filebrowser-datasets`: the `filebrowser/filebrowser` container image is upgraded from v2.27.0 to v2.30.0.
- `core/apps/planktoscope/device-portal`: the `ghcr.io/planktoscope/device-portal` container is upgraded from v0.2.1 to v0.2.2.

## v2024.0.0-alpha.2 - 2024-04-25

### Added

- `core/apps/cockpit` now provides a drop-in config file for reverse-proxying (see the notes on additions to `core/host/cockpit`)
- `core/apps/planktoscope/node-red-dashboard` now exports more config files needed for the Node-RED dashboard.
- `core/host/cockpit` now provides system services to automatically generate the Cockpit config file from a drop-in config directory, and it provides some default drop-in config files - including drop-in files provided by some new feature flags: `allow-unencrypted`, `allow-origins-planktoscope-static-ips`, `allow-origins-planktoscope-legacy-mdns-names`, `allow-origins-planktoscope-mdns-names`, `allow-origins-templated-custom-domain-home`, and `allow-origins-templated-mdns-hostname`
- Added a `core/host/docker` package which exports an override to the default systemd `docker.service`.
- `core/host/machine-name` (renamed from `core/host/planktoscope/machine-name`) now exports everything needed for automatically updating machine name-related configurations (machine name, hostname, SSID).
- `core/host/machine-name`: the dynamically-generated machine name can now be overridden by making a file with a desired static name at `/etc/machine-name`.
- `core/host/machine-name`: if deployed on a non-Raspberry Pi computer, generation of the machine name now uses `/etc/machine-id` as a substitute for the Raspberry Pi's serial number, instead of falling back to a placeholder like `pkscope`.
- `core/host/machine-name`: the prefix for the hostname (and the SSID and the Cockpit configuration), which was previously hard-coded, can now be manually changed by creating a hostname template file at `/etc/hostname-template`. A default hostname template of `pkscope-{machine-name}` is provided the new `hostname-template-pkscope` feature flag.
- `core/host/networking/autohotspot` now exports everything needed for autohotspot functionality.
- `core/host/networking/avahi-daemon` now provides two feature flags for registering the PlanktoScope under mDNS aliases `planktoscope.local` and `pkscope.local`, respectively: `register-planktoscope-local` and `register-pkscope-local`
- `core/host/networking/dhcpcd` now exports an override to the default systemd `dhcpcd.service`.
- `core/host/networking/dnsmasq` now exports various drop-in config files for dnsmasq and adds a few new feature flags: `planktoscope-dhcp-interfaces`, to add another drop-in config file for dnsmasq based on the PlanktoScope OS's static IP address assignments for its various network interfaces; custom-domain, to add drop-in config file template for dnsmasq which uses the custom domain (newly configurable at `/etc/custom-domain`) for dnsmasq; and `planktoscope-custom-domain`, which provides a `/etc/custom-domain` file to set the custom domain to `pkscope`.
- `core/host/networking/hostapd` now provides system services to automatically generate the hostapd config file from a drop-in config directory, and it provides some default drop-in config files - including drop-in files provided by some new feature flags: `interface-wlan0`, `localization-us`, `planktoscope-password`, `ssid-hostname`
- `core/host/networking/hosts` now provides system services to automatically generate the hosts file from a drop-in config directory, and it provides some default drop-in config files - including hostnames previously provided by the Raspberry Pi OS, and also drop-in files provided by some new feature flags: `planktoscope-custom-domain-home` and `planktoscope-domain-machine-name`
- `core/host/networking/interface-forwarding` now exports everything needed for interface-forwarding functionality.
- `core/host/planktoscope/gpio-init` now exports everything needed for GPIO-initialization functionality.
- `core/host/planktoscope/gpsd` now exports all config files needed to support the GPS module (still no guarantee whether the files are actually correct, though!).
- `core/host/sshd` adds two feature flags: `ssh-server-enabled` to enable the `ssh.service` and `ensure-ssh-host-keys` to add and enable a service which automatically regenerates host keys for the SSH server if no host keys exist at boot.

### Changed

- (Breaking change) The minimum supported Forklift version for using this repository has been bumped from v0.4.0 to v0.7.0, because some packages provided by this repository now require functionality added by v0.7.0 (namely, file-exporting functionality) in order to work as described/expected.
- (Breaking change) `community/apps/portainer` was previously named `core/apps/portainer`; it's been moved out of `core`, as its default inclusion in the PlanktoScope OS is deprecated in v2024.0.0 of the PlanktoScope OS; in the future, the user will have to manually add this package to their custom pallet if they want to add Portainer.
- (Breaking change) `core/host/machine-name` was previously named `core/host/planktoscope/machine-name`; it's been renamed, as it can now be configured (via feature flags) without PlanktoScope-specific naming.
- (Breaking change) `core/host/machine-name`: the machine name is now generated at `/run/machine-name` rather than `/var/lib/planktoscope/machine-name`. however, a symlink is now exported to redirect `/var/lib/planktoscope/machine-name` to `/run/machine-name`, for backwards-compatibility with programs still expecting `/var/lib/planktoscope/machine-name`.
- (Breaking change) `core/host/machine-name`: automatic updating of the hostname based on the machine name is no longer default behavior, but rather has to be enabled with a new `generate-templated-hostname` feature flag. If a hostname template is unspecified, the default hostname template is now `machine-{machine-name}` instead of `pkscope-{machine-name}`.
- (Breaking change) `core/host/machine-name`: inclusion of a `pkscope-` prefix for the hostname (and the SSID and the Cockpit configuration) is no longer default behavior, but rather has to be enabled with a new `hostname-prefix-pkscope` feature flag.
- (Breaking change) `core/host/networking/dnsmasq`: use of `pkscope` as the custom domain is no longer default behavior, but rather has to be enabled with a new `planktoscope-custom-domain` feature flag.
- (Breaking change) `core/host/networking/hostapd`: various settings are no longer provided by default, but rather have to be enabled with the new `interface-wlan0`, `localization-us`, `planktoscope-password`, and `ssid-hostname` feature flags.
- (Breaking change) `core/host/networking/hosts`: hostnames involving the custom domain (e.g. `pkscope) are no longer added by default, but rather have to be enabled with a new `planktoscope-custom-domain-home` and `planktoscope-custom-domain-machine-name` feature flags.
- (Breaking change) Previously, the default behavior of the segmenter provided by `core/apps/planktoscope/device-backend/processing/segmenter` was to subtract consecutive masks to try to mitigate image-processing issues with objects which get stuck to the flowcell during imaging. However, when different objects occupied the same space in consecutive frames, the subtraction behavior would subtract one object's mask from the mask of the other object in the following frame, which would produce clearly incorrect masks. This behavior is no longer enabled by default; in order to re-enable it, you should enable the `pipeline-subtract-consecutive-masks` feature flag.
- All packages in `core/apps` which use the `alpine` container image have upgraded it from v3.19.0 to v3.19.1.
- `core/apps/dozzle`: the `amir20/dozzle` container image is upgraded from v6.0.6 to v6.5.1.
- `core/apps/grafana`: the `grafana/grafana-oss` container image is upgraded from v10.1.6 to v10.4.2.
- `core/apps/planktoscope/device-portal`: the `device-portal` container image is upgraded from v0.1.15 to v0.2.1.
- `core/infra/caddy-ingress`: the `lucaslorentz/caddy-docker-proxy` container image is upgraded from v2.8.10 to v2.8.11.
- `core/infra/prometheus`: the `prom/prometheus` container image is upgraded from v2.48.1 to v2.51.2.
- `core/host/networking/interface-forwarding` has a slightly simpler network configuration, and now all packets for the PlanktoScope's static IP addresses (e.g. 192.168.4.1, 192.168.5.1, 192.168.6.1, etc.) are routed to 127.0.0.1 regardless of whether the packet for that IP address came from the interface corresponding to it.

### Deprecated

- In the future, `core/host/planktoscope/machine-name` will remove support for looking up the machine name from `/var/lib/planktoscope/machine-name`; instead, only `/run/machine-name` will be supported.

### Removed

- `core/apps/cockpit` no longer has a resource dependency on a fileset involving `/etc/cockpit/cockpit.conf`.
- (Breaking change) `core/host/planktoscope/machine-name` no longer provides functionality to automatically update the Cockpit config based on the machine name. Instead, `core/host/cockpit` provides templating functionality to automatically update the Cockpit config, and the machine name and hostname can be interpolated into those templates.
- (Breaking change) `core/host/exim` is no longer provided, as exim was only provided by a Cockpit extension (`cockpit-storaged`) which is no longer installed by default on the PlanktoScope OS.

## v2024.0.0-alpha.1 - 2024-03-26

### Added

- Added provided/required files/directories to the resource interfaces of some packages.
- Added some `core/host` packages to specify assumptions about provided files/directories.

### Changed

- Upgraded `core/apps/planktoscope/docs`'s container image from v2023.9.0 to v2024.0.0-alpha.1
- Upgraded `core/apps/planktoscope/device-backend/processing/segmenter`'s container image from v2024.0.0-alpha.0 to v2024.0.0-alpha.1

## v2024.0.0-alpha.0 - 2024-02-06

### Added

- Added a new `core/apps/dozzle` package for viewing Docker container logs.
- Added a new `core/infra/prometheus` package for handling all Prometheus metrics.
- Added a new `core/apps/node-exporter` package for generating Prometheus metrics about the state of the host system.
- Added a new `core/apps/grafana` package for visualizing Prometheus metrics, including a dashboard summarizing the state of the host system.
- Exposed the `/ps/node-red-v2/api/*` path for prototyping HTTP API endpoints.
- Added `requires-grafana-host-summary-dashboard` and `requires-filebrowser-datasets` feature flags to `/core/apps/planktoscope/node-red-dashboard` to express resource requirements for apps embedded in the Node-RED dashboard.
- Added scripts for the PlanktoScope distro in `core/host/networking/autohotspot`, `core/host/interface-forwarding`, `core/host/planktoscope/gpio-init`, and `core/host/planktoscope/machine-name`.
- Added the Node-RED settings file to `core/apps/planktoscope/node-red-dashboard`.
- Added the dhcpcd config file to `core/host/networking/dhcpcd`.

### Changed

- (Breaking change) Changed the `core/apps/planktoscope/device-backend/processing/segmenter` package to deploy the segmenter as a Docker container rather than expecting it to exist on the host.
- (Breaking change) Reorganized packages in `core/host`.
- Now the `core/apps/planktoscope/filebrowser-backend-logs` package has a resource dependency on one or more deployments which save logs to the location expected by the package.
- Changed some package resource dependency relationships to be nonblocking for `plt apply` and `dev plt apply`.
- Upgraded `core/apps/planktoscope/device-portal`'s container image from v0.1.12 to v0.1.14.
- Upgraded all packages which use the `alpine` container image from 3.18.3 to 3.19.0.
- Upgraded all packages which use the `filebrowser/filebrowser` container image from v2.24.2 to v2.27.0.
- Upgraded `core/apps/portainer`'s container image from 2.18.4 to 2.19.4.
- Upgraded `core/infra/caddy-ingress`'s container image from 2.8.6 to 2.8.10.
- Upgraded `core/infra/mosquitto`'s container image from 2.0.17 to 2.0.18.

### Removed

- (Breaking change) Removed `core/apps/planktoscope/device-backend/processing/segmenter`'s MJPEG stream service on host port 8001, since it can now be accessed via Docker networking.

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
