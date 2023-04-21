# Reference

This document is a detailed reference for *Pallet*, the packaging system used by PlanktoScopes to manage software installations.


## Introduction

Pallet is a declarative software packaging system for uniformly distributing and deploying software as [Docker Stacks](https://docs.docker.com/engine/reference/commandline/stack/) on single-host Docker Swarm Mode environments. Its design is heavily inspired by the Go programming language's module system, and this reference document tries to echo the [reference document for Go modules](https://go.dev/ref/mod) for familiarity; certain aspects of Pallet are also inspired by the Rust programming language's [Cargo](https://doc.rust-lang.org/cargo/) package management system.

## Repositories, packages, and versions

A Pallet *repository* is a collection of packages that are tested, released, distributed, and upgraded together. Repositories are how PlanktoScopes manage software installations. Pallet repositories may be downloaded directly from Git repositories hosted on Github. A Pallet repository is identified by a [*repository path*](#repository-paths), which is declared in a `pallet-repository.yml` file. The *repository root directory* is the directory that contains the repository's `pallet-repository.yml` file.

Each Pallet *package* within a repository specifies the preconditions and consequences of its deployment on the host. Typically, a package declares some or all of the following:

- A Docker stack which will be deployed on the Docker host to a stack name specified by the package. If a newer version of a package uses the same stack name as an older version of that package, the stack will be replaced when upgrading or downgrading between those versions. If two or more packages with different repository paths use the same stack name, only one of those packages may be deployed on a host at any given time.
- A set of optional [*features*](#package-features) which may be enabled for the deployment. Features control the functionalities or behavior of the *package deployment*, which is fully and uniquely specified by declaring the package to deploy along with the features to enable in the deployment.
- A set of [*constraints*](#package-deployments-and-constraints) for determining whether the package deployment is allowed on the Docker host, including a list of any host [*resources*](#package-resource-constraints) which are required by the package deployment or provided by the package deployment. Features may also declare their own constraints, which are only used when those features are enabled.

All of this information is declared in a `pallet-package.yml` file. The *package root directory* is the directory that contains the package's `pallet-package.yml` file.

### Repository paths
A Pallet *repository path* is the canonical name for a repository, declared with the `path` field in the repository's `pallet-repository.yml` file. A repository's path is the prefix for package paths within the repository.

A repository path should communicate both what the repository does and where to find it. Typically, a Pallet repository path consists of a Github repository root path followed either by a subdirectory (if the collection contains multiple repositories) or by nothing at all (if the Github repository is a single Pallet repository).  `github.com/PlanktoScope/pallets/core` is an example of a Pallet repository path in a Github repository with multiple Pallet repositories, while `github.com/PlanktoScope/forklift` is an example of a Pallet repository path in a Github repository with a single Pallet repository.

- The *Github repository root path* is the portion of the Pallet repository path that corresponds to the root directory of the Github repository where the Pallet repository is maintained.
  - As an example, the Pallet repository `github.com/PlanktoScope/pallets/core` is under the Github repository root path `github.com/PlanktoScope/pallets`
  - As another example, the Pallet repository `github.com/PlanktoScope/forklift` is under the Github repository root path `github.com/PlanktoScope/forklift`.
- If the Pallet repository is not defined in the Github repository's root directory, the Pallet *repository subdirectory* is the part of the repository path that names the directory.
  - As an example, the Pallet repository `github.com/PlanktoScope/pallets/core` is in the `core` subdirectory of the Github repository with root path `github.com/PlanktoScope/pallets`, so it has the Pallet repository subdirectory `core`, which in turn is the repository's root directory.
  - As another example, the Pallet repository `github.com/PlanktoScope/forklift` is defined in the root directory of the Github repository `github.com/PlanktoScope/forklift`, so it has no Pallet repository subdirectory, and the Github repository's root directory is also the Pallet repository's root directory.

### Repository versions
A *repository version* is a Git tag which identifies an immutable snapshot of all Pallet repositories in a Github repository and all Pallet packages in each Pallet repository; thus, all Pallet repositories in a Github repository will have always have identical repository versions, and all Pallet packages in a Github repository will have the same repository version. A repository version may be either a release or a pre-release. Once a Git tag is created, it should not be deleted or changed to a different revision. Versions will be authenticated to ensure safe, repeatable deployments. If a tag is modified, clients may see a security error when downloading it.

Each version starts with the letter `v`, followed by either a semantic version or a calendar version. See the [Semantic Versioning 2.0.0 specification](https://semver.org/spec/v2.0.0.html) for details on how semantic versions are formatted, interpreted, and compared; the [Calendar Versioning reference](https://calver.org/) describes a variety of ways that calendar versions may be constructed, but any calendar versioning scheme used for a Pallet repository must meet the following requirements:

- The calendar version must have three parts (major, minor, and micro), and it may have additional labels for pre-release and build metadata following the semantic versioning specification.
- No version part may be zero-padded (so e.g. `2022.4.0` and `22.4.0` are allowed, while `2022.04.0` and `22.04.0` are not allowed).
- The calendar version must conform to the semantic versioning specifications for precedence, so that versions can be compared and sequentially ordered.

### Package paths
The path of a Pallet package is the Pallet repository path joined with the subdirectory (relative to the Pallet repository root) which contains the package's `pallet-package.yml` file. That subdirectory is the *package root directory*. For example, the Pallet repository `github.com/PlanktoScope/pallets/core` contains a Pallet package in the directory `caddy-ingress`. The `caddy-ingress` directory contains a `pallet-package.yml` file and thus is the root directory of a package which has a package path of `github.com/PlanktoScope/pallets/core/caddy-ingress`. Note that the package path cannot be resolved as a web page URL (so for example <https://github.com/PlanktoScope/pallets/core/caddy-ingress> gives a HTTP 404 Not Found error), because the package path is only resolvable in the context of a specific Github repository version.

## Package deployments and constraints
Usually, multiple package deployments are simultaneously active on a Docker host, and multiple package deployments will be modified by any package manager operation, for example:

- Adding new package deployments
- Removing existing package deployments
- Modifying the enabled features of existing package deployments
- Upgrading the versions of the Pallet repositories providing deployed packages
- Downgrading the versions of the Pallet repositories providing deployed packages

Each such operation will modify the set of all active package deployments on the Docker host, and it will succeed if (and only if) all of the following constraints will be satisfied by the resulting set of all package deployments:

- Docker stack name constraints:
  - Uniqueness constraint: no package deployment will attempt to use the same Docker stack name as another distinct package deployment; package deployments are distinct if they have different package paths and/or if they declare different sets of enabled features.
- Resource constraints:
  - Dependency constraint (*resource requirements*): all of the resources required by all of the active package deployments will also be resources provided by some set of the active package deployments.
  - Uniqueness constraint (*provided resources*): none of the resources provided by any of the active package deployments will conflict with resources provided by any subset of the active package deployments.

### Package resource constraints

The resource requirements and provided resources associated with a package deployment are part of the set of constraints which determine whether the package deployment is allowed. When a package deployment is not allowed, information about unsatisfied resource constraints should be used by the package manager to help users resolve dependencies and conflicts between package deployments.

A package deployment's declaration of resource requirements and provided resources is also a declaration of its external interface on the Docker host. Currently, resources can be:

- Docker networks
- Port listeners on ports mapped to the host
- Network services mapped to the host

Resource requirements and provided resources are specified as a set of *identification criteria* for determining whether two provided resources have conflicting identities or whether the identity of a package deployment's required resource matches the identity of a resource provided by another package.

Because some Docker hosts may already have ambiently-available resources not provided by applications running in Docker Stacks (for example, an SSH server on port 22 installed using `apt-get`), a Pallet package may also include a list of resources already ambiently provided by the host; if such a resource is declared, it should be provided by the Docker host regardless of whether the Pallet package is installed. Installing or uninstalling such a package will not affect the actual existence of such resources; it will only change a package manager's assumptions about what resources are ambiently provided by the host.

### Package features
Pallet *features* provide a mechanism to express optional resource constraints (both required resources and provided resources) and functionalities of a package. The design of Pallet features is inspired by the design of the [features system](https://doc.rust-lang.org/cargo/reference/features.html) in the Rust Cargo package management system.

A package defines a set of named features in its `pallet-package.yml` metadata file, and each feature can be either enabled or disabled by a package manager. Each Pallet feature specifies any resources it requires from the Docker host, as well as any resources it provides on the Docker host.

### Versioning with constraints and features

Usually, the following changes to a package will require incrementing the major component of that package's semantic version if the major component was already nonzero:

- Changing the Docker stack name to use for deploying the package
- Making changes which may introduce conflicts between provided resources, for certain combinations of package deployments:
  - In the host specification or the deployment specification:
    - Adding a provided resource
    - Modifying the identification criteria of a provided resource
  - In any optional feature:
    - Adding a new provided resource
- Making changes which may make dependencies between provided and required resources unresolvable, for certain combinations of package deployments:
  - In the host specification or the deployment specification:
    - Removing a provided resource
  - In the deployment specification:
    - Adding a resource requirement
    - Modifying the identification criteria of a resource requirement
  - In any optional feature:
    - Adding a new resource requirement
    - Removing a provided resource
- Making changes which may make a package deployment declaration invalid:
  - In the list of optional features offered by the package:
    - Removing any feature
    - Renaming any feature
- Making a backwards-incompatible change to any external technical interfaces (protocols, APIs, schemas, data formats, etc.) provided or required by that package: this may break compatibility with other deployed packages which interact with those interfaces. Backwards-incompatible changes include:
  - Adding a new requirement as part of the interface
  - Removing a previously-provided functionality from the interface
- Making a change to any user interfaces provided or by that package which would probably break users' existing mental models of how to use the interface.

The following changes to a package will usually only require incrementing the minor component of the package's semantic version:

- Adding a new optional feature
- Removing a requirement from any optional feature
- Making a backwards-compatible change to any external technical or user interfaces provided or required by that package. Backwards-compatible changes in an interface include:
  - Removing a requirement from the interface
  - Adding new optional functionality  to the interface

It is the reponsibility of the package maintainer to document the package's external interfaces, to increment the major component of a package's semantic version when needed, and to help users migrate smoothly across version upgrades and downgrades.

## Repository metadata

The metadata for a repository is defined by a YAML file named `pallet-repository.yml` in the repository's root directory. Here is an example of a `pallet-repository.yml` file:

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

The metadata for a package is defined by a YAML file named `pallet-package.yml` in the package's root directory. Here is an example of a `pallet-package.yml` file:

TODO: document the schema
