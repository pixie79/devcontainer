#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

USERNAME=${USERNAME:-"codespace"}

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

export DEBIAN_FRONTEND=noninteractive

sudo_if() {
    COMMAND="$*"
    if [[ ${ID} -eq 0 ]] && [[ ${USERNAME} != "root" ]]; then
        su - "${USERNAME}" -c "${COMMAND}"
    else
        "${COMMAND}"
    fi
}

NODE_PATH="/home/codespace/nvm/current"
ln -snf /usr/local/share/nvm /home/codespace

PYTHON_PATH="/home/${USERNAME}/.python/current"
mkdir -p /home/"${USERNAME}"/.python
ln -snf /usr/local/python/current "${PYTHON_PATH}"
ln -snf /usr/local/python /opt/python

JAVA_PATH="/home/codespace/java/current"
ln -snf /usr/local/sdkman/candidates/java /home/codespace

DOTNET_PATH="/home/${USERNAME}/.dotnet"

# Required due to https://github.com/devcontainers/features/pull/628/files#r1276659825
chown -R "${USERNAME}:${USERNAME}" /usr/share/dotnet
chmod g+r+w+s /usr/share/dotnet
chmod -R g+r+w /usr/share/dotnet

ln -snf /usr/share/dotnet "${DOTNET_PATH}"
mkdir -p /opt/dotnet/lts
cp -R /usr/share/dotnet/dotnet /opt/dotnet/lts
cp -R /usr/share/dotnet/LICENSE.txt /opt/dotnet/lts
cp -R /usr/share/dotnet/ThirdPartyNotices.txt /opt/dotnet/lts

MAVEN_PATH="/home/${USERNAME}/.maven/current"
mkdir -p /home/"${USERNAME}"/.maven
ln -snf /usr/local/sdkman/candidates/maven/current "${MAVEN_PATH}"

HUGO_ROOT="/home/${USERNAME}/.hugo/current"
mkdir -p /home/"${USERNAME}"/.hugo
ln -snf /usr/local/hugo "${HUGO_ROOT}"

HOME_DIR="/home/${USERNAME}/"
chown -R "${USERNAME}":"${USERNAME}" "${HOME_DIR}"
chmod -R g+r+w "${HOME_DIR}"
find "${HOME_DIR}" -type d -exec chmod g+s {} \;

echo "Defaults secure_path=\"${DOTNET_PATH}:${NODE_PATH}/bin:${PYTHON_PATH}/bin:${JAVA_PATH}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:/usr/local/share:/home/${USERNAME}/.local/bin:${PATH}\"" >>/etc/sudoers.d/"${USERNAME}"

# Temporary: Due to GHSA-c2qf-rxjj-qqgw
bash -c ". /usr/local/share/nvm/nvm.sh && nvm use 18"
bash -c "npm -g install -g npm@9.8.1"
bash -c ". /usr/local/share/nvm/nvm.sh && nvm use stable"

echo "Done!"
