# Prerequisites

Ready to dive into Kubepak? Before you start, let's ensure you have the right tools in place. Whether you're a developer
contributing to Kubepak or just getting started, we've got two options: manual installation or the convenient Docker
image.

## Manual Installation

This option gives you more control and is ideal for developers actively working on Kubepak. Make sure you have these
packages installed on your Linux system:

* `Essential`: curl, docker-buildx, docker.io, git, jq, mysql-client, openssh-client, postgresql-client
* `Additional Tools`:
  - Install [`awscli`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - Install [`az`](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  - Install [`helm`](https://helm.sh/docs/intro/install/)
  - Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
  - Install [`mongosh`](https://www.mongodb.com/try/download/shell)
  - Install [`vault`](https://www.vaultproject.io/downloads)
  - Install [`yq`](https://github.com/mikefarah/yq/#install)

Follow the linked instructions for each tool to install them correctly.

## Docker Image

Want a quick and easy setup? Skip the manual installation and use the pre-built Kubepak Docker image. If you don't have
it already, build your own image with this command:

```bash
docker build -t "kubepak" .
```

Verify the image is built successfully by running:

```bash
docker run kubepak --help
```

If everything is good, you should see the Kubepak help message!
