#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    # Take argv[1] as the output directory, creating it if it does not
    # exist yet
    outpath = Path(sys.argv[1])
    outpath.mkdir(parents=True, exist_ok=True)

    # Unless we are in CI, clone a copy of the repository into a
    # temporary directory
    if not os.getenv("CI"):
        with tempfile.TemporaryDirectory() as temp:
            subprocess.check_output(["git", "clone", os.getcwd(), temp])
            publish_tags(Path(temp), outpath)
    else:
        publish_tags(Path(os.getcwd()), outpath)


def publish_tags(repo: Path, outpath: Path):
    tags = subprocess.check_output(
        ["git", "tag", "--list"], cwd=repo, text=True
    ).splitlines()

    for tag in tags:
        subprocess.check_call(["git", "checkout", f"tags/{tag}"], cwd=repo)
        shutil.copytree(repo / "src", outpath / str(tag), copy_function=shutil.copy)


if __name__ == "__main__":
    main()
