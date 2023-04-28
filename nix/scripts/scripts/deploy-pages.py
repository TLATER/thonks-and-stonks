#!/usr/bin/env python3

import logging
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


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
            publish_pages(Path(temp), outpath)
    else:
        publish_pages(Path(os.getcwd()), outpath)


def publish_pages(repo: Path, outpath: Path):
    # Get a list of all tags and branches to publish
    versions = subprocess.check_output(
        [
            "git",
            "for-each-ref",
            "--format=%(refname:short)",
            "refs/remotes",
            "refs/tags",
        ],
        cwd=repo,
        text=True,
    ).splitlines()
    logger.debug(f"Versions to publish: {versions}")

    for version in versions:
        logger.debug(f"Checking out {version}")
        subprocess.check_call(["git", "checkout", version], cwd=repo)

        # Branches that start with `origin` should not start with `origin`
        name = version.removeprefix("origin/")
        shutil.copytree(repo / "src", outpath / name, copy_function=shutil.copy)


if __name__ == "__main__":
    main()
