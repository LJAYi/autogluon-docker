#!/usr/bin/env python3

import os
import sys
from importlib.metadata import version

import torch
from autogluon.tabular import TabularPredictor


expected_version = os.environ.get("EXPECTED_VERSION")
expected_cuda = os.environ.get("EXPECTED_CUDA")

print("Python:", sys.version)
autogluon_version = version("autogluon")
print("AutoGluon:", autogluon_version)
print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if expected_version:
    assert autogluon_version == expected_version, (
        f"expected AutoGluon {expected_version}, got {autogluon_version}"
    )
if expected_cuda == "none":
    assert torch.version.cuda is None, f"expected CPU PyTorch, got {torch.version.cuda}"
elif expected_cuda:
    assert torch.version.cuda == expected_cuda, (
        f"expected CUDA {expected_cuda}, got {torch.version.cuda}"
    )

print("AutoGluon TabularPredictor import: OK")
