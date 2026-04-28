# NusaCommerce Analytics

Portfolio project: SQL kompleks + dashboard publik berbasis Indonesia E-Commerce Sales 2023–2025.

## Status

**COMPLETED**

## Live Dashboards

- **Tableau Public:** [NusaCommerce Executive Dashboard](https://public.tableau.com/app/profile/agatha.silalahi/viz/NusaCommerceExecutiveDashboard/Dashboard1)
- **Looker Studio:** [NusaCommerce Operational Dashboard](https://datastudio.google.com/reporting/617f29b4-3925-4943-8729-68fd4bfff227)

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Revenue | Rp 948M |
| Total Orders | 16,045 |
| Average Order Value | Rp 59K |
| Unique Customers | 404 |

## Key Insights

1. **Regional Dominance:** Jawa Barat leads with Rp244M revenue (25.7% share)
2. **Customer Segments:** 86 Champions contributing highest lifetime value
3. **Payment Preference:** Digital payments dominate at 61.98% vs COD 38.02%
4. **Peak Performance:** August 2024 achieved highest monthly revenue at Rp71M

## Stack

- **Database:** PostgreSQL 14
- **ETL:** Python (pandas, Faker, psycopg2)
- **Analytics:** SQL (CTEs, Window Functions, RFM Segmentation)
- **Visualization:** Tableau Public, Looker Studio

## Project Structure

```
nusacommerce-analytics/
├── data/
│   ├── raw/                    # Source CSV files
│   ├── exports/                # SQL query exports
│   ├── sheets/                 # Google Sheets ready CSVs
│   ├── tableau/                # Tableau formatted exports
│   └── insights/               # Key metrics documentation
├── sql/
│   ├── 01_schema.sql           # Database schema (5 tables)
│   ├── 01_data_quality.sql     # Data quality checks
│   ├── 02_revenue_trend.sql    # Revenue & MoM analysis
│   ├── 03_rfm_segmentation.sql # RFM customer segmentation
│   ├── 04_shipping_performance.sql
│   ├── 05_payment_analysis.sql
│   ├── 06_category_analysis.sql
│   └── 07_views_dashboard_prep.sql  # Dashboard-ready views
├── scripts/
│   ├── ingest.py               # CSV to PostgreSQL ingestion
│   ├── prepare_for_sheets.py   # Google Sheets export
│   └── export_tableau_csv.py   # Tableau formatted export
├── docs/
│   └── SHEETS_SETUP.md         # Google Sheets integration guide
├── dashboard/                  # Dashboard assets
├── notebooks/                  # Jupyter notebooks
└── .planning/                  # Project planning docs
```

## Database Schema

```
customers (424 rows)
├── customer_id (PK)
├── customer_name, city, province, phone

products (679 rows)
├── product_id (PK)
├── category_name, num_categories

shipping_methods (45 rows)
├── shipping_id (PK)
├── method_name, courier_name, service_type

orders (18,868 rows)
├── order_id (PK)
├── customer_id (FK), product_id (FK), shipping_id (FK)
├── total_qty, total_weight_gr, total_returned_qty
├── status, cancellation_reason, order_timestamp, year_month

payments (18,868 rows)
├── payment_id (PK), order_id (FK)
├── payment_method, discount_amount, shipping_paid_by_buyer
├── estimated_shipping_discount, total_payment, estimated_shipping_cost
```

## Quick Start

```bash
# Setup database
psql -U postgres -c "CREATE DATABASE nusacommerce;"
psql -d nusacommerce -f sql/01_schema.sql

# Ingest data
python scripts/ingest.py

# Run analytics
psql -d nusacommerce -f sql/02_revenue_trend.sql

# Export for Tableau
python scripts/export_tableau_csv.py
```

## License

MIT
