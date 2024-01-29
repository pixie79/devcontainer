FROM mcr.microsoft.com/devcontainers/universal:latest

ENV DEBIAN_FRONTEND noninteractive

# Update package lists and install necessary packages
RUN apt-get update -yqq && \
    apt-get install -y \
      curl \
      expect \
      git \
      make \
      wget \
      unzip \
      vim \
      openssh-client \
      locales \
      libarchive-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the locale to en_GB.UTF-8
RUN localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8


# Set the system language to GB English
ENV LANG en_GB.UTF-8

ENTRYPOINT ["/usr/bin/zsh"]
