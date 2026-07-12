#!/bin/sh
# Installs the latest portway-agent release for this machine's OS/arch.
# Usage: curl -fsSL https://raw.githubusercontent.com/coderbenny/portway-agent/main/install.sh | sh
set -eu

REPO="coderbenny/portway-agent"

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  *)
    echo "portway-agent: unsupported OS '$os'. Download a binary manually from https://github.com/$REPO/releases/latest" >&2
    exit 1
    ;;
esac

case "$arch" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *)
    echo "portway-agent: unsupported architecture '$arch'. Download a binary manually from https://github.com/$REPO/releases/latest" >&2
    exit 1
    ;;
esac

echo "Fetching the latest portway-agent release for ${os}/${arch}..."

api_url="https://api.github.com/repos/${REPO}/releases/latest"
asset_url="$(curl -fsSL "$api_url" | grep '"browser_download_url"' | grep "_${os}_${arch}\.tar\.gz" | head -n1 | cut -d '"' -f4)"

if [ -z "$asset_url" ]; then
  echo "portway-agent: couldn't find a release asset for ${os}/${arch}. Check https://github.com/$REPO/releases/latest" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "Downloading ${asset_url}..."
curl -fsSL "$asset_url" -o "$tmpdir/portway-agent.tar.gz"
tar -xzf "$tmpdir/portway-agent.tar.gz" -C "$tmpdir"

install_dir="$HOME/.local/bin"
mkdir -p "$install_dir"

if [ ! -w "$install_dir" ]; then
  if [ -w "/usr/local/bin" ]; then
    install_dir="/usr/local/bin"
  else
    echo "portway-agent: neither ${install_dir} nor /usr/local/bin is writable." >&2
    exit 1
  fi
fi

mv "$tmpdir/portway-agent" "$install_dir/portway-agent"
chmod +x "$install_dir/portway-agent"

echo "Installed portway-agent to ${install_dir}/portway-agent"

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *)
    echo "Note: ${install_dir} is not on your PATH. Add it, e.g.:"
    echo "  export PATH=\"${install_dir}:\$PATH\""
    ;;
esac

echo
echo "Run it with:"
echo "  portway-agent -relay=agent.portway.online:9443 -tls=true -token=<token from the Portway dashboard>"
