# syntax=docker/dockerfile:1

ARG VARIANT=cpu

FROM python:3.12-slim-bookworm AS cpu
ARG AUTOGLUON_VERSION=1.6.1
ARG PYTORCH_VERSION=2.13.0
ARG TORCHVISION_VERSION=0.28.0

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libfontconfig1 \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libsm6 \
        libxext6 \
        libxrender1 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN python -m pip install --upgrade pip "setuptools<82" wheel \
    && python -m pip install \
        --index-url https://download.pytorch.org/whl/cpu \
        "torch==${PYTORCH_VERSION}" \
        "torchvision==${TORCHVISION_VERSION}" \
    && python -m pip install \
        --extra-index-url https://download.pytorch.org/whl/cpu \
        "autogluon==${AUTOGLUON_VERSION}"

FROM nvidia/cuda:13.2.1-cudnn-runtime-ubuntu24.04 AS gpu
ARG AUTOGLUON_VERSION=1.6.1
ARG PYTORCH_VERSION=2.13.0
ARG TORCHVISION_VERSION=0.28.0

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libfontconfig1 \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libsm6 \
        libxext6 \
        libxrender1 \
        python3.12 \
        python3.12-dev \
        python3.12-venv \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN python -m pip install --upgrade pip "setuptools<82" wheel \
    && python -m pip install \
        --index-url https://download.pytorch.org/whl/cu132 \
        "torch==${PYTORCH_VERSION}" \
        "torchvision==${TORCHVISION_VERSION}" \
    && python -m pip install \
        --extra-index-url https://download.pytorch.org/whl/cu132 \
        "autogluon==${AUTOGLUON_VERSION}"

FROM ${VARIANT} AS final
ARG AUTOGLUON_VERSION=1.6.1
ARG VARIANT=cpu

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

LABEL org.opencontainers.image.title="AutoGluon Docker" \
      org.opencontainers.image.description="Unofficial AutoGluon ${VARIANT} image" \
      org.opencontainers.image.version="${AUTOGLUON_VERSION}"

WORKDIR /workspace
COPY scripts/smoke-test.py /tests/smoke-test.py

CMD ["python"]
