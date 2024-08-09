# Installed nvim using Pre-built archives

The Releases page provides pre-built binaries for Linux systems.

```sh
#        https://github.com/neovim/neovim/releases/download/v0.10.1/nvim-linux64.tar.gz
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
```

After this step add this to ~/.bashrc:
Then in ~/.bashrc add the following line:

```bash
export PATH="$PATH:/opt/nvim-linux64/bin"
```
