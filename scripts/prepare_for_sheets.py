#!/usr/bin/env python3
"""
Prepare CSV files for manual upload to Google Sheets / Looker Studio.
"""

import shutil
from pathlib import Path

SOURCE_FILES = {
    "data/exports/dashboard_revenue_monthly.csv": "data/sheets/01_revenue_monthly.csv",
    "data/exports/dashboard_rfm_summary.csv": "data/sheets/02_rfm_summary.csv",
    "data/exports/dashboard_shipping_summary.csv": "data/sheets/03_shipping_summary.csv",
    "data/exports/category_analysis.csv": "data/sheets/04_category_analysis.csv",
}

PROJECT_ROOT = Path(__file__).parent.parent


def count_rows(filepath):
    """Count data rows in CSV (excluding header)."""
    with open(filepath, 'r') as f:
        return sum(1 for _ in f) - 1


def main():
    print("Preparing CSV files for Google Sheets upload...\n")

    sheets_dir = PROJECT_ROOT / "data" / "sheets"
    sheets_dir.mkdir(parents=True, exist_ok=True)

    print(f"{'Source':<45} {'Destination':<35} {'Rows':>8}")
    print("-" * 90)

    total_rows = 0
    for source, dest in SOURCE_FILES.items():
        source_path = PROJECT_ROOT / source
        dest_path = PROJECT_ROOT / dest

        if not source_path.exists():
            print(f"{source:<45} MISSING")
            continue

        shutil.copy2(source_path, dest_path)
        rows = count_rows(dest_path)
        total_rows += rows
        print(f"{source:<45} {dest:<35} {rows:>8}")

    print("-" * 90)
    print(f"{'Total':<80} {total_rows:>8}")

    print("\n" + "=" * 60)
    print("FILES READY FOR MANUAL UPLOAD")
    print("=" * 60)
    print(f"\nLocation: {sheets_dir}/")
    print("\nFiles:")
    for dest in SOURCE_FILES.values():
        print(f"  - {Path(dest).name}")

    print("\n" + "-" * 60)
    print("INSTRUCTIONS FOR GOOGLE SHEETS:")
    print("-" * 60)
    print("""
1. Go to sheets.google.com
2. Create new spreadsheet: "NusaCommerce Analytics - Looker Studio"
3. For each CSV file:
   a. File > Import > Upload
   b. Select the CSV file
   c. Choose "Insert new sheet(s)"
   d. Click Import
4. Rename each sheet tab to match the file name

INSTRUCTIONS FOR LOOKER STUDIO:
1. Go to lookerstudio.google.com
2. Create new report
3. Add data source > Google Sheets
4. Select "NusaCommerce Analytics - Looker Studio"
5. Add each sheet as a separate data source
""")


if __name__ == "__main__":
    main()
