# nix-python-cuda

## Getting started 🚀

Use [`nix-direnv`](https://github.com/nix-community/nix-direnv) and the development shell will automatically activate

Install Python dependencies with
```bash
poetry install --no-root
```

## n.b.

- Add external projects as [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

```bash
cd ComfyUI
rm -rf custom_nodes
ln -s ../custom_nodes/ .
```