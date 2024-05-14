#!/usr/bin/env python3
"""
Hard link all files in directory that have the same hash
"""

import argparse
import hashlib
import os
import sys


def hash_file(file: str, algorithm: str = "blake2b") -> str:
    """
    Hash file
    """
    with open(file, "rb") as f:
        return hashlib.file_digest(f, algorithm).hexdigest()


def do_dir(directory: str, dry_run: bool = False, quiet: bool = False) -> None:
    """
    Process directory
    """
    hashes: dict[str, str] = {}

    for root, _, files in os.walk(directory):
        files.sort()
        for file in files:
            file = os.path.join(root, file)
            if not os.path.isfile(file):
                continue
            file_hash = hash_file(file)
            if file_hash in hashes:
                dest_file = hashes[file_hash]
                if os.path.samefile(file, dest_file):
                    continue
                if not dry_run:
                    try:
                        os.unlink(file)
                        os.link(dest_file, file)
                    except OSError as exc:
                        sys.exit(str(exc))
                if not quiet:
                    print(f"'{file}' => '{dest_file}'")
            else:
                hashes[file_hash] = file


def main() -> None:
    """
    Main function
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--dry-run", action="store_true", help="dry run")
    parser.add_argument("-q", "--quiet", action="store_true", help="be quiet")
    parser.add_argument("directory", nargs="+")
    args = parser.parse_args()

    for directory in args.directory:
        do_dir(directory, dry_run=args.dry_run, quiet=args.quiet)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
