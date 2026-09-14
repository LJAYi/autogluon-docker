#!/usr/bin/env python3
"""Print the latest non-prerelease AutoGluon version published on PyPI."""

import json
import re
import urllib.request


URL = "https://pypi.org/pypi/autogluon/json"
STABLE = re.compile(r"^(\d+)\.(\d+)\.(\d+)(?:\.post(\d+))?$")


with urllib.request.urlopen(URL, timeout=30) as response:
    data = json.load(response)

candidates = []
for version, files in data["releases"].items():
    match = STABLE.fullmatch(version)
    if not match or not files or all(item.get("yanked", False) for item in files):
        continue
    major, minor, patch, post = match.groups()
    key = (int(major), int(minor), int(patch), -1 if post is None else int(post))
    candidates.append((key, version))

if not candidates:
    raise SystemExit("PyPI did not report a usable stable AutoGluon release")

print(max(candidates)[1])
