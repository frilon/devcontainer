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

# see: https://github.com/microsoft/vscode-dev-containers/tree/main/script-library

COPY library-scripts/*.sh /tmp/library-scripts/

RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" "${DOCKER_VERSION}" \
    && if [ "${NODE_VERSION}" != "none" ]; then bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; fi \
    && apt-get autoremove -y && apt-get clean -y

ENV GOROOT=/usr/local/go \
    GOPATH=/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}
RUN apt-get update && bash /tmp/library-scripts/go-debian.sh "latest" "${GOROOT}" "${GOPATH}" && apt-get clean -y

ARG PYTHON_PATH=/usr/local/python
ENV PIPX_HOME=/usr/local/py-utils \
    PIPX_BIN_DIR=/usr/local/py-utils/bin
ENV PATH=${PYTHON_PATH}/bin:${PATH}:${PIPX_BIN_DIR}
# COPY library-scripts/python-debian.sh /tmp/library-scripts/
RUN apt-get update && bash /tmp/library-scripts/python-debian.sh "3.9" "${PYTHON_PATH}" "${PIPX_HOME}"

COPY setup.sh /tmp/
RUN /bin/bash /tmp/setup.sh

RUN rm -rf /tmp/*

VOLUME [ "/var/lib/docker" ]

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

