# NusaCommerce Analytics 🇮🇩

> End-to-end Data Analytics portfolio project — dari raw e-commerce data ke dua dashboard publik dan insight deck McKinsey-style, menggunakan PostgreSQL, Python, Tableau Public, dan Looker Studio.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat-square&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat-square&logo=tableau&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-Studio-4285F4?style=flat-square&logo=google&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-336791?style=flat-square&logo=postgresql&logoColor=white)
![pandas](https://img.shields.io/badge/pandas-2.x-150458?style=flat-square&logo=pandas&logoColor=white)

**Status: COMPLETED ✅**

---

## 📊 Live Dashboards

| Dashboard | Platform | Audience | Link |
|-----------|----------|----------|------|
| Executive Dashboard | Tableau Public | C-Level / Decision Maker | [🔗 View](https://public.tableau.com/app/profile/agatha.silalahi/viz/NusaCommerceExecutiveDashboard/Dashboard1) |
| Operational Dashboard | Looker Studio | Tim Operasional | [🔗 View](https://datastudio.google.com/reporting/617f29b4-3925-4943-8729-68fd4bfff227) |

---

## 🔍 Key Findings

- **Revenue Rp948M** selama 24 bulan (Des 2023–Nov 2025), CAGR +23% YoY — peak Agustus 2024 Rp71M
- **Jawa Barat 25.7%** total revenue; 3 provinsi teratas (Jabar, Banten, DKI) = 56% revenue nasional
- **29% pelanggan** kategori Hibernating + Lost membutuhkan win-back campaign; 35% Champions + Loyal menghasilkan mayoritas revenue

---

## 📈 Key Metrics

| Metric | Value |
|--------|-------|
| Total Revenue | Rp 948M |
| Total Orders (Selesai) | 16,045 |
| Total Orders (Semua Status) | 18,868 |
| Average Order Value | Rp 59K |
| Total Customers | 424 |
| Active Customers (RFM) | 404 |
| Provinsi Aktif | 33 |
| Periode Analisis | Des 2023 – Nov 2025 |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA PIPELINE                            │
│                                                                 │
│  Kaggle Dataset          Python (pandas)       PostgreSQL 16    │
│  ──────────────  →   ─────────────────────  →  ─────────────── │
│  bakitacos/             ingest.py                5 tabel        │
│  indonesia-e-commerce   Faker id_ID enrichment   7 views        │
│  -sales-and-shipping    20,848 baris raw         16,045 selesai │
│  -20232025                                                      │
│                               │                                 │
│                               ▼                                 │
│                    Advanced SQL Analytics                       │
│                    ──────────────────────                       │
│                    CTEs · Window Functions                      │
│                    RFM NTILE · Revenue Trend                    │
│                    Shipping · Payment · Category                │
│                                                                 │
│          ┌────────────────────┴────────────────────┐            │
│          ▼                                         ▼            │
│   Tableau Public                          Looker Studio         │
│   ─────────────                           ─────────────         │
│   Executive Dashboard                     Operational Dashboard │
│   Z-pattern layout                        Google Sheets source  │
│   dashboard_executive_clean.csv           4 tabs CSV upload     │
│                                                                 │
│                               ▼                                 │
│                  Insight Deck PDF (McKinsey Style)              │
│                  7 slides · Bahasa Indonesia · C-level          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
nusacommerce-analytics/
├── data/
│   ├── raw/                         # Source: all_months_clean.csv (3.7MB)
│   ├── exports/                     # SQL query exports (10 CSV files)
│   ├── sheets/                      # Google Sheets ready CSVs (4 files)
│   ├── tableau/                     # Tableau formatted exports
│   └── insights/                    # Key metrics documentation
├── sql/
│   ├── 01_schema.sql                # Database schema (5 tables)
│   ├── 01_data_quality.sql          # Data quality & profiling
│   ├── 02_revenue_trend.sql         # Revenue & MoM analysis
│   ├── 03_rfm_segmentation.sql      # RFM customer segmentation
│   ├── 04_shipping_performance.sql  # Logistics analysis
│   ├── 05_payment_analysis.sql      # Payment method breakdown
│   ├── 06_category_analysis.sql     # Product category analysis
│   └── 07_views_dashboard_prep.sql  # 7 dashboard-ready views
├── scripts/
│   ├── ingest.py                    # CSV → PostgreSQL pipeline
│   ├── export_tableau_csv.py        # PostgreSQL view → Tableau CSV
│   ├── prepare_for_sheets.py        # Google Sheets export
│   └── verify_data_sources.py       # Data lineage verification
├── outputs/
│   └── NusaCommerce_Insight_Deck.pdf
├── docs/
│   └── SHEETS_SETUP.md
├── dashboard/
└── notebooks/
```

---

## 🗄️ Database Schema

```
customers (424 rows)          products (679 rows)
├── customer_id (PK)          ├── product_id (PK)
├── customer_name             ├── category_name
├── city, province, phone     └── num_categories

shipping_methods (45 rows)    payments (18,868 rows)
├── shipping_id (PK)          ├── payment_id (PK)
├── courier_name              ├── order_id (FK)
└── service_type              ├── payment_method
                              ├── discount_amount
orders (18,868 rows)          ├── shipping_paid_by_buyer
├── order_id (PK)             ├── total_payment
├── customer_id (FK)          └── estimated_shipping_cost
├── product_id (FK)
├── shipping_id (FK)          Views (7):
├── status                    ├── vw_dashboard_executive (16,045)
├── order_timestamp           ├── vw_revenue_monthly     (588)
└── year_month                ├── vw_rfm_summary         (404)
                              ├── vw_shipping_summary    (45)
                              ├── vw_category_summary    (640)
                              ├── vw_payment_summary     (12)
                              └── vw_province_summary    (34)
```

---

## ⭐ SQL Highlight — RFM Segmentation (NTILE + Window Functions)

```sql
-- sql/03_rfm_segmentation.sql (simplified showcase)
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(order_timestamp::date)                AS last_order_date,
        COUNT(DISTINCT order_id)                  AS frequency,
        SUM(total_payment)                        AS monetary,
        CURRENT_DATE - MAX(order_timestamp::date) AS recency_days
    FROM orders
    WHERE status = 'Selesai'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days ASC)  AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC)    AS f_score,
        NTILE(4) OVER (ORDER BY monetary DESC)     AS m_score
    FROM rfm_base
)
SELECT segment, COUNT(*) AS customer_count,
       ROUND(AVG(monetary), 0) AS avg_monetary
FROM rfm_scores
GROUP BY segment
ORDER BY avg_monetary DESC;
```

Output: 404 pelanggan aktif tersegmentasi — Champions (86), Loyal (55), Hibernating (61), Lost (56).

---

## 🚀 Quick Start

```bash
# 1. Clone & setup environment
git clone https://github.com/Agathahah/nusacommerce-analytics.git
cd nusacommerce-analytics
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 2. Setup PostgreSQL (Mac via Homebrew)
brew install postgresql@16
brew services start postgresql@16
createdb nusacommerce
psql -d nusacommerce -f sql/01_schema.sql

# 3. Download dataset dari Kaggle
kaggle datasets download -d bakitacos/indonesia-e-commerce-sales-and-shipping-20232025 \
  --path data/raw/ --unzip

# 4. Ingest ke PostgreSQL
python scripts/ingest.py

# 5. Jalankan SQL analytics
psql -d nusacommerce -f sql/02_revenue_trend.sql
psql -d nusacommerce -f sql/03_rfm_segmentation.sql
psql -d nusacommerce -f sql/07_views_dashboard_prep.sql

# 6. Export untuk Tableau
python scripts/export_tableau_csv.py

# 7. Verifikasi semua data source
python scripts/verify_data_sources.py
```

---

## 📦 Dataset

**Indonesia E-Commerce Sales & Shipping 2023–2025**
- Source: [Kaggle — bakitacos/indonesia-e-commerce-sales-and-shipping-20232025](https://www.kaggle.com/datasets/bakitacos/indonesia-e-commerce-sales-and-shipping-20232025)
- Format: CSV semicolon-separated, kolom Bahasa Indonesia
- Raw: 20,848 baris · 19 kolom · file all_months_clean.csv
- Setelah filter status Selesai: 16,045 transaksi untuk analisis
- Catatan: Data simulasi e-commerce Indonesia (bukan data Shopee resmi)

---

## 🛠️ Tech Stack

| Layer | Tools |
|-------|-------|
| Data Ingestion | Python, Kaggle API, pandas, SQLAlchemy, psycopg2 |
| Data Enrichment | Faker id_ID (customer_name, phone) |
| Database | PostgreSQL 16 (Homebrew Mac), DBeaver Community |
| Analytics | SQL (CTEs, Window Functions, NTILE, RFM) |
| Visualization | Tableau Public, Looker Studio, Google Sheets |
| PDF Generation | reportlab |
| Version Control | Git, GitHub |

---

## 👩‍💻 Author

**Agatha Silalahi**
Data Scientist · Bank Indonesia Institute (BINS)
S2 Data Science, Universitas Indonesia · AI/ML Engineering, Pacmann

[![GitHub](https://img.shields.io/badge/GitHub-Agathahah-181717?style=flat-square&logo=github)](https://github.com/Agathahah)
[![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat-square&logo=tableau)](https://public.tableau.com/app/profile/agatha.silalahi)

---

## 📄 License

MIT

---

*Data simulasi e-commerce Indonesia. Project ini bagian dari portfolio Data Analyst untuk mendemonstrasikan kemampuan end-to-end: ingestion pipeline, SQL kompleks, dan storytelling visual.*
