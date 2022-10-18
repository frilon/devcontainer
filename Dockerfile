FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

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

RUN rm -rf /tmp/* /var/lib/apt/lists/* ; apt-get autoremove -y ; apt-get clean -y

VOLUME [ "/var/lib/docker" ]

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

