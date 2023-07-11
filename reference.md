# Reference

This document is a detailed reference for *Pallets*, the packaging system used by PlanktoScopes to manage software installations.


## Introduction

Pallets is a declarative software packaging system for uniformly distributing and deploying software as [Docker Stacks](https://docs.docker.com/engine/reference/commandline/stack/) on single-host Docker Swarm Mode environments. Its design is heavily inspired by the Go programming language's module system, and this reference document tries to echo the [reference document for Go modules](https://go.dev/ref/mod) for familiarity; certain aspects of Pallets are also inspired by the Rust programming language's [Cargo](https://doc.rust-lang.org/cargo/) package management system.

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
- Host port listeners bound to network ports on the host
- Network services mapped to the host

Resource requirements and provided resources are specified as a set of *identification criteria* for determining whether two provided resources have conflicting identities or whether the identity of a package deployment's required resource matches the identity of a resource provided by another package.

Because some Docker hosts may already have ambiently-available resources not provided by applications running in Docker Stacks (for example, an SSH server on port 22 installed using `apt-get`), a Pallet package may also include a list of resources already ambiently provided by the host; if such a resource is declared, it should be provided by the Docker host regardless of whether the Pallet package is installed. Installing or uninstalling such a package will not affect the actual existence of such resources; it will only change a package manager's assumptions about what resources are ambiently provided by the host.

### Package features
Pallet package *features* provide a mechanism to express optional resource constraints (both required resources and provided resources) and functionalities of a package. The design of Pallet package features is inspired by the design of the [features system](https://doc.rust-lang.org/cargo/reference/features.html) in the Rust Cargo package management system.

A package defines a set of named features in its `pallet-package.yml` metadata file, and each feature can be either enabled or disabled by a package manager. Each Pallet package feature specifies any resources it requires from the Docker host, as well as any resources it provides on the Docker host.

### Versioning with constraints and features

Usually, the following changes to a package are backwards-incompatible, in which case they will require incrementing the major component of the semantic version of the repository providing that package, if the major component of the semantic version was already nonzero:

- Changing the Docker stack name to use for deploying the package
- Making changes which may introduce conflicts between provided resources, for certain combinations of package deployments:
  - In the host specification or the deployment specification:
    - Adding a provided resource
    - Modifying the identification criteria of a provided resource
  - In any optional feature:
    - Adding a new provided resource
    - Modifying the identification criteria of a provided resource
- Making changes which may make dependencies between provided and required resources unresolvable, for certain combinations of package deployments:
  - In the host specification or the deployment specification:
    - Removing a provided resource
    - Modifying the identification criteria of a provided resource
  - In the deployment specification:
    - Adding a resource requirement
    - Modifying the identification criteria of a resource requirement
  - In any optional feature:
    - Adding a new resource requirement
    - Removing a provided resource
    - Modifying the identification criteria of a provided resource
    - Modifying the identification criteria of a resource requirement
- Making changes which may make a package deployment declaration invalid:
  - In the list of optional features offered by the package:
    - Removing any feature
    - Renaming any feature
- Making a backwards-incompatible change to any external technical interfaces (protocols, APIs, schemas, data formats, etc.) provided or required by that package: this may break compatibility with other deployed packages which interact with those interfaces. Backwards-incompatible changes include:
  - Adding a new requirement as part of the interface
  - Removing a previously-provided functionality from the interface
- Making a change to any user interfaces provided or by that package which would probably break users' existing mental models of how to use the interface.

The following changes to a package are usually backwards-compatible, in which case they would only require incrementing the minor component of the semantic version of the repository providing that package:

- Adding a new optional feature
- Removing a resource requirement from any optional feature
- Making a backwards-compatible change to any external technical or user interfaces provided or required by that package. Backwards-compatible changes in an interface include:
  - Removing a requirement from the interface
  - Adding new optional functionality to the interface

It is the reponsibility of the package maintainer to document the package's external interfaces, to increment the major component of a repository's semantic version when needed, and to help users migrate smoothly across version upgrades and downgrades. If the repository uses calendar versioning rather than semantic versioning, the above requirements for incrementing the version components do not apply.

## Repository definition

The definition of a repository is stored in a YAML file named `pallet-repository.yml` in the repository's root directory. Here is an example of a `pallet-repository.yml` file:

```yaml
repository:
  path: github.com/PlanktoScope/pallets/core
  description: Officially-maintained open-source PlanktoScope packages
  readme-file: README.md
```

Currently, all fields in the repository metadata file are under a `repository` section.

### `repository` section

This section of the `pallet-repository.yml` file contains some basic metadata to help describe and identify the repository. Here is an example of a `repository` section:

```yaml
repository:
  path: github.com/PlanktoScope/pallets/testing
  description: Unstable PlanktoScope packages for testing
  readme-file: README.md
```

#### `path` field
This field of the `repository` section is the repository path.
- This field is required.
- Example:
  ```yaml
  path: github.com/PlanktoScope/pallets/community
  ```

#### `description` field
This field of the `repository` section is a short (one-sentence) description of the repository to be shown to users.
- This field is required.
- Example:
  ```yaml
  description: Community-maintained open-source PlanktoScope packages
  ```

#### `readme-file` field
This field of the `repository` section is the filename of a readme file to be shown to users.
- This field is required.
- The file must be located in the same directory as the `pallet-repository.yml` file.
- The file must be a text file.
- It is recommended for this file to be named `README.md` and to be formatted in [GitHub-flavored Markdown](https://github.github.com/gfm/).
- Example:
  ```yaml
  readme-file: README.md
  ```

## Package definition

The definition of a package is stored in a YAML file named `pallet-package.yml` in the package's root directory. Here is an example of a `pallet-package.yml` file:

```yaml
package:
  description: Reverse proxy for web services
  maintainers:
    - name: Ethan Li
      email: lietk12@gmail.com
  license: MIT
  sources:
    - https://github.com/lucaslorentz/caddy-docker-proxy

deployment:
  name: caddy-ingress
  definition-file: docker-stack.yml

features:
  service-proxy:
    description: Provides reverse-proxying access to Docker Swarm services defined by other packages
    requires:
      networks:
        - description: Bridge network to the host
          name: bridge
    provides:
      networks:
        - description: Overlay network for Caddy to connect to upstream services
          name: caddy-ingress
      listeners:
        - description: Web server for all HTTP requests
          port: 80
          protocol: tcp
        - description: Web server for all HTTPS requests
          port: 443
          protocol: tcp
      services:
        - description: Web server which reverse-proxies PlanktoScope web services
          tags: [caddy-docker-proxy]
          port: 80
          protocol: http
        - description: Reverse-proxy web server which provides TLS termination to PlanktoScope web services
          tags: [caddy-docker-proxy]
          port: 443
          protocol: https
```

The file has four sections: `package`, `host` (an optional section), `deployment` (a required section), and `features` (an optional section).

### `package` section

This section of the `pallet-package.yml` file contains some basic metadata to help describe and identify the package. Here is an example of a `package` section:

```yaml
package:
  description: MQTT broker ambiently provided by the PlanktoScope
  maintainers:
    - name: Ethan Li
      email: lietk12@gmail.com
  license: (EPL-2.0 OR BSD-3-Clause)
  sources:
    - https://github.com/eclipse/mosquitto
```

#### `description` field
This field of the `package` section is a short (one-sentence) description of the package to be shown to users.
- This field is required.
- Example:
  ```yaml
  description: Web GUI for operating the PlanktoScope
  ```

#### `maintainers` field
This field of the `package` section is an array of maintainer objects listing the people who maintain the Pallet package.
- This field is optional.
- In most cases, the maintainers of the Pallet package will be different from the maintainers of the original software applications provided by the Pallet package. The maintainers of the Pallet package are specifically the people responsible for maintaining the software configurations specified by the Pallet package.
- Example:
  ```yaml
  maintainers:
    - name: Ethan Li
      email: lietk12@gmail.com
    - name: Thibaut Pollina
  ```

A maintainer object consists of the following fields:
- `name` is a string with the maintainer's name.
  - This field is optional.
  - Example:
    ```yaml
    name: Ethan Li
    ```

- `email` is a string with an email address for contacting the maintainer.
  - This field is optional.
  - Example:
    ```yaml
    email: lietk12@gmail.com
    ```

#### `license` field
This field of the `package` section is an [SPDX 2.1 license expression](https://spdx.github.io/spdx-spec/v2-draft/SPDX-license-expressions/) specifying the software license terms which the software is released under. These license terms are for the software provided by the Pallet package.
- This field is optional.
- Usually, an SPDX license name will be sufficient; however, some software applications are released under multiple licenses, in which case a more complex SPDX license expression (such as `MIT OR Apache-2.0`) is needed.
- If a package is using a nonstandard license, then the `license-file` field may be specified in lieu of the `license` field.
- Example:
  ```yaml
  license: GPL-3.0
  ```

#### `license-file` field
This field of the `package` section is the filename of a license file describing the licensing terms of the software provided by the Pallet package.
- This field is optional.
- The file must be a text file.
- The file must be located in the same directory as the `pallet-package.yml` file.
- Example:
  ```yaml
  license-file: LICENSE-ZeroTier-BSL
  ```

#### `sources` field
This field of the `package` section is an array of URLs which can be opened to access the source code for the software provided by the Pallet package.
- This field is optional.
- Example:
  ```yaml
  sources:
    - https://github.com/zerotier/ZeroTierOne
    - https://github.com/sargassum-world/docker-zerotier-controller
  ```

### `host` section

This optional section of the `pallet-package.yml` file describes any relevant resources already ambiently provided by the Docker host. Such resources will exist whether or not the package is deployed; specifying resources in this section provides necessary information for checking [package resource constraints](#package-resource-constraints). Here is an example of a `host` section:

```yaml
host:
  tags:
    - device-portal-name=Cockpit (direct-access fallback)
    - device-portal-description=Provides fallback access to the Cockpit application, accessible even if the system's service proxy stops working
    - device-portal-type=Browser applications
    - device-portal-purpose=System recovery
    - device-portal-entrypoint=/admin/cockpit/
  provides:
    listeners:
      - description: Web server for the Cockpit dashboard
        port: 9090
        protocol: tcp
    services:
      - description: The Cockpit system administration dashboard
        port: 9090
        protocol: http
        paths:
          - /admin/cockpit/*
```

#### `tags` field
This field of the `host` section is an array of strings to associate with resources provided by the host. These tags have no semantic meaning within the Pallet package specification, but can be used by other applications for arbitrary purposes.
- This field is optional.
- Example:
  ```yaml
  tags:
    - device-portal-name=SSH server
    - device-portal-description=Provides SSH access to the PlanktoScope on port 22
    - device-portal-type=System infrastructure
    - device-portal-purpose=Networking
    - systemd-service=sshd.service
    - config-file=/etc/ssh/sshd_config
    - system
    - networking
    - remote-access
  ```

#### `provides` subsection

This optional subsection of the `host` section specifies the resources ambiently provided by the Docker host. Here is an example of a `provides` section:

```yaml
provides:
  listeners:
    - description: SSH server
      port: 22
      protocol: tcp
  services:
    - description: SSH server
      tags: [sshd]
      port: 22
      protocol: ssh
```

##### `listeners` field

This field of the `provides` subsection is an array of host port listener objects listing the network port/protocol pairs which are already bound to host processes which are running on the Docker host and listening for incoming traffic on those port/protocol pairs, on any/all IP addresses.
- This field is optional.
- Each host port listener object describes a host port listener resource which may or may not be in conflict with other host port listener resources; this is because multiple processes are not allowed to simultaneously bind to the same port/protocol pair on all IP addresses.
- If a set of Pallet package deployments contains two or more host port listener resources for the same port/protocol pair from different Pallet package deployments, the package deployments declaring those respective host port listeners will be reported as conflicting with each other. Therefore, the overall set of Pallet package deployments will not be allowed because its [package resource constraints](#package-resource-constraints) for uniqueness of host port listener resources will not be satisfied.
- Currently, this specification does not allow multiple host port listeners to bind to the same port/protocol pair on different IP addresses; instead for simplicity, processes are assumed to be listening for that port/protocol pair on *all* IP addresses on the host.
- Example:
  ```yaml
  listeners:
    - description: ZeroTier traffic to the rest of the world
      port: 9993
      protocol: udp
    - description: ZeroTier API for control from the ZeroTier UI and the ZeroTier CLI
      port: 9993
      protocol: tcp
  ```

A host port listener object consists of the following fields:
- `description` is a short (one-sentence) description of the host port listener resource to be shown to users.
  - This field is required.
  - Example:
    ```yaml
    description: Web server for the Cockpit dashboard
    ```

- `port` is a number specifying the [network port](https://en.wikipedia.org/wiki/Port_(computer_networking)) bound by a process running on the host.
  - This field is required.
  - Example:
    ```yaml
    port: 9090
    ```

- `protocol` is a string specifying whether the bound network port is for the TCP transport protocol or for the UDP transport protocol.
  - This field is required.
  - The value of this field must be either `tcp` or `udp`.
  - Example:
    ```yaml
    protocol: tcp
    ```

##### `networks` field

This field of the `provides` subsection is an array of host Docker network objects listing the Docker networks which are already available on the Docker host.
- This field is optional.
- Each host Docker network object describes a Docker network resource which may or may not be in conflict with other Docker network resources; this is because multiple Docker networks are not allowed to have the same name.
- If a set of Pallet package deployments contains two or more Docker network resources for networks with the same name from different Pallet package deployments, the package deployments declaring those respective Docker networks will be reported as conflicting with each other. Therefore, the overall set of Pallet package deployments will not be allowed because its [package resource constraints](#package-resource-constraints) for uniqueness of host Docker network names will not be satisfied.
- Example:
  ```yaml
  networks:
    - description: Default bridge to the host
      name: bridge
  ```

A Docker network object consists of the following fields:
- `description` is a short (one-sentence) description of the Docker network resource to be shown to users.
  - This field is required.
  - Example:
    ```yaml
    description: Default host network
    ```

- `name` is a string specifying the name of the Docker network.
  - This field is required.
  - Example:
    ```yaml
    name: host
    ```

##### `services` field

This field of the `provides` subsection is an array of network service objects listing the network services which are already available on the Docker host.
- This field is optional.
- The route of a network service can be defined either as a port/protocol pair or as a combination of port, protocol, and one or more paths. A network service whose route is defined only as a port/protocol pair will overlap with another network service if and only if the other network service whose route is also defined only as a port/protocol pair. A network service whose route is defined with one or more paths will overlap with another network service if and only if both network services have the same port, the same protocol, and at least one overlapping path (for a definition of overlapping paths, refer below to description of the `path` field of the network service object).
- Each host network service object describes a network service resource which may or may not be in conflict with other network service resources; this is because multiple networks are not allowed to have overlapping routes.
- If a set of Pallet package deployments contains two or more network service resources for services with overlapping routes from different Pallet package deployments, then the package deployments declaring those respective network services will be reported as conflicting with each other. Therefore, the overall set of Pallet package deployments will not be allowed because its [package resource constraints](#package-resource-constraints) for uniqueness of network services will not be satisfied.
- Example:
  ```yaml
  services:
    - description: SSH server
      port: 22
      protocol: ssh
  ```

A network service object consists of the following fields:
- `description` is a short (one-sentence) description of the network service resource to be shown to users.
  - This field is required.
  - Example:
    ```yaml
    description: The Cockpit system administration dashboard
    ```

- `port` is a number specifying the network port used for accessing the service.
  - This field is required.
  - Example:
    ```yaml
    port: 9090
    ```

- `protocol` is a string specifying the application-level protocol used for accessing the service.
  - This field is required.
  - Example:
    ```yaml
    protocol: https
    ```

- `tags` is an array of strings which constrain resolution of network service resource dependencies among package deployments. These tags are ignored in determining whether network services conflict with each other, since they are not part of the network service's route.
  - This field is optional.
  - Tags can be used to annotate a network service with information about API versions, subprotocols, etc. If a package deployment specifies that it requires a network service with one or more tags, then another package deployment will only be considered to satisfy the network service dependency if it provides a network service matching both the required route and all required tags. This is useful in ensuring that a network service provided by one package deployment is compatible with the API version required by a service client from another package deployment, for example.
  - Example:
    ```yaml
    tags:
      - https-only
      - tls-client-certs-required
    ```

- `paths` is an array of strings which are paths used for accessing the service.
  - This field is optional.
  - A path may optionally have an asterisk (`*`) at the end, in which case it is a prefix path - so the network service covers all paths beginning with that prefix (i.e. the string before the asterisk).
  - If a network service specifies a port and protocol but no paths, it will conflict with another network service which also specifies the same port and protocol but no paths. It will not conflict with another network service which specifies the same port and protocol, but also specifies some paths. This is useful for describing systems involving HTTP reverse-proxies and message brokers, where one package deployment may provide a network service which routes specific messages to network services from other package deployments on specific paths; then the reverse-proxy or message broker would be specified on some port and protocol with no paths, while the network services behind it would be specified on the same port and protocol but with a set of specific paths.
  - If a package deployment has a dependency on a network service with a specific path which matches a prefix path in a network service from another package deployment, that dependency will be satisfied. For example, a dependency on a network service requiring a path `/admin/cockpit/system` would be met by a network service provded with the path prefix `/admin/cockpit/*`, assuming they have the same port and protocol.
  - If a package deployment provides a network service with a specific path which matches a prefix path in a network service provided by another package deployment, those two package deployments will be in conflict with each other. For example, a network service providing a path `/admin/cockpit/system` would conflict with a network service providing the path prefix `/admin/cockpit/*`, assuming they have the same port and protocol. This is because those overlapping paths would cause the network services to overlap with each other, which is not allowed.
  - Example:
    ```yaml
    paths:
      - /admin/cockpit/*
    ```

### `deployment` section

This optional section of the `pallet-package.yml` file specifies the Docker stack definition file provided by the package, as well as any resources required for deployment of the package to succeed and any resources provided by deployment of the package. If required resources are not met, the deployment will not be allowed; resources provided by deployment of the package will only exist once the package deployment is successfully applied. Here is an example of a `deployment` section:

```yaml
deployment:
  definition-file: docker-stack.yml
  provides:
    networks:
      - description: Overlay network for the Portainer server to connect to Portainer agents
        name: portainer-agent
```

#### `definition-file` field
This field of the `deployment` section is the filename of a Docker stack definition file specifying the Docker stack which will be deployed when the package is deployed.
- This field is optional.
- The file must be a YAML file following the [Docker Compose file specification](https://docs.docker.com/compose/compose-file/).
- The file must be located in the same directory as the `pallet-package.yml` file.
- It only makes sense to omit the Docker stack definition file from a package if the package also specifies some host resources in the `host` section of the `pallet-package.yml` file; otherwise, the package would do nothing and have no effect.
- Example:
  ```yaml
  definition-file: docker-stack.yml
  ```

#### `tags` field
This field of the `deployment` section is an array of strings to associate with resources provided by the package deployment. These tags have no semantic meaning within the Pallet package specification, but can be used by other applications for arbitrary purposes.
- This field is optional.
- Example:
  ```yaml
  tags:
    - remote-access
  ```
  - This field is required.
  - Example:
    ```yaml
    port: 9090
    ```

- `protocol` is a string specifying the application-level protocol used for accessing the service.
  - This field is required.
  - Example:
    ```yaml
    protocol: https
    ```

- `paths` is an array of strings which are paths used for accessing the service.
  - This field is optional.
  - A path may optionally have an asterisk (`*`) at the end, in which case it is a prefix path - so the network service covers all paths beginning with that prefix (i.e. the string before the asterisk).
  - If a network service specifies a port and protocol but no paths, it will conflict with another network service which also specifies the same port and protocol but no paths. It will not conflict with another network service which specifies the same port protocol, but also specifies some paths. This is useful for describing systems involving HTTP reverse-proxies and message brokers, where one package deployment may provide a network service which routes specific messages to network services from other package deployments on specific paths; then the reverse-proxy or message broker would be specified on some port and protocol with no paths, while the network services behind it would be specified on the same port and protocol but with a set of specific paths.
  - If a package deployment has a dependency on a network service with a specific path which matches a prefix path in a network service from another package deployment, that dependency will be satisfied. For example, a dependency on a network service requiring a path `/admin/cockpit/system` would be met by a network service provded with the path prefix `/admin/cockpit/*`, assuming they have the same port and protocol.
  - If a package deployment provides a network service with a specific path which matches a prefix path in a network service provided by another package deployment, those two package deployments will be in conflict with each other. For example, a network service providing a path `/admin/cockpit/system` would conflict with a network service providing the path prefix `/admin/cockpit/*`, assuming they have the same port and protocol. This is because those overlapping paths would cause the network services to overlap with each other, which is not allowed.
  - Example:
    ```yaml
    paths:
      - /admin/cockpit/*
    ```

### `deployment` section

TODO

### `features` section

TODO
