#!/usr/bin/env bash
## This script is intended to be run inside a devcontainer within a checked out trunk repo
set -e
unset LC_CTYPE

sudo sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen

echo "PATH=${PWD}/.trunk/tools/:${HOME}/.local/bin:/home/codespace/venv/bin:${PATH}" >>~/.zshrc
echo "WORKSPACE=${PWD}" >>~/.zshrc

ARCH=$(dpkg --print-architecture)

if [[ -f /home/codespace/requirements.txt ]]; then
    python3 -m venv /home/codespace/venv
    source /home/codespace/venv/bin/activate # trunk-ignore(shellcheck/SC1091)
    python3.11 -m pip --disable-pip-version-check --no-cache-dir install -r /home/codespace/requirements.txt
fi

if [[ -f /home/codespace/requirements-data.txt ]]; then
    case "${DATA,,}" in
    "true" | "t")
        echo "Installing Python3 data tools."
        python3 -m venv /home/codespace/venv
        source /home/codespace/venv/bin/activate # trunk-ignore(shellcheck/SC1091)
        python3.11 -m pip --disable-pip-version-check --no-cache-dir install -r /home/codespace/requirements-data.txt
        ;;
    *)
        echo "Not installing Python3 data tools as DATA is not set to TRUE"
        ;;
    esac
fi

if [[ -d ${PWD}/.env ]]; then
    source .env
    echo "source ${WORKSPACE}/.env" >>~/.zshrc
fi

if [[ -d ${PWD}/.venv ]]; then
    echo "source ${PWD}/.venv/bin/activate" >>~/.zshrc
fi

if [[ -d ${PWD}/.git ]]; then
    sudo chown "${USER}":"${USER}" "${PWD}"/.git
fi

if [[ -f ${PWD}/.trunk/trunk.yaml ]]; then
    trunk install
    trunk upgrade
    /usr/local/bin/update-trunk-simlinks.sh
fi

if [[ -f ${PWD}/pyproject.toml ]]; then
    poetry config virtualenvs.in-project true
    poetry config virtualenvs.path ".venv"
    poetry install
fi

case "${RPK,,}" in
"true" | "t")
    curl -L https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-"${ARCH}".zip -o rpk-linux.zip
    unzip rpk-linux.zip
    mv rpk ~/.local/bin
    chmod +x ~/.local/bin/rpk
    rm rpk-linux.zip
    ;;
*)
    echo "Not installing Redpanda rpk as RPK is not set to TRUE"
    ;;
esac

if [[ -d ${PWD}/terraform ]]; then
    curl -L https://github.com/minamijoyo/tfupdate/releases/download/v0.8.2/tfupdate_0.8.2_linux_"${ARCH}".tar.gz -o tfupdate.tar.gz
    tar zxvf tfupdate.tar.gz tfupdate
    mv tfupdate ~/.local/bin
    rm tfupdate.tar.gz
fi

exit 0
