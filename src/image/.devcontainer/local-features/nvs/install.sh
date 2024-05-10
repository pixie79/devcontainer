#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

USERNAME=${USERNAME:-"codespace"}
NVS_HOME=${NVS_HOME:-"/usr/local/nvs"}

set -eux

ID=$(id -u)
if [[ ${ID} -ne 0 ]]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
PATHSWITCH=$(sh -lc 'echo $PATH')
echo "export PATH=${PATH//${PATHSWITCH}/\$PATH}" >/etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Function to run apt-get if needed
apt_get_update_if_needed() {
    FIND_APT_FILES=$(find /var/lib/apt/lists/ -mindepth 1 -maxdepth 1)
    COUNT_APT_FILES=$(echo -n"${FIND_APT_FILES}" | wc -l)
    if [[ ! -d "/var/lib/apt/lists" ]] || [[ $((COUNT_APT_FILES)) -eq 0 ]]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

updaterc() {
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [[ "$(cat /etc/bash.bashrc || true)" != *"$1"* ]]; then
        echo -e "$1" >>/etc/bash.bashrc
    fi
    if [[ -f "/etc/zsh/zshrc" ]] && [[ "$(cat /etc/zsh/zshrc || true)" != *"$1"* ]]; then
        echo -e "$1" >>/etc/zsh/zshrc
    fi
}

export DEBIAN_FRONTEND=noninteractive

GROUPLIST=$(cat /etc/group)
if ! echo "${GROUPLIST}" | grep -e "^nvs:" >/dev/null 2>&1; then
    groupadd -r nvs
fi
usermod -a -G nvs "${USERNAME}"

git config --global --add safe.directory "${NVS_HOME}"
mkdir -p "${NVS_HOME}"

git clone -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs "${NVS_HOME}" 2>&1
GITLOG=$(git log -n 1 --pretty=format:%H -- .)
(cd "${NVS_HOME}" && git remote get-url origin && echo "${GITLOG}") >"${NVS_HOME}"/.git-remote-and-commit
bash "${NVS_HOME}"/nvs.sh install
rm "${NVS_HOME}"/cache/*

# Clean up
rm -rf "${NVS_HOME}"/.git

updaterc "if [[ \"\${PATH}\" != *\"${NVS_HOME}\"* ]]; then export PATH=${NVS_HOME}:\${PATH}; fi"

chown -R "${USERNAME}:nvs" "${NVS_HOME}"
chmod -R g+r+w "${NVS_HOME}"
find "${NVS_HOME}" -type d -exec chmod g+s {} \;

NVS="/home/codespace/.nvs"
mkdir -p "${NVS}"
ln -snf "${NVS_HOME}"/* "${NVS}"

echo "Done!"
