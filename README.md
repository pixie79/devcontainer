# devcontainer

Devcontainer based on ultimate codespaces with extras and sample linting files

## First Time Setup

For a new project ensure the src directory is correctly set in pyproject.toml and run the following to setup commit messages and checking

```
pre-commit install
commitizen init cz-conventional-changelog --save-dev --save-exact --force
```

When checking in code instead of using `git commit` use `git cz` - This will auto create the commit message based on your prompt answers in the correct format.


Additional features can be added from here: [https://containers.dev/feature](https://containers.dev/features)
