#!/usr/bin/env python3

import hashlib
import sys
import tomllib
from pathlib import Path
from typing import List, Tuple


def main():
    repo_root = Path(__file__).resolve().parent.parent.parent.parent
    pack_file = repo_root / "src" / "pack.toml"
    index_file = repo_root / "src" / "index.toml"

    all_correct = True

    for metafile in get_nonmetafiles(index_file):
        with metafile[0].open("rb") as f:
            digest = hashlib.file_digest(f, "sha256")
            if digest.hexdigest() != metafile[1]:
                all_correct = False
                print(f"Hash mismatch for {metafile[0]}: {digest} != {metafile[1]}")

    if not all_correct:
        sys.exit(1)
    else:
        sys.exit(0)


def get_nonmetafiles(index_file: Path) -> List[Tuple[Path, str]]:
    with open(index_file, "rb") as f:
        index = tomllib.load(f)

    files = filter(lambda entry: not entry.get("metafile", False), index["files"])
    return [(index_file.parent / entry["file"], entry["hash"]) for entry in files]


if __name__ == "__main__":
    main()
