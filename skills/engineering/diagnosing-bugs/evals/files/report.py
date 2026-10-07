"""CSV renderer used by the nightly worker, one call per customer."""

HEADER = ["id", "name", "total"]
_lines = []


def render_csv(rows):
    """Return the CSV text for rows, header first."""
    _lines.append(",".join(HEADER))
    for row in rows:
        _lines.append(",".join(str(row[key]) for key in HEADER))
    return "\n".join(_lines) + "\n"
