#!/usr/bin/env python3
"""
Plot primary & secondary
"""

import argparse
import math
from datetime import date, datetime, timedelta
import matplotlib.pyplot as plt

# Set background color
plt.rcParams["figure.facecolor"] = "lightgray"
plt.rcParams["axes.facecolor"] = "lightgray"


def sin(days_lived: int, cycle_length: int) -> float:
    """
    Get value
    """
    return math.sin(2 * math.pi * days_lived / cycle_length)


def plot_chart(
    dates: list[date],
    target: date,
    cycles: dict[str, tuple[str, list[float]]],
    title: str,
) -> None:
    """
    Plot chart
    """
    plt.figure(figsize=(8, 8))
    for label, (color, values) in cycles.items():
        plt.plot(dates, values, label=label, color=color)

    # Horizontal and vertical reference lines
    plt.axhline(0, color="gray", linestyle="--")
    plt.axvline(target, color="gray", linestyle="--")

    # Update X-axis ticks to show relative days
    plt.xticks(dates, [f"{(date - target).days:+d}" for date in dates], rotation=0)

    plt.ylim(-100, 100)
    plt.xlim(dates[0], dates[-1])

    plt.title(title)
    plt.xlabel(f"Days relative to {target}")
    plt.ylabel("Value (%)")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{title}.png")


def plot_charts(birth_date: str, target_date: str | None, days_range: int = 7) -> None:
    """
    Plot charts
    """
    birth: date = datetime.strptime(birth_date, "%Y-%m-%d").date()
    target: date = (
        datetime.strptime(target_date, "%Y-%m-%d").date()
        if target_date
        else datetime.now().date()
    )
    dates: list[date] = [
        target + timedelta(days=i) for i in range(-days_range, days_range + 1)
    ]
    days_lived: list[int] = [(date - birth).days for date in dates]

    primary: dict[str, tuple[str, list[float]]] = {
        "Physical": ("red", [sin(d, 23) * 100 for d in days_lived]),
        "Emotional": ("yellow", [sin(d, 28) * 100 for d in days_lived]),
        "Intellectual": ("blue", [sin(d, 33) * 100 for d in days_lived]),
    }
    plot_chart(dates, target, primary, "Primary")

    secondary: dict[str, tuple[str, list[float]]] = {
        "Passion": ("orange", [(sin(d, 23) + sin(d, 28)) * 50 for d in days_lived]),
        "Mastery": ("purple", [(sin(d, 23) + sin(d, 33)) * 50 for d in days_lived]),
        "Wisdom": ("green", [(sin(d, 28) + sin(d, 33)) * 50 for d in days_lived]),
    }
    plot_chart(dates, target, secondary, "Secondary")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "birth_date",
        type=str,
        help="Birth date in YYYY-MM-DD format",
    )
    parser.add_argument(
        "target_date",
        type=str,
        default=None,
        nargs="?",
        help="Target date in YYYY-MM-DD format (default is today)",
    )
    args = parser.parse_args()
    plot_charts(args.birth_date, args.target_date)
