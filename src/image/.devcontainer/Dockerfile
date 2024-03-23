# [Choice] Ubuntu version (use jammy on local arm64/Apple Silicon): jammy
ARG VARIANT="jammy"
FROM buildpack-deps:${VARIANT}-curl

LABEL dev.containers.features="common"

ENV DEBIAN_FRONTEND noninteractive

# Update package lists and install necessary packages
RUN apt-get update -yqq && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    expect \
    git \
    gcc \
    make \
    wget \
    unzip \
    vim \
    gnupg2 \
    openssh-client \
    locales \
    zsh \
    libarchive-tools && \  
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

 RUN apt-get update -yqq && \
    apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3.11-dev \
    python3-pip \
    python-is-python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the locale to en_GB.UTF-8
RUN localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8

COPY requirements.txt /tmp/pip-tmp/
#RUN python3.11 -m pip --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
#   && rm -rf /tmp/pip-tmp

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

COPY setup-devcontainer.sh /usr/local/bin/
COPY update-trunk-simlinks.sh /usr/local/bin/
COPY zprofile /home/codespace/.zprofile
RUN chmod +x /usr/local/bin/setup-devcontainer.sh /usr/local/bin/update-trunk-simlinks.sh
RUN echo "$(date +%y-%m-%d)" > /usr/local/share/devcontainer_version

# Set the system language to GB English
ENV LANG en_GB.UTF-8

RUN ENABLE_NONROOT_DOCKER=false \
  /bin/bash \
  -c "$(curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/docker-outside-of-docker/install.sh)"

ENTRYPOINT ["/usr/bin/zsh"]
