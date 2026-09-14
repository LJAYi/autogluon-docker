# AutoGluon Docker

Unofficial, community-maintained AutoGluon images for CPU and GPU workloads.
This project is not affiliated with or endorsed by AutoGluon or Amazon Web Services.

## Images

```text
ghcr.io/ljayi/autogluon-docker:1.6.2-cpu-py312
ghcr.io/ljayi/autogluon-docker:1.6.2-gpu-cu132-py312
```

Moving aliases are also published as `latest-cpu-py312` and
`latest-gpu-cu132-py312`. Use a versioned tag for reproducible jobs. Images
currently target `linux/amd64` and use Python 3.12.
The build resolves compatible Torch packages from the CPU or CUDA 13.2 PyTorch
index for each AutoGluon release.

## Run

```bash
docker run --rm ghcr.io/ljayi/autogluon-docker:latest-cpu-py312 \
  python -c 'from importlib.metadata import version; print(version("autogluon"))'

docker run --rm --gpus all \
  ghcr.io/ljayi/autogluon-docker:latest-gpu-cu132-py312 \
  python -c 'import torch; print(torch.version.cuda, torch.cuda.is_available())'
```

The GPU image requires a compatible NVIDIA host driver and NVIDIA Container Toolkit.
The standard GitHub-hosted runner has no NVIDIA GPU, so CI validates GPU imports and
CUDA wheel metadata, not actual GPU execution.

## Slurm with Apptainer

Pull a versioned image once on a login node:

```bash
module load apptainer
apptainer pull autogluon-gpu.sif \
  docker://ghcr.io/ljayi/autogluon-docker:1.6.2-gpu-cu132-py312
```

Run it on a GPU node:

```bash
srun --partition=gpu --gres=gpu:1 --cpus-per-task=8 --mem=32G \
  apptainer exec --cleanenv --nv --bind "$SLURM_SUBMIT_DIR:/workspace" --pwd /workspace \
  autogluon-gpu.sif python train.py
```

Partition names and resource flags vary by cluster. The host NVIDIA driver must
support CUDA 13.2. Remove `--nv` and use the CPU image for CPU-only jobs.

## Release policy

The scheduled workflow checks PyPI daily for the latest stable AutoGluon release.
For a new version it builds both variants, runs smoke tests, and publishes versioned
and moving `latest-*` tags. A successful new version also creates an
`autogluon-<version>` GitHub Release. A failed build is retried on the next run. If
all image tags were published before a smoke-test or Release failure, the next run
resumes at the smoke test without rebuilding the images.
