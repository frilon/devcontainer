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
TERRAFORM_VERSION="1.2.2"
GHCLI_VERSION="latest"

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
        gnupg \
        pwgen \
        software-properties-common \
        redis-tools \
        dos2unix \
        bash-completion \
        lsb-release \
        ca-certificates \
        iputils-ping \
        python3-distutils
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
    sudo cp "/tmp/shellcheck-${SHELLCHECK_VERSION}/shellcheck" "/usr/local/bin/"
    sudo chmod +x "/usr/local/bin/shellcheck"
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
    sudo /tmp/awscliv2/aws/install
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
    sudo /tmp/sam-installation/install
}

function install_session_manager {
    curl -sL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
        -o "/tmp/session-manager-plugin.deb"
    sudo dpkg -i "/tmp/session-manager-plugin.deb"
}

function install_gossm {
    GH_ORG="gjbae1212"
    GH_REPO="gossm"
    if [[ "${GOSSM_VERSION}" = "latest" ]]; then
        GOSSM_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="gossm_${GOSSM_VERSION}_Linux_x86_64.tar.gz"
    curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/v${GOSSM_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/tmp/${DOWNLOAD_FILENAME}"
    tar -xf "/tmp/${DOWNLOAD_FILENAME}" -C /tmp/
    sudo mv "/tmp/gossm" "/usr/local/bin/"
    sudo chmod +x "/usr/local/bin/gossm"
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
    DOWNLOAD_FILENAME="shfmt_v${SHFMT_VERSION}_linux_amd64"
    sudo curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/v${GOSSM_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/usr/local/bin/shfmt"
    sudo chmod +x "/usr/local/bin/shfmt"
}

function install_terraform {
    GH_ORG="hashicorp"
    GH_REPO="terraform"
    if [[ "${TERRAFORM_VERSION}" = "latest" ]]; then
        TERRAFORM_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

    curl -sL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${DOWNLOAD_FILENAME}" \
        -o "/tmp/${DOWNLOAD_FILENAME}"
    sudo unzip -q "/tmp/${DOWNLOAD_FILENAME}" -d "/usr/local/bin/"
    sudo chmod +x "/usr/local/bin/terraform"
    # terraform -install-autocomplete # already in bashrc
}

function install_ghcli {
    GH_ORG="cli"
    GH_REPO="cli"
    if [[ "${GHCLI_VERSION}" = "latest" ]]; then
        GHCLI_VERSION="$(get_latest_github_release_version)"
    fi
    DOWNLOAD_FILENAME="gh_${GHCLI_VERSION}_linux_amd64.deb"

    sudo curl -sL \
        "https://github.com/${GH_ORG}/${GH_REPO}/releases/download/${GOSSM_VERSION}/${DOWNLOAD_FILENAME}" \
        -o /tmp/gh_"${GHCLI_VERSION}"_linux_amd64.deb
    dpkg -i /tmp/gh_"${GHCLI_VERSION}"_linux_amd64.deb
}

# function install_bashhub {
#     curl -OL https://raw.githubusercontent.com/yggdrion/bashhub-client/main/install-bashhub.sh && bash install-bashhub.sh non-interactive
# }

install_packages
install_shfmt
install_terraform
install_aws_cli
install_shellcheck
install_aws_sam
install_gossm
install_trivy
install_ghcli
install_session_manager
#install_bashhub
pip install cfn-lint

rm -rf /tmp/*
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/library-scripts/
