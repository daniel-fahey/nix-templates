# nix-python-cuda

## Getting started 🚀

### Linking the devShell to a GC Root 🌱

Whenever you want to enter your development environment, use:

```bash
nix develop --profile .nix/devshell-profile
```

📝 **Note**: This will generate symlinks that point to the Nix store path of your dev environment.

### Cleaning Up 🧹

- If you ever wish to remove the dev environment, delete the symlinks:

```bash
rm .nix/devshell-profile*
```

After this, the next garbage collection cycle will clean up the environment in the Nix store.

This ensures you're always working within the protected dev environment.

## n.b.

- Add external projects as [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)