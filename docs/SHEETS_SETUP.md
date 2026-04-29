# Google Sheets Setup for Looker Studio

This guide explains how to set up Google Sheets as a data source for Looker Studio dashboards.

## Prerequisites

- Google Cloud Platform account
- Python with gspread installed (already in requirements.txt)

## Step 1: Create Google Cloud Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the **Google Sheets API** and **Google Drive API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sheets API" and enable it
   - Search for "Google Drive API" and enable it

4. Create a Service Account:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "Service Account"
   - Name: `nusacommerce-sheets`
   - Click "Create and Continue"
   - Role: "Editor" (or skip)
   - Click "Done"

5. Create and download the key:
   - Click on the service account you just created
   - Go to "Keys" tab
   - Click "Add Key" > "Create new key"
   - Select "JSON" format
   - Download the file

## Step 2: Install Credentials

Save the downloaded JSON file to one of these locations:

**Option A (Recommended):** Global gspread config
```bash
mkdir -p ~/.config/gspread
mv ~/Downloads/your-key-file.json ~/.config/gspread/service_account.json
```

**Option B:** Project directory
```bash
mv ~/Downloads/your-key-file.json ~/nusacommerce-analytics/credentials.json
```

> **Security Note:** Never commit credentials.json to git. It's already in .gitignore.

## Step 3: Run the Upload Script

```bash
cd ~/nusacommerce-analytics
source venv/bin/activate
python scripts/upload_to_sheets.py
```

The script will:
1. Create a spreadsheet named "NusaCommerce Analytics - Looker Studio"
2. Upload 4 CSV files as separate tabs:
   - Revenue Monthly
   - RFM Summary
   - Shipping Summary
   - Category Analysis
3. Print the spreadsheet URL

## Step 4: Connect to Looker Studio

1. Open [Looker Studio](https://lookerstudio.google.com/)
2. Click "Create" > "Report"
3. Add data source > Google Sheets
4. Find "NusaCommerce Analytics - Looker Studio"
5. Select each tab as a separate data source
6. Build your dashboard!

## Refreshing Data

To update the Google Sheets with fresh data:

```bash
# Re-run SQL exports
psql -U nusacommerce_user -d nusacommerce -c "\COPY (SELECT * FROM vw_revenue_monthly) TO 'data/exports/dashboard_revenue_monthly.csv' CSV HEADER;"
psql -U nusacommerce_user -d nusacommerce -c "\COPY (SELECT * FROM vw_rfm_summary) TO 'data/exports/dashboard_rfm_summary.csv' CSV HEADER;"
psql -U nusacommerce_user -d nusacommerce -c "\COPY (SELECT * FROM vw_shipping_summary) TO 'data/exports/dashboard_shipping_summary.csv' CSV HEADER;"
psql -U nusacommerce_user -d nusacommerce -f sql/06_category_analysis.sql -o data/exports/category_analysis.csv --csv

# Upload to Sheets
python scripts/upload_to_sheets.py
```

Looker Studio will automatically pick up the updated data.

## Troubleshooting

### "Authentication failed"
- Verify credentials.json exists in the correct location
- Check that the service account has Sheets and Drive API enabled

### "SpreadsheetNotFound" when opening
- The spreadsheet is created with service account ownership
- Share it with your personal email to view in browser

### "Quota exceeded"
- Google Sheets API has rate limits
- Wait a few minutes and try again
