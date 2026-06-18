#!/bin/sh
# Instalador da toolchain Ayize (estilo rustup): descarrega o binário pré-compilado
# do repositório público de releases e instala-o em ~/.ayize/bin.
#
#   curl --proto '=https' --tlsv1.2 -sSf https://ayize.dev/install.sh | sh
#   (ou) curl --proto '=https' --tlsv1.2 -sSf \
#        https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install.sh | sh
set -eu

REPO="angolardevops/ayize-releases"
INSTALL_DIR="${AYIZE_HOME:-$HOME/.ayize}/bin"

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Linux) os_tag="linux" ;;
  Darwin) os_tag="macos" ;;
  *) echo "ayize: SO não suportado ($os) — compila a partir da fonte (ver README)"; exit 1 ;;
esac
case "$arch" in
  x86_64 | amd64) arch_tag="x86_64" ;;
  aarch64 | arm64) arch_tag="aarch64" ;;
  *) echo "ayize: arquitetura não suportada ($arch)"; exit 1 ;;
esac

asset="ayize-${os_tag}-${arch_tag}"

# Variante com aceleração GPU (opcional):
#   AYIZE_GPU=cuda  → NVIDIA (precisa de libcuda/libnvrtc no sistema)
#   AYIZE_GPU=wgpu  → portável (Vulkan/Metal/DX)
gpu="${AYIZE_GPU:-}"
case "$gpu" in
  "") ;;
  cuda | wgpu) asset="${asset}-${gpu}" ;;
  *) echo "ayize: AYIZE_GPU inválido ('$gpu') — usa 'cuda' ou 'wgpu'"; exit 1 ;;
esac

url="https://github.com/${REPO}/releases/latest/download/${asset}"

echo "A descarregar ${asset}…"
mkdir -p "$INSTALL_DIR"
if ! curl --proto '=https' --tlsv1.2 -fSL "$url" -o "$INSTALL_DIR/ayize"; then
  echo "ayize: não há binário '${asset}' nesta release."
  if [ -n "$gpu" ]; then
    echo "       As variantes GPU existem para linux-x86_64; nas outras plataformas usa a versão base (sem AYIZE_GPU)."
  fi
  exit 1
fi
chmod +x "$INSTALL_DIR/ayize"

echo "Ayize instalado em $INSTALL_DIR/ayize"
case ":${PATH}:" in
  *":${INSTALL_DIR}:"*) ;;
  *)
    echo
    echo "Adiciona ao teu shell (~/.bashrc, ~/.zshrc, …):"
    echo "    export PATH=\"${INSTALL_DIR}:\$PATH\""
    ;;
esac
echo
echo "Confirma com:  ayize --help     ·     docs:  ayize serve doc"
