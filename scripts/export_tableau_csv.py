#!/usr/bin/env python3
"""
Export clean CSVs for Tableau with proper formatting.
"""

import csv
import psycopg2
from pathlib import Path

DB_CONFIG = {
    'dbname': 'nusacommerce',
    'user': 'nusacommerce_user',
    'password': 'nusacommerce2025',
    'host': 'localhost'
}

PROJECT_ROOT = Path(__file__).parent.parent
TABLEAU_DIR = PROJECT_ROOT / "data" / "tableau"

EXPORTS = {
    "dashboard_executive": "SELECT * FROM vw_dashboard_executive",
    "rfm_summary": "SELECT * FROM vw_rfm_summary",
    "revenue_monthly": "SELECT * FROM vw_revenue_monthly",
}


def export_query_to_csv(cursor, query, filepath, delimiter=','):
    """Export query results to CSV with proper formatting."""
    cursor.execute(query)
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()

    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(
            f,
            delimiter=delimiter,
            quoting=csv.QUOTE_NONNUMERIC,
            quotechar='"'
        )
        writer.writerow(columns)

        for row in rows:
            cleaned_row = []
            for val in row:
                if val is None:
                    cleaned_row.append('')
                elif isinstance(val, (int, float)):
                    cleaned_row.append(val)
                else:
                    cleaned_row.append(str(val))
            writer.writerow(cleaned_row)

    return len(rows), len(columns)


def main():
    print("Exporting CSVs for Tableau...\n")

    TABLEAU_DIR.mkdir(parents=True, exist_ok=True)

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    print(f"{'Export':<25} {'Rows':>8} {'Cols':>6} {'File'}")
    print("-" * 70)

    for name, query in EXPORTS.items():
        csv_path = TABLEAU_DIR / f"{name}_clean.csv"
        rows, cols = export_query_to_csv(cursor, query, csv_path)
        print(f"{name:<25} {rows:>8} {cols:>6} {csv_path.name}")

        pipe_path = TABLEAU_DIR / f"{name}.txt"
        export_query_to_csv(cursor, query, pipe_path, delimiter='|')

    cursor.close()
    conn.close()

    print("\n" + "=" * 70)
    print("EXPORT COMPLETE")
    print("=" * 70)
    print(f"\nFiles saved to: {TABLEAU_DIR}/")
    print("\nFor each export:")
    print("  - *_clean.csv : Comma-separated with proper quoting")
    print("  - *.txt       : Pipe-separated (alternative format)")

    print("\n" + "-" * 70)
    print("PREVIEW (first 2 rows of each clean CSV):")
    print("-" * 70)

    for name in EXPORTS.keys():
        csv_path = TABLEAU_DIR / f"{name}_clean.csv"
        print(f"\n{csv_path.name}:")
        with open(csv_path, 'r') as f:
            for i, line in enumerate(f):
                if i < 2:
                    if len(line) > 120:
                        print(f"  {line[:120].strip()}...")
                    else:
                        print(f"  {line.strip()}")


if __name__ == "__main__":
    main()
