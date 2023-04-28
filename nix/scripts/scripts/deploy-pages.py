#!/usr/bin/env python3

import logging
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from textwrap import dedent, indent

import mistune

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
            "--format=%(refname:short),%(objectname)",
            "refs/remotes",
            "refs/tags",
        ],
        cwd=repo,
        text=True,
    ).splitlines()

    versions = [version.split(",")[:2] for version in versions]
    # Remove the prefix `origin` from all branch names
    versions = {name.removeprefix("origin/"): obj for name, obj in versions}

    logger.debug(f"Versions to publish: {versions}")

    # Check out and copy the modpack for each version
    for version, obj in versions.items():
        logger.debug(f"Checking out {version}")
        subprocess.check_call(["git", "checkout", obj], cwd=repo)
        shutil.copytree(repo / "src", outpath / version, copy_function=shutil.copy)

    # Finally, write a little index page so that we can easily
    # navigate the various versions
    links = "\n".join(
        f"- [{version}]({version}/pack.toml)"
        for version in sorted(versions.keys(), reverse=True)
    )
    # indent the links by just as much as the other lines in the
    # markdown string, so that `dedent` behaves correctly
    links = indent(links, "                    ")

    with (outpath / "index.html").open("w") as index:
        index.write(
            mistune.html(
                dedent(
                    f"""
                    Welcome to the Thonks & Stonks modpack!

                    ## Installation instructions

                    1. Use [PrismLauncher][prismlauncher-home]
                    2. Create a new instance
                    3. Download the latest packwiz bootstrap installer from [their release
                       page][packwiz-installer-latest] (the `.jar` file)
                    4. Put the installer in the `.minecraft` directory of the instance you
                       created
                    5. Copy [this link]({sorted(versions, reverse=True)[0]}/pack.toml) or any of the
                       links in [Versions](#Versions) (right mouse button + copy link)
                    6. Go to your instance configuration, to Settings > Custom Commands
                    7. Tick the `Custom Commands` box and enter the following into the
                       `Pre-launch command`:
                       `"$INST_JAVA" -jar packwiz-installer-bootstrap.jar <paste link here>`

                    ## Versions

{links}

                    [prismlauncher-home]: https://prismlauncher.org/
                    [packwiz-installer-latest]: https://github.com/packwiz/packwiz-installer-bootstrap/releases/tag/v0.0.3
                    """
                )
            )
        )


if __name__ == "__main__":
    main()
