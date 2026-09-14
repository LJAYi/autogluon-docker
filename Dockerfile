# syntax=docker/dockerfile:1

ARG VARIANT=cpu

FROM python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254 AS cpu
ARG AUTOGLUON_VERSION=1.6.2

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
        --extra-index-url https://pypi.org/simple \
        "autogluon==${AUTOGLUON_VERSION}"

FROM nvidia/cuda:13.2.1-cudnn-runtime-ubuntu24.04@sha256:1c0c68dbf3258d32b446a02cb4be05c8478b65d320d7856ad33c4bbdf898ca86 AS gpu
ARG AUTOGLUON_VERSION=1.6.2

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
        --extra-index-url https://pypi.org/simple \
        "autogluon==${AUTOGLUON_VERSION}"

FROM ${VARIANT} AS final
ARG AUTOGLUON_VERSION=1.6.2
ARG VARIANT=cpu

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

LABEL org.opencontainers.image.title="AutoGluon Docker" \
      org.opencontainers.image.description="Unofficial AutoGluon ${VARIANT} image" \
      org.opencontainers.image.version="${AUTOGLUON_VERSION}"

WORKDIR /workspace
COPY scripts/smoke-test.py /tests/smoke-test.py

CMD ["python"]
