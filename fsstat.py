#!/usr/bin/env python3
"""
Get filesystem statistics
"""

import argparse
import os
import sys
from statistics import mean, median


def get_file_sizes(directory: str) -> list[int]:
    """
    Get file sizes
    """
    file_sizes = []
    inodes = set()

    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                file_stat = os.stat(file_path)
                # Ignore hard links by checking the inode
                if file_stat.st_ino not in inodes:
                    inodes.add(file_stat.st_ino)
                    file_sizes.append(file_stat.st_size)
            except FileNotFoundError:
                # Handle the case where the file was deleted between finding it and stat-ing it
                continue

    return file_sizes


def print_statistics(file_sizes: list[int]) -> None:
    """
    Print stats
    """
    if not file_sizes:
        print("No files found.")
        return

    avg_size = mean(file_sizes)
    med_size = median(file_sizes)

    print(f"Average file size: {avg_size:.2f} bytes")
    print(f"Median file size: {med_size:.2f} bytes")


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
        file_sizes = get_file_sizes(directory)
        print_statistics(file_sizes)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
