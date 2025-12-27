#!/usr/bin/env python3
"""
Show FreeBSD last update dates
"""

import urllib.request
from datetime import datetime
from html.parser import HTMLParser


URL = "https://pkg.freebsd.org/FreeBSD:15:amd64/"


class DirectoryParser(HTMLParser):
    """
    Parse directory entries from https://pkg.freebsd.org/
    """

    def __init__(self):
        super().__init__()
        self.entries = []
        self.current = {}
        self.in_class = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "td":
            self.in_class = attrs.get("class")
        elif tag == "a" and self.in_class == "link":
            href = attrs.get("href", "")
            if href != "../":
                self.current["name"] = href.rstrip("/")

    def handle_data(self, data):
        if self.in_class == "date":
            self.current["date"] = data.strip()

    def handle_endtag(self, tag):
        if tag == "td":
            self.in_class = None
        elif tag == "tr" and "name" in self.current and "date" in self.current:
            self.entries.append(self.current)
            self.current = {}


def parse_date(date_str):
    """
    Parse date string like '2025-Dec-27 12:01' and return asctime format
    """
    dt = datetime.strptime(date_str, "%Y-%b-%d %H:%M")
    return dt.strftime("%c")


if __name__ == "__main__":
    with urllib.request.urlopen(URL) as response:
        html = response.read().decode("utf-8")

    parser = DirectoryParser()
    parser.feed(html)

    for entry in parser.entries:
        repo = entry['name']
        updated = parse_date(entry["date"])
        print(f"{repo:17}  {updated}")
