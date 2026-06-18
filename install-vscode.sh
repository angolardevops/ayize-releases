#!/bin/sh
# Instalador da extensão Ayize para editores da família VS Code: VS Code, Insiders,
# VSCodium, Cursor e Google Antigravity. Coloração de sintaxe de .az, snippets e,
# opcionalmente, o language server. Descarrega o .vsix da release mais recente e
# instala-o em TODOS os editores compatíveis que encontrar.
#
#   curl --proto '=https' --tlsv1.2 -sSf \
#     https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install-vscode.sh | sh
#
# AYIZE_EDITOR="antigravity"  → instala só nesse editor (ex.: code, cursor, antigravity).
set -eu

REPO="angolardevops/ayize-releases"
VSIX_URL="https://github.com/${REPO}/releases/latest/download/ayize-vscode.vsix"

# Editores compatíveis (instala em todos os presentes; override com AYIZE_EDITOR).
candidates="code code-insiders codium code-oss cursor antigravity"
[ -n "${AYIZE_EDITOR:-}" ] && candidates="$AYIZE_EDITOR"

found=""
for c in $candidates; do
  if command -v "$c" >/dev/null 2>&1; then
    found="${found:+$found }$c"
  fi
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
vsix="$tmp/ayize-vscode.vsix"

echo "A descarregar a extensão Ayize…"
if ! curl --proto '=https' --tlsv1.2 -fSL "$VSIX_URL" -o "$vsix"; then
  echo "ayize: não consegui descarregar a extensão (ayize-vscode.vsix)."
  exit 1
fi

if [ -n "$found" ]; then
  ok=0
  for c in $found; do
    if "$c" --install-extension "$vsix" --force >/dev/null 2>&1; then
      echo "  ✓ instalada em: $c"
      ok=1
    else
      echo "  ✗ falhou em: $c"
    fi
  done
  if [ "$ok" -eq 1 ]; then
    echo "Extensão Ayize instalada. Abre um ficheiro .az (recarrega o editor se preciso)."
  fi
else
  # Sem nenhum CLI compatível: instala manualmente na pasta de extensões do VS Code.
  ext_dir="$HOME/.vscode/extensions/ayize.ayize"
  echo "Nenhum editor compatível no PATH — a instalar em $ext_dir…"
  if ! command -v unzip >/dev/null 2>&1; then
    echo "ayize: instala um editor compatível (code/cursor/antigravity) ou o 'unzip'."
    echo "       (o .vsix está em $vsix)"
    exit 1
  fi
  rm -rf "$ext_dir"
  mkdir -p "$ext_dir"
  unzip -q "$vsix" 'extension/*' -d "$tmp/x"
  cp -R "$tmp/x/extension/." "$ext_dir/"
  echo "Extensão Ayize instalada em $ext_dir. Reinicia o editor."
fi

echo
echo "Sintaxe .az ativa. O language server (diagnósticos) é opcional: instala 'ayize-lsp'"
echo "no PATH para o ativar — sem ele, o highlighting e os snippets funcionam na mesma."
