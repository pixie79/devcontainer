# DevContainer

DevContainer based on ultimate codespaces with extras and sample linting files

## First Time Setup

For a new project ensure the src directory is correctly set in pyproject.toml and run the following
to setup commit messages and checking

## Setting up your environment

This repository is configured with a DevContainer, it can be used either by Github Codespaces or
VSCode. It should be activated upon each use, the default shell in use is _zsh_.

Once the DevContainer is running to complete the setup run

```zsh
setup-DevContainer.sh
```

Then restart your shell to update the profile.

Additional features can be added from
([here](https://github.com/DevContainers-contrib/features/tree/main/src))

### SSH Commit Signing

To set SSH Commit Signing do the following:

```zsh
git config --global user.email "<EMAIL ADDRESS>"
git config --global user.name "<FIRSTNAME LASTNAME>"
git config --global gpg.format "ssh"
git config --global user.signingkey "ssh-rsa <SSH_KEY>"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.ssh.allowedSignersFile ".github/allowed_signers"

echo "<EMAIL ADDRESS> ssh-rsa <SSH_KEY>" >> .github/allowed_signers
```

Replace the items in '<>' with the relevant information.

### Setup AWS Configuration

#### Prompt Answers

-   SO session name (Recommended): int
<!-- trunk-ignore(markdown-link-check/0) -->
-   SSO start URL [None]: <https://pixie79.awsapps.com/start#>
-   SSO region [None]: eu-west-2
-   SSO registration scopes [sso:account:access]: sso:account:access
-   Select the role AWS Int Data Engineer with the account ID: XXXXXXXXX
-   CLI default client Region [None]: eu-west-2
-   CLI default output format [None]: json

```zsh
aws configure sso
```

## Run AWS Commands locally

Once you have completed the above setup steps for can run AWS commands locally with the following
commands

```zsh
aws sso login --profile int-data-eng
```

### Using DevContainer

To use this DevContainer within another repo, you need a _.DevContainer.json_ file in the base of a
repo.

Here is a sample file - please change _<CURRENT_REPO_NAME>_ with your correct repo name

```json
{
    "image": "ghcr.io/pixie79/DevContainer:latest",
    "containerEnv": {
        "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}",
        "GITHUB_USER": "${localEnv:GITHUB_USER}"
    },
    "customizations": {
        "codespaces": {
            "repositories": {
                "pixie79/DevContainer": {
                    "permissions": "read-all"
                },
                "pixie79/<CURRENT_REPO_NAME>": {
                    "permissions": "write-all"
                }
            }
        }
    }
}
```
