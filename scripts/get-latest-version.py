#!/usr/bin/env python3
"""Print the latest non-prerelease AutoGluon version published on PyPI."""

import json
import re
import urllib.request


URL = "https://pypi.org/pypi/autogluon/json"
STABLE = re.compile(r"^\d+\.\d+\.\d+(?:\.post\d+)?$")


with urllib.request.urlopen(URL, timeout=30) as response:
    data = json.load(response)

version = data["info"]["version"]
files = data["releases"].get(version, [])
if not STABLE.fullmatch(version) or not files or all(item["yanked"] for item in files):
    raise SystemExit(f"PyPI did not report a usable stable release: {version}")

print(version)
