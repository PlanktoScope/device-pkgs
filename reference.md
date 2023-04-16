# Reference

This document is a detailed reference for Pallet, the packaging system used by PlanktoScopes to manage software installations.


## Introduction

Pallet is a minimalist software packaging system for uniformly distributing and deploying software as [Docker Stacks](https://docs.docker.com/engine/reference/commandline/stack/) across single-host Docker Swarm Mode environments. Its design is inspired by the Go programming language's module system, and this reference document is heavily inspired by the [reference document for Go modules](https://go.dev/ref/mod).

## Repositories, packages, and versions

A Pallet *repository* is a collection of packages that are tested, released, distributed, and upgraded together. Repositories are how PlanktoScopes manage software installations. Pallet repositories may be downloaded directly from Git repositories hosted on Github. A Pallet repository is identified by a [*repository path*](#repository-paths), which is declared in a `repository.pallet.yml` file. The *repository root directory* is the directory that contains the `repository.pallet.yml` file.

Each Pallet *package* within a repository specifies the conditions and consequences of its deployment on the host. Typically, a package specifies a Docker stack which will be deployed to a name specified by the package.

### Repository paths
A Pallet *repository path* is the canonical name for a repository, declared with the `path` field in the repository's `repository.pallet.yml` file. A repository's path is the prefix for package paths within the repository.

A repository path should communicate both what the repository does and where to find it. Typically, a Pallet repository path consists of a Github repository root path followed either by a subdirectory (if the collection contains multiple repositories) or by nothing at all (if the Github repository is a single Pallet repository).  `github.com/PlanktoScope/pallets/core` is an example of a Pallet repository path in a Github repository with multiple Pallet repositories, while `github.com/PlanktoScope/forklift` is an example of a Pallet repository path in a Github repository with a single Pallet repository.

- The *Github repository root path* is the portion of the Pallet repository path that corresponds to the root directory of the Github repository where the Pallet repository is maintained. For example, the Pallet repository `github.com/PlanktoScope/pallets/core` is under the Github repository root path `github.com/PlanktoScope/pallets`; and the Pallet repository `github.com/PlanktoScope/forklift` is under the Github repository root path `github.com/PlanktoScope/forklift`.
- If the Pallet repository is not defined in the Github repository's root directory, the Pallet *repository subdirectory* is the part of the repository path that names the directory. For example, the Pallet repository `github.com/PlanktoScope/pallets/core` is in the `core` subdirectory of the Github repository with root path `github.com/PlanktoScope/pallets`, so it has the Pallet repository subdirectory `core`; while the Pallet repository `github.com/PlanktoScope/forklift` is defined in the root directory of the Github repository `github.com/PlanktoScope/forklift`, so it has no Pallet repository subdirectory.

### Repository versions
A *repository version* is a Git tag which identifies an immutable snapshot of all Pallet repositories in a Github repository; thus, all Pallet repositories in a Github repository will have always have identical repository versions. A repository version may be either a release or a pre-release. Each version starts with the letter `v`, followed by either a semantic version or a calendar version. See the [Semantic Versioning 2.0.0 specification](https://semver.org/spec/v2.0.0.html) for details on how semantic versions are formatted, interpreted, and compared; see the [Calendar Versioning reference](https://calver.org/) for details on how calendar versions may be constructed.

### Package paths
The path of a Pallet package is the Pallet repository path joined with the subdirectory (relative to the Pallet repository root) which contains the package's `package.pallet.yml` file. That subdirectory is the *package root directory*. For example, the Pallet repository `github.com/PlanktoScope/pallets/core` contains a Pallet package in the directory `caddy-ingress`, which is that package's root directory and which contains a `package.pallet.yml` file for the package; and that package's path is `github.com/PlanktoScope/pallets/core/caddy-ingress`. Note that the package path cannot be opened as a web browser URL (so for example <https://github.com/PlanktoScope/pallets/core/caddy-ingress> gives a HTTP 404 Not Found error).

### Package resources
A Pallet package should describe its external interface with the Docker host as a list of *resources* which it requires from the host and/or provides to the host, and which can be:

- Docker networks
- Docker volumes
- Bind mounts
- Network services mapped to the host

A package will be deployed successfully if (and only if) all of the following conditions are satisfied:

- The resources it requires from the host have already been provided by other packages
- The resources it provides on the host don't conflict with resources provided by other packages

Information about the resources required and provided by the deployment of a Pallet package can be used by a Pallet package manager to prevent/detect conflicts between package deployments and to aid in resolving dependencies between packages.

Because some Docker hosts may already have ambiently-available resources (for example, an SSH server on port 22 installed using `apt-get`), a Pallet package may also include a list of resources already available on the host; such resources should be provided by the Docker host regardless of whether the package is installed. Installing or uninstalling such a package will not affect the actual existence of such resources; it will only change a Pallet package manager's assumptions about what resources are available on the host.

### Package deployments
Pallet packages specify how they will be deployed on the Docker Swarm Mode environment.

TODO: finish this section

### Package features
Pallet *features* provide a mechanism to express optional dependencies and optional external interfaces of a package. The design of Pallet features is inspired by the design of [Rust Cargo features](https://doc.rust-lang.org/cargo/reference/features.html).

A package defines a set of named features in its `package.pallet.yml` metadata file, and each feature can be either enabled or disabled. Each Pallet feature specifies any resources it requires from the Docker host, as well as any resources it exposes on the Docker host.

Additionally, a package may specify a default list of Pallet features to enable upon deployment, which is used if (and only if) a list of enabled features is not provided by a Pallet package manager.

### Package resources

TODO: finish this section

### Package versions
A *package version* identifies an immutable snapshot of a package, which may be either a release or a pre-release. Each version starts with the letter `v`, followed by a semantic version. Package versions are reported to users when applying an upgrade or downgrade of a Pallet repository in order to help users understand the changes they will make.

Usually, the following changes to a package will require incrementing the major component of that package's semantic version if the major component is nonzero:

TODO: update items to account for new fields within resources

- In the host specification:
  - TODO: finish this section
- In the deployment specification:
  - Adding a new required resource - this may break any deployment would subsequently be unable to satisfy the new requirement without manual intervention
  - Adding a new provided resource - the added resource may conflict with resources provided by other deployed packages
  - Removing a provided resource - this may make the deployment unable to satisfy another deployed package's requirements
  - Adding a Pallet feature to the package's default list of features - the added Pallet feature may conflict with features provided by other deployed packages
  - Removing a Pallet feature from the package's default list of features - this may make the deployment unable to satisfy another deployed package's requirements
- In the list of pallet features offered by the package:
  - Removing or renaming any Pallet feature - this may break any installation which had enabled the feature
  - In any Pallet feature:
    - Adding a new required resource - this may break any deployment which had enabled the feature but would subsequently be unable to satisfy the new requirement without manual intervention
    - Adding a new provided resource - the added resource may conflict with resources provided by other deployed packages
    - Removing a provided resource - this may make the deployment unable to satisfy another deployed package's resource requirements
- Making a backwards-incompatible change to any external interfaces (protocols, APIs, schemas, data formats, etc.) provided or required by that package - this may break compatibility with other packages which may interact with those interfaces. Backwards-incompatible changes in an interface include:
  - Adding a new requirement
  - Removing a previously-provided functionality

The following changes to a package will usually only require incrementing the minor component of the package's semantic version:

TODO: update items to account for new fields within resources

- Adding a new Pallet feature, without adding it to the default list of enabled features
- Removing a requirement from any Pallet feature
- Making a backwards-compatible change to any external interfaces provided or required by that package. Backwards-compatible changes in an interface include:
  - Adding new optional functionality
  - Removing a requirement

It is the reponsibility of the package maintainer to document the package's external interfaces and to increment the major component of a package's semantic version when needed.

## Repository metadata

The metadata for a repository is defined by a YAML file named `repository.pallet.yml` in the repository's root directory. Here is an example of a `repository.pallet.yml` file:

```yaml
path: github.com/PlanktoScope/pallets/core
```

The rest of this section describes the fields in the repository metadata file:

### `path`
`path` is the repository path.
- This field is required.
- Example:

  ```yaml
  path: github.com/PlanktoScope/pallets/core
  ```

## Package metadata

The metadata for a package is defined by a YAML file named `package.pallet.yml` in the package's root directory. Here is an example of a `package.pallet.yml` file:

TODO: document the schema
