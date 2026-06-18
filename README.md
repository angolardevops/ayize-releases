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

## Atualizar

Corre **o mesmo comando** outra vez. O instalador deteta a versão instalada e:

- se já for a mais recente → não faz nada;
- se for mais antiga → atualiza-a (descarrega e substitui), mostrando `0.1.0 → 0.1.1`.

Para forçar a reinstalação (ou trocar de variante CPU/GPU sem mudar de versão), usa
`AYIZE_FORCE=1`. A documentação online está em
<https://angolardevops.github.io/ayize-releases/>.

## Aceleração GPU

Há variantes com GPU para Linux x86_64. Escolhe-as com a variável `AYIZE_GPU`:

```sh
# NVIDIA (CUDA) — precisa de libcuda/libnvrtc no sistema
curl --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install.sh | AYIZE_GPU=cuda sh

# Portável (wgpu: Vulkan / Metal / DX)
curl --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/angolardevops/ayize-releases/main/install.sh | AYIZE_GPU=wgpu sh
```

Com uma variante GPU, os `matmul` grandes correm na placa automaticamente (forward e
backward residentes no dispositivo). A versão base usa CPU.

## Plataformas

| Plataforma            | Asset                         | Estado |
|-----------------------|-------------------------------|--------|
| Linux x86_64 (CPU)    | `ayize-linux-x86_64`          | ✅     |
| Linux x86_64 (CUDA)   | `ayize-linux-x86_64-cuda`     | ✅     |
| Linux x86_64 (wgpu)   | `ayize-linux-x86_64-wgpu`     | ✅     |
| macOS / Windows / ARM | —                             | no roteiro |

## Licença

MIT OR Apache-2.0 (igual ao projeto principal).
