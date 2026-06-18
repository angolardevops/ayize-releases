#!/bin/sh
# Instalador / atualizador da toolchain Ayize (estilo rustup): descarrega o binário
# pré-compilado do repositório público de releases e instala-o em ~/.ayize/bin.
# Se já houver uma instalação, deteta a versão e atualiza-a para a release mais recente.
#
#   curl --proto '=https' --tlsv1.2 -sSf https://ayize.dev/install.sh | sh
#   (ou) curl --proto '=https' --tlsv1.2 -sSf \
#        https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install.sh | sh
#
# Variáveis: AYIZE_GPU=cuda|wgpu (variante GPU) · AYIZE_FORCE=1 (reinstala mesmo já atual)
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

# ── Versão da release mais recente (via API; vazio se offline/sem acesso) ──
latest_tag="$(curl --proto '=https' --tlsv1.2 -fsSL \
  "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null \
  | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
latest_ver="${latest_tag#v}"

# ── Versão atualmente instalada neste diretório (se existir) ──
existing="$INSTALL_DIR/ayize"
current=""
if [ -x "$existing" ]; then
  current="$("$existing" --version 2>/dev/null | awk '{print $2}')"
fi

# ── Decidir: nada a fazer / atualizar / instalar de novo ──
if [ -n "$current" ]; then
  if [ -n "$latest_ver" ] && [ "$current" = "$latest_ver" ] && [ -z "${AYIZE_FORCE:-}" ]; then
    echo "Ayize $current já é a versão mais recente em $existing — nada a fazer."
    echo "(define AYIZE_FORCE=1 para reinstalar ou trocar de variante.)"
    exit 0
  fi
  if [ -n "$latest_ver" ]; then
    echo "Ayize $current instalado — a atualizar para $latest_ver…"
  else
    echo "Ayize $current instalado — a reinstalar a partir da release mais recente…"
  fi
else
  echo "A instalar Ayize ${latest_ver:-(release mais recente)}…"
fi

# ── Descarregar para ficheiro temporário e só depois substituir (atómico) ──
echo "A descarregar ${asset}…"
mkdir -p "$INSTALL_DIR"
tmp="$INSTALL_DIR/.ayize.download.$$"
if ! curl --proto '=https' --tlsv1.2 -fSL "$url" -o "$tmp"; then
  rm -f "$tmp"
  echo "ayize: não há binário '${asset}' nesta release."
  if [ -n "$gpu" ]; then
    echo "       As variantes GPU existem para linux-x86_64; nas outras plataformas usa a versão base (sem AYIZE_GPU)."
  fi
  exit 1
fi
chmod +x "$tmp"
mv -f "$tmp" "$INSTALL_DIR/ayize"

new_ver="$("$INSTALL_DIR/ayize" --version 2>/dev/null | awk '{print $2}')"
if [ -n "$current" ] && [ -n "$new_ver" ] && [ "$current" != "$new_ver" ]; then
  echo "Ayize atualizado: $current → $new_ver  ($INSTALL_DIR/ayize)"
else
  echo "Ayize ${new_ver:+$new_ver }instalado em $INSTALL_DIR/ayize"
fi

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
