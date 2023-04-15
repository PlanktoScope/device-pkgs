# Reference
This document is a detailed reference for Pallet, the packaging system used by PlanktoScopes to manage software installations.

## Introduction

Pallet is a minimalist software packaging system for uniformly distributing and deploying software as [Docker Stacks](https://docs.docker.com/engine/reference/commandline/stack/) across many Docker Swarms. Its design is inspired by the Go programming language's module system, and this reference document is heavily inspired by the [reference document for Go modules](https://go.dev/ref/mod).

## Repositories, packages, and versions
A Pallet *repository* is a collection of packages that are released, distributed, and upgraded together. Repositories are how PlanktoScopes manage software deployments. Pallet repositories may be downloaded directly from Git repositories hosted on Github. A Pallet repository is identified by a *repository path*, which is declared in a `repository.yml` file. The *repository root directory* is the directory that contains the `repository.yml` file.

Each Pallet *package* within a repository is a Docker Stack deployed to a name specified by the package. The path of a package is the repository path joined with the subdirectory containing the package (relative to the repository root). For example, the repository `github.com/PlanktoScope/pallets/core` contains a package in the directory `caddy-ingress`; that package's path is `github.com/PlanktoScope/pallets/core/caddy-ingress`.

### Repository paths
A *repository path* is the canonical name for a repository, declared with the `path` field in the repository's `repository.yml` file. A repository's path is the prefix for package paths within the repository.

A repository path should communicate both what the repository does and where to find it. Typically, a Pallet repository path consists of a Github repository root path followed by (if the collection contains multiple repositories) a subdirectory.

- The *Github repository root path* is the portion of the Pallet repository path that corresponds to the root directory of the Github repository where the Pallet repository is maintained.
- If the repository is not defined in the Github repository's root directory, the *repository subdirectory* is the part of the repository path that names the directory. For example, the repository `github.com/PlanktoScope/pallets/core` is in the `core` subdirectory of the Github repository with root path `github.com/PlanktoScope/pallets`, so it has the repository subdirectory `core`.

### Repository versions
A *repository version* is a Git tag which identifies an immutable snapshot of a Pallet repository, which may be either a release or a pre-release. Each version starts with the letter `v`, followed by either a semantic version or a calendar version. See the [Semantic Versioning 2.0.0 specification](https://semver.org/spec/v2.0.0.html) for details on how semantic versions are formatted, interpreted, and compared; see the [Calendar Versioning reference](https://calver.org/) for details on how calendar versions may be constructed.

By design, all Pallet repositories in a Github repository will have the same repository version.

### Package versions

A *package version* identifies an immutable snapshot of a package, which may be either a release or a pre-release. Each version starts with the letter `v`, followed by a semantic version. Currently, the only use for package versions is for them to be reported in order to help users understand the changes made by applying an upgrade or downgrade of the Pallet repository version installed on a PlanktoScope.
