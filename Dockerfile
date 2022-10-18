FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="true"
# [Option] Engine/CLI Version
ARG DOCKER_VERSION="latest"

ARG NODE_VERSION="16"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}

ENV DOCKER_BUILDKIT=1

ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# https://github.com/devcontainers/features

RUN git clone https://github.com/devcontainers/features /tmp/features

ENV NONFREEPACKAGES=true
ENV UID=1000
ENV GID=1000
RUN bash /tmp/features/src/common-utils/install.sh

RUN bash /tmp/features/src/node/install.sh

RUN bash /tmp/features/src/docker-in-docker/install.sh

RUN bash /tmp/features/src/github-cli/install.sh

RUN bash /tmp/features/src/terraform/install.sh

RUN bash /tmp/features/src/go/install.sh

ENV OPTIMIZE=true
RUN bash /tmp/features/src/python/install.sh

COPY setup.sh /tmp/
RUN /bin/bash /tmp/setup.sh

VOLUME [ "/var/lib/docker" ]

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

