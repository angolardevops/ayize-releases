# Ayize — releases

Binários pré-compilados da toolchain [**Ayize**](https://github.com/angolardevops/ayize),
uma linguagem de programação *LLM-native* (`.az`).

## Instalar (uma linha)

```sh
curl --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install.sh | sh
```

Isto descarrega o binário certo para a tua plataforma (das [Releases](../../releases)),
instala-o em `~/.ayize/bin/ayize` e diz-te como o pôr no `PATH`. Depois:

```sh
ayize --help          # a toolchain: new / run / check / fmt / test
ayize serve doc       # abre a documentação oficial no browser
```

## Plataformas

| Plataforma            | Asset                    | Estado |
|-----------------------|--------------------------|--------|
| Linux x86_64          | `ayize-linux-x86_64`     | ✅     |
| macOS / Windows / ARM | —                        | compila a partir da fonte |

Para outras plataformas (ou para ativar o JIT LLVM / GPU CUDA/wgpu), compila a partir da
fonte: <https://github.com/angolardevops/ayize>.

## Licença

MIT OR Apache-2.0 (igual ao projeto principal).
