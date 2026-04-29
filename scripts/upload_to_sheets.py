#!/usr/bin/env python3
"""
Upload NusaCommerce Analytics CSVs to Google Sheets for Looker Studio.
"""

import os
import sys
import pandas as pd
import gspread
from pathlib import Path

SPREADSHEET_NAME = "NusaCommerce Analytics - Looker Studio"

CSV_FILES = {
    "Revenue Monthly": "data/exports/dashboard_revenue_monthly.csv",
    "RFM Summary": "data/exports/dashboard_rfm_summary.csv",
    "Shipping Summary": "data/exports/dashboard_shipping_summary.csv",
    "Category Analysis": "data/exports/category_analysis.csv",
}

CREDENTIALS_PATHS = [
    Path.home() / ".config" / "gspread" / "service_account.json",
    Path.cwd() / "credentials.json",
    Path(__file__).parent.parent / "credentials.json",
]


def find_credentials():
    """Find service account credentials file."""
    for path in CREDENTIALS_PATHS:
        if path.exists():
            return path
    return None


def get_client():
    """Get authenticated gspread client."""
    creds_path = find_credentials()
    if creds_path:
        print(f"Using credentials: {creds_path}")
        return gspread.service_account(filename=str(creds_path))

    print("Trying default gspread authentication...")
    return gspread.service_account()


def upload_csv_to_sheet(worksheet, csv_path):
    """Upload CSV data to a worksheet."""
    df = pd.read_csv(csv_path)
    df = df.fillna("")

    for col in df.select_dtypes(include=['float64']).columns:
        df[col] = df[col].apply(lambda x: round(x, 2) if x != "" else x)

    data = [df.columns.tolist()] + df.values.tolist()

    worksheet.clear()
    worksheet.update(data, value_input_option='RAW')

    return len(df)


def main():
    print("Authenticating with Google Sheets...")
    try:
        gc = get_client()
    except Exception as e:
        print(f"\nAuthentication failed: {e}")
        print("\nTo set up credentials:")
        print("1. Create a Google Cloud Service Account")
        print("2. Download the JSON key file")
        print("3. Save it to one of these locations:")
        for path in CREDENTIALS_PATHS:
            print(f"   - {path}")
        sys.exit(1)

    try:
        spreadsheet = gc.open(SPREADSHEET_NAME)
        print(f"Found existing spreadsheet: {SPREADSHEET_NAME}")
    except gspread.SpreadsheetNotFound:
        print(f"Creating new spreadsheet: {SPREADSHEET_NAME}")
        spreadsheet = gc.create(SPREADSHEET_NAME)
        spreadsheet.share(None, perm_type='anyone', role='reader')

    existing_sheets = [ws.title for ws in spreadsheet.worksheets()]

    for tab_name, csv_path in CSV_FILES.items():
        csv_full_path = Path(__file__).parent.parent / csv_path

        if not csv_full_path.exists():
            print(f"  Skipping {tab_name}: {csv_path} not found")
            continue

        if tab_name in existing_sheets:
            worksheet = spreadsheet.worksheet(tab_name)
            print(f"  Updating tab: {tab_name}")
        else:
            worksheet = spreadsheet.add_worksheet(title=tab_name, rows=1000, cols=30)
            print(f"  Creating tab: {tab_name}")

        row_count = upload_csv_to_sheet(worksheet, csv_full_path)
        print(f"    Uploaded {row_count} rows")

    if "Sheet1" in existing_sheets and len(existing_sheets) > 1:
        try:
            spreadsheet.del_worksheet(spreadsheet.worksheet("Sheet1"))
            print("  Removed default Sheet1")
        except Exception:
            pass

    print(f"\nSpreadsheet URL: {spreadsheet.url}")
    print("\nNext steps:")
    print("1. Open Looker Studio (lookerstudio.google.com)")
    print("2. Create new report > Add data > Google Sheets")
    print("3. Select the spreadsheet and connect each tab")

    return spreadsheet.url


if __name__ == "__main__":
    main()
