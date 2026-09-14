#!/usr/bin/env python3

import os
import sys

import autogluon
import torch
from autogluon.tabular import TabularPredictor


expected_version = os.environ.get("EXPECTED_VERSION")
expected_cuda = os.environ.get("EXPECTED_CUDA")

print("Python:", sys.version)
print("AutoGluon:", autogluon.__version__)
print("PyTorch:", torch.__version__)
print("PyTorch CUDA:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if expected_version:
    assert autogluon.__version__ == expected_version, (
        f"expected AutoGluon {expected_version}, got {autogluon.__version__}"
    )
if expected_cuda == "none":
    assert torch.version.cuda is None, f"expected CPU PyTorch, got {torch.version.cuda}"
elif expected_cuda:
    assert torch.version.cuda == expected_cuda, (
        f"expected CUDA {expected_cuda}, got {torch.version.cuda}"
    )

assert TabularPredictor is not None
print("AutoGluon TabularPredictor import: OK")
