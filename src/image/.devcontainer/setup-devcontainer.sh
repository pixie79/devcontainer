#!/usr/bin/env bash
## This script is intended to be run inside a devcontainer within a checked out trunk repo
set -e

echo "PATH=${PWD}/.trunk/tools/:${HOME}/.local/bin:$PATH" >>~/.zshrc
echo "WORKSPACE=${PWD}" >>~/.zshrc

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
