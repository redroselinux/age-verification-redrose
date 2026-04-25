#!/usr/bin/env python3
import subprocess
import sys

result = subprocess.run(["useradd"] + sys.argv[1:])

if result.returncode == 0:
    result = subprocess.run(["age_verification_redrose"])

sys.exit(result.returncode)
