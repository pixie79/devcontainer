#!/usr/bin/env bash
## This script is intended to be run inside a devcontainer within a checked out trunk repo
set -e
unset LC_CTYPE

sudo sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen

echo "PATH=${PWD}/.trunk/tools/:${HOME}/.local/bin:/home/codespaces/venv/bin:$PATH" >>~/.zshrc
echo "WORKSPACE=${PWD}" >>~/.zshrc

if [[ -f /home/codespace/requirements.txt ]]; then
    python3 -m venv /home/codespace/venv
    source /home/codespace/venv/bin/activate
    python3.11 -m pip --disable-pip-version-check --no-cache-dir install -r /home/codespace/requirements.txt
fi

if [[ -d ${PWD}/.env ]]; then
    source .env
    echo "source ${WORKSPACE}/.env" >>~/.zshrc
fi

if [[ -d ${PWD}/.venv ]]; then
    echo "source ${PWD}/.venv/bin/activate" >>~/.zshrc
fi

if [[ -d ${PWD}/.git ]]; then
    sudo chown ${USER}:${USER} ${PWD}/.git
fi

if [[ -f ${PWD}/.trunk/trunk.yaml ]]; then
    trunk install
    trunk upgrade
    /usr/local/bin/update-trunk-simlinks.sh
fi

if [[ -f ${PWD}/commitlint.config.js ]]; then
    commitizen init cz-conventional-changelog --save-dev --save-exact --force
fi

if [[ -f ${PWD}/pyproject.toml ]]; then
    poetry config virtualenvs.in-project true
    poetry config virtualenvs.path ".venv"
    poetry install
fi

echo "please restart your ZSH Shell"
echo "install rpk, tfupdate"