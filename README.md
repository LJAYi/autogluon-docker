# AutoGluon Docker

Unofficial, community-maintained AutoGluon images for CPU and GPU workloads.
This project is not affiliated with or endorsed by AutoGluon or Amazon Web Services.

## Images

```text
ghcr.io/<owner>/autogluon-docker:1.6.1-cpu-py312
ghcr.io/<owner>/autogluon-docker:1.6.1-gpu-cu132-py312
```

Moving aliases are also published as `latest-cpu-py312` and
`latest-gpu-cu132-py312`. Images currently target `linux/amd64`.

## Run

```bash
docker run --rm ghcr.io/<owner>/autogluon-docker:latest-cpu-py312 \
  python -c 'import autogluon; print(autogluon.__version__)'

docker run --rm --gpus all \
  ghcr.io/<owner>/autogluon-docker:latest-gpu-cu132-py312 \
  python -c 'import torch; print(torch.version.cuda, torch.cuda.is_available())'
```

The GPU image requires a compatible NVIDIA host driver and NVIDIA Container Toolkit.
The standard GitHub-hosted runner has no NVIDIA GPU, so CI validates GPU imports and
CUDA wheel metadata, not actual GPU execution.

## Release policy

The scheduled workflow reads the latest stable AutoGluon release from PyPI. It ignores
pre-releases and yanked releases, builds both variants, runs smoke tests, and publishes
immutable version tags plus moving `latest-*` aliases.
