#!/bin/sh
# Instalador da extensão Ayize para VS Code (syntax highlighting de .az, snippets e,
# opcionalmente, o language server). Descarrega o .vsix da release mais recente e
# instala-o no editor da família VS Code que encontrar.
#
#   curl --proto '=https' --tlsv1.2 -sSf \
#     https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install-vscode.sh | sh
set -eu

REPO="angolardevops/ayize-releases"
VSIX_URL="https://github.com/${REPO}/releases/latest/download/ayize-vscode.vsix"

# Encontra um CLI da família VS Code (VS Code, Insiders, VSCodium, Cursor).
cli=""
for c in code code-insiders codium code-oss cursor; do
  if command -v "$c" >/dev/null 2>&1; then cli="$c"; break; fi
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
vsix="$tmp/ayize-vscode.vsix"

echo "A descarregar a extensão Ayize para VS Code…"
if ! curl --proto '=https' --tlsv1.2 -fSL "$VSIX_URL" -o "$vsix"; then
  echo "ayize: não consegui descarregar a extensão (ayize-vscode.vsix)."
  exit 1
fi

if [ -n "$cli" ]; then
  echo "A instalar via '$cli'…"
  "$cli" --install-extension "$vsix" --force
  echo "Extensão Ayize instalada. Abre um ficheiro .az (recarrega o editor se preciso)."
else
  # Sem CLI 'code': instala manualmente, extraindo para a pasta de extensões.
  ext_dir="$HOME/.vscode/extensions/ayize.ayize"
  echo "Nenhum CLI da família VS Code encontrado — a instalar em $ext_dir…"
  if ! command -v unzip >/dev/null 2>&1; then
    echo "ayize: instala o CLI 'code' ou o 'unzip' para concluir."
    echo "       (o .vsix está em $vsix)"
    exit 1
  fi
  rm -rf "$ext_dir"
  mkdir -p "$ext_dir"
  unzip -q "$vsix" 'extension/*' -d "$tmp/x"
  cp -R "$tmp/x/extension/." "$ext_dir/"
  echo "Extensão Ayize instalada em $ext_dir. Reinicia o VS Code."
fi

echo
echo "Sintaxe .az ativa. O language server (diagnósticos) é opcional: instala 'ayize-lsp'"
echo "no PATH para o ativar — sem ele, o highlighting e os snippets funcionam na mesma."
