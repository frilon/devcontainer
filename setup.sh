#!/bin/bash

# tldr
# gossm
# vimrc
# historysync

# If you want to use a specific version, set the version number here.
# Otherwise, set the variable to 'latest'
SHELLCHECK_VERSION="latest"
AWS_CLI_VERSION="latest"
AWS_SAM_CLI_VERSION="latest"
GOSSM_VERSION="latest"
SHFMT_VERSION="latest"
TRIVY_VERSION="0.27.1"

export DEBIAN_FRONTEND=noninteractive

function install_packages {

    apt-get update
    apt-get -y install --no-install-recommends \
        netcat \
        vim \
        htop \
        zip unzip \
        git \
        curl \
        wget \
        jq \
        jo \
        xz-utils \
        file \
        gnupg2 \
        pwgen \
        uuid-runtime \
        software-properties-common \
        redis-tools \
        dos2unix \
        bash-completion \
        lsb-release \
        ca-certificates \
        iputils-ping \
        python3-distutils \
        m4
}

function get_latest_github_release_version() {
    curl -s "https://api.github.com/repos/${GH_ORG}/${GH_REPO}/releases/latest" | jq -r '.tag_name'
}

function install_shellcheck {
    GH_ORG="koalaman"
    GH_REPO="shellcheck"
    if [[ "${SHELLCHECK_VERSION}" = "latest" ]]; then
        SHELLCHECK_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
    curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/${SHELLCHECK_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/tmp/${DOWNLOAD_FILENAME}"
    tar -xf "/tmp/${DOWNLOAD_FILENAME}" -C "/tmp/"
    cp "/tmp/shellcheck-${SHELLCHECK_VERSION}/shellcheck" "/usr/local/bin/"
    chmod +x "/usr/local/bin/shellcheck"
}

function install_aws_cli {
    GH_ORG="aws"
    GH_REPO="aws-cli"
    if [[ "${AWS_CLI_VERSION}" = "latest" ]]; then
        AWS_CLI_VERSION=$(curl -s https://api.github.com/repos/aws/aws-cli/tags | jq -r '.[].name' | sort -V | tail -n1)
    fi
    DOWNLOAD_FILENAME="awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"

    curl -sL \
        "https://awscli.amazonaws.com/${DOWNLOAD_FILENAME}" \
        -o "/tmp/awscliv2.zip"
    unzip -q "/tmp/awscliv2.zip" -d "/tmp/awscliv2"
    /tmp/awscliv2/aws/install
}

function install_aws_sam {
    GH_ORG="aws"
    GH_REPO="aws-sam-cli"
    if [[ "${AWS_SAM_CLI_VERSION}" = "latest" ]]; then
        AWS_SAM_CLI_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="aws-sam-cli-linux-x86_64.zip"

    curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/${AWS_SAM_CLI_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/tmp/${DOWNLOAD_FILENAME}"
    unzip -q "/tmp/${DOWNLOAD_FILENAME}" -d "/tmp/sam-installation"
    /tmp/sam-installation/install
}

function install_session_manager {
    curl -sL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
        -o "/tmp/session-manager-plugin.deb"
    dpkg -i "/tmp/session-manager-plugin.deb"
}

function install_gossm {
    GH_ORG="gjbae1212"
    GH_REPO="gossm"
    if [[ "${GOSSM_VERSION}" = "latest" ]]; then
        GOSSM_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="gossm_${GOSSM_VERSION/v/}_Linux_x86_64.tar.gz"
    curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/${GOSSM_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/tmp/${DOWNLOAD_FILENAME}"
    tar -xf "/tmp/${DOWNLOAD_FILENAME}" -C /tmp/
    mv "/tmp/gossm" "/usr/local/bin/"
    chmod +x "/usr/local/bin/gossm"
}

function install_trivy {

    curl -sL https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb -o /tmp/trivy_${TRIVY_VERSION}_Linux-64bit.deb
    dpkg -i /tmp/trivy_${TRIVY_VERSION}_Linux-64bit.deb

}

function install_shfmt {
    GH_ORG="mvdan"
    GH_REPO="sh"
    if [[ "${SHFMT_VERSION}" = "latest" ]]; then
        SHFMT_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="shfmt_${SHFMT_VERSION}_linux_amd64"
    curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/${SHFMT_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/usr/local/bin/shfmt"
    chmod +x "/usr/local/bin/shfmt"
}

install_packages
install_shfmt
install_aws_cli
install_shellcheck
install_aws_sam
install_gossm
install_trivy
install_session_manager

pip install cfn-lint
