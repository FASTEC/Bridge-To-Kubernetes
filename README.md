
# Bridge to Kubernetes

[![CI Status](https://github.com/go1com/Bridge-To-Kubernetes/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/go1com/Bridge-To-Kubernetes/actions/workflows/ci.yml)

## Maintainers

This (forked) repository is being maintained by Go1. [Microsoft made the decision to no longer actively maintain the project](https://github.com/Azure/Bridge-To-Kubernetes/blob/fec6f302cf821bb0e958084c7d607dac0ba8888d/README.md).

## A simple history

Microsoft had maintained this repository, in addition to a separate repository for [a VSCode extension](https://github.com/Azure/vscode-bridge-to-kubernetes).

This repository builds out [a CLI tool](https://github.com/Azure/Bridge-To-Kubernetes/blob/fec6f302cf821bb0e958084c7d607dac0ba8888d/README.md?plain=1#L37), which as far as Go1 could tell, was never actively championed by Microsoft in favor of the [VSCode extension](https://github.com/Azure/vscode-bridge-to-kubernetes). It also builds out the Docker images used for deployment into the Kubernetes cluster when using the service.

Go1 has made the decision to actively maintain the [CLI tool](https://github.com/Azure/Bridge-To-Kubernetes/blob/fec6f302cf821bb0e958084c7d607dac0ba8888d/README.md?plain=1#L37), but not the [VSCode extension](https://github.com/Azure/vscode-bridge-to-kubernetes). The reason for this is:

- we continually experienced issues with the [VSCode extension](https://github.com/Azure/vscode-bridge-to-kubernetes) not shutting down resources in Kubernetes properly
- the [VSCode extension](https://github.com/Azure/vscode-bridge-to-kubernetes) would do stuff like try to manage a local dotnet and kubectl installs, which added unnecesary complexity and caused issues (e.g. kubectl version and kubelet versions out of sync > 3 versions)
- it simply abstracted away the underlying [a CLI tool](https://github.com/Azure/Bridge-To-Kubernetes/blob/fec6f302cf821bb0e958084c7d607dac0ba8888d/README.md?plain=1#L37) anyway, which seemed to be more robust.

## Key changes in the Go1 fork

- The Docker images are now maintained in our DockerHub registry
    - [go1com/routingmanager](https://hub.docker.com/r/go1com/routingmanager)
    - [go1com/lpkrestorationjob](https://hub.docker.com/r/go1com/lpkrestorationjob)
    - [go1com/lpkremoteagent](https://hub.docker.com/r/go1com/lpkremoteagent)
- The CLI tool and Docker images have been upgraded from .NET 7 to [.NET 8, the current active LTS version](https://versionsof.net/)
- The CLI tool is only built using `--self-contained true`, so users do not need a local dotnet installation.
- The install scripts have been updated to remove the management of dependencies. Users need kubectl ready on their system. An install script for Windows was added.
    - [install.sh](./scripts/install.sh)
    - [install.ps1](./scripts/install.ps1)
- The install scripts will pull down a simple wrapper around dsc(.exe), which is installed into the system path as `b2k`. This wrapper prompts for service, namespace and ports to expose. There is absolutely no obligation to use this, its just a nice wrapper that we like to use at Go1.
    - [b2k.sh](./scripts/b2k.sh)
    - [b2k.ps1](./scripts/b2k.ps1)

## CLI tool installation

[Release version](https://github.com/go1com/Bridge-To-Kubernetes/releases) is explicitly required at this time (we may implicitly update this to use the latest release at a later date).

Examples below.

### Linux / MacOS / WSL
```bash
curl -fsSL https://raw.githubusercontent.com/go1com/Bridge-To-Kubernetes/main/scripts/install.sh | bash -s -- 2.2025.0103.0242
```

### Windows
Use the [install.ps1](./scripts/install.ps1) script:

```powershell
install.ps1 2.2025.0103.0242
```

## CLI usage - dsc

```bash
dsc connect \
    --service ${SVC} \
    --routing ${ROUTING} \
    --namespace ${NS} \
    --local-port ${PORT} \
    --use-kubernetes-service-environment-variables
```

Where:
- `service` is the name of the service you want to connect to
- `routing` is a way of isolating the traffic. This is important for ensuring your running service does not interrupt cluster traffic, but can still reach out to other services as if it was in the cluster itself.
- `namespace` is the namespace in the K8s cluster
- `local-port` is the port your local service is going to run on. Its important to note that a K8s `Service` may have [multiple ports specified](https://kubernetes.io/docs/concepts/services-networking/service/#multi-port-services).
    - Ports will be assigned top to bottom from the deployed `Service`
    - Multiple ports can be opened locally with multiple `--local-port` args. E.g.: `dsc connect ... --local-port 3000 --local-port 5000`.
    - The order in which `--local-port` is specified matters, first specified maps to first declared in the K8s `Service` etc.
- `use-kubernetes-service-environment-variables` will ensure that the environment variables of the running pod are available in the local shell. Can be used with [KubernetesLocalProcessConfig.yaml](https://learn.microsoft.com/en-us/visualstudio/bridge/configure-bridge-to-kubernetes#local-configuration-using-kuberneteslocalprocessconfigyaml). We have [preserved this document as a pdf](./docs/configure-bridge-to-kubernetes.pdf) in the event that Microsoft kills it.

## CLI usage - b2k

A simple wrapper around `dsc` with a couple of prompts.

- [b2k.sh](./scripts/b2k.sh)
- [b2k.ps1](./scripts/b2k.ps1)
 
Its convenient to be able to set the `SVC`, `NS` and `PORT` in the environment before executing to skip the prompts.

## Support + Contributions

Go1 forked this because we find it useful developing against our microservice architecture. We will support the best we can. Contributors welcome.
