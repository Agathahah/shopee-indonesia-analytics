# Shopee Indonesia Analytics 🇮🇩

**56% revenue e-commerce Indonesia hanya berasal dari 3 provinsi.**
Dari 20.000+ transaksi Shopee Indonesia: 29% pelanggan sudah churn,
COD masih 38% risiko margin, dan revenue sangat bergantung pada
segmen Champions yang kecil.

Project ini membangun end-to-end analytics pipeline untuk mengidentifikasi
revenue leakage dan growth opportunity dari data transaksi Shopee Indonesia.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat-square&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat-square&logo=tableau&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-Studio-4285F4?style=flat-square&logo=google&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-336791?style=flat-square&logo=postgresql&logoColor=white)
![pandas](https://img.shields.io/badge/pandas-2.x-150458?style=flat-square&logo=pandas&logoColor=white)

---

## 📊 Live Dashboards

| Dashboard | Platform | Link |
|-----------|----------|------|
| Executive Dashboard | Tableau Public | [🔗 View](https://public.tableau.com/app/profile/agatha.silalahi/viz/NusaCommerceExecutiveDashboard/Dashboard1) |
| Operational Dashboard | Looker Studio | [🔗 View](https://datastudio.google.com/reporting/617f29b4-3925-4943-8729-68fd4bfff227) |

---

## 🔍 Key Insights

> Temuan dari analisis 20.848 transaksi Shopee Indonesia 2023–2025.

**Geografis — Revenue sangat terkonsentrasi:**
- Jawa Barat: Rp244M (25.7% total revenue)
- Top 3 provinsi (Jabar + Banten + DKI): **56% revenue nasional**
- 30 provinsi lainnya berbagi 44% — potensi ekspansi besar yang belum digarap

**Customer — Revenue bocor diam-diam:**
- 86 Champions menghasilkan revenue tidak proporsional dibanding segmen lain
- **29% pelanggan (117 orang) sudah Hibernating/Lost** — tanpa program reaktivasi
- 35% Champions + Loyal = mayoritas revenue dari basis pelanggan kecil

**Payment — Sinyal masalah margin:**
- **COD masih 38%** dari total transaksi → risiko retur tinggi, menekan unit economics
- Digital payment 62% — potensi dorong ke 75% dengan insentif cashless

---

## 💡 Business Recommendations

| Prioritas | Rekomendasi | Estimasi Impact |
|-----------|-------------|-----------------|
| 🔴 Tinggi | Win-back campaign 117 pelanggan Hibernating/Lost | Revenue recovery |
| 🟡 Sedang | Realokasi 30% budget iklan ke Sumatera Utara & Kalimantan Timur | Market expansion |
| 🟡 Sedang | Insentif cashless → turunkan COD dari 38% ke target 25% | Margin improvement |

---

## 🏗️ Architecture
Kaggle Dataset (bakitacos)
Data transaksi seller Shopee Indonesia 2023–2025
│
▼
Python Pipeline (pandas + Faker id_ID)
│  ingest.py — validasi, enrichment, loading
▼
PostgreSQL 16 — database: nusacommerce
│  5 tabel: orders, customers, products,
│           shipping_methods, payments
│  20,848 baris raw → 16,045 status Selesai
▼
SQL Analytics (7 files)
│  CTEs · Window Functions · NTILE
│  RFM Segmentation · Revenue Trend
│  Shipping · Payment · Category
▼
7 PostgreSQL Views (single source of truth)
│
├──────────────────────┐
▼                      ▼
Tableau Public          Looker Studio
Executive Dashboard     Operational Dashboard
Z-pattern layout        Google Sheets connector
│                      │
└──────────┬────────────┘
▼
Insight Deck PDF (7 slides, McKinsey style)

---

## 📁 Project Structure
shopee-indonesia-analytics/
├── data/
│   ├── raw/              # all_months_clean.csv (3.7MB, 20,848 baris)
│   ├── exports/          # 10 CSV dari SQL analytics
│   ├── sheets/           # 4 CSV untuk Looker Studio
│   └── tableau/          # dashboard_executive_clean.csv (16,045 baris)
├── sql/
│   ├── 01_schema.sql
│   ├── 01_data_quality.sql
│   ├── 02_revenue_trend.sql
│   ├── 03_rfm_segmentation.sql      ★ NTILE + Window Functions
│   ├── 04_shipping_performance.sql
│   ├── 05_payment_analysis.sql
│   ├── 06_category_analysis.sql
│   └── 07_views_dashboard_prep.sql  ★ 7 views
├── scripts/
│   ├── ingest.py
│   ├── export_tableau_csv.py
│   ├── prepare_for_sheets.py
│   └── verify_data_sources.py       ★ data lineage check
├── docs/
│   └── SHEETS_SETUP.md
└── outputs/
└── NusaCommerce_Insight_Deck.pdf

---

## 🗄️ Database Schema
orders (18,868 rows)          customers (424 rows)
├── order_id (PK)             ├── customer_id (PK)
├── customer_id (FK)          ├── customer_name (Faker id_ID)
├── product_id (FK)           └── city, province, phone
├── shipping_id (FK)
├── status                    products (679 rows)
├── order_timestamp           ├── product_id (PK)
└── year_month                └── category_name
payments (18,868 rows)        Views (7):
├── payment_method            ├── vw_dashboard_executive (16,045)
├── total_payment             ├── vw_revenue_monthly     (588)
└── discount_amount           ├── vw_rfm_summary         (404)
├── vw_shipping_summary    (45)
shipping_methods (45 rows)    ├── vw_category_summary    (640)
├── courier_name              ├── vw_payment_summary     (12)
└── service_type              └── vw_province_summary    (34)

---

## ⭐ SQL Highlight — RFM Segmentation

```sql
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
-- Output: Champions 86, Loyal 55, Hibernating 61, Lost 56
```

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

## 🚀 Quick Start

```bash
git clone https://github.com/Agathahah/shopee-indonesia-analytics.git
cd shopee-indonesia-analytics
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Setup PostgreSQL
brew install postgresql@16 && brew services start postgresql@16
createdb nusacommerce
psql -d nusacommerce -f sql/01_schema.sql

# Download dataset
kaggle datasets download -d bakitacos/indonesia-e-commerce-sales-and-shipping-20232025 \
  --path data/raw/ --unzip

# Pipeline
python scripts/ingest.py
psql -d nusacommerce -f sql/07_views_dashboard_prep.sql
python scripts/export_tableau_csv.py

# Verifikasi
python scripts/verify_data_sources.py
```

---

## 📦 Dataset

**Indonesia E-Commerce Sales & Shipping 2023–2025**
- Source: [Kaggle — bakitacos/indonesia-e-commerce-sales-and-shipping-20232025](https://www.kaggle.com/datasets/bakitacos/indonesia-e-commerce-sales-and-shipping-20232025)
- Deskripsi: Data export transaksi seller Shopee Indonesia, dipublikasikan di Kaggle untuk keperluan edukasi dan riset
- Format: CSV semicolon-separated, kolom Bahasa Indonesia
- Raw: 20,848 baris · 19 kolom · file all_months_clean.csv
- Filtered (status Selesai): 16,045 transaksi
- Customer name & phone: di-enrich menggunakan Faker id_ID

---

## 🛠️ Tech Stack

| Layer | Tools |
|-------|-------|
| Ingestion | Python, Kaggle API, pandas, SQLAlchemy, psycopg2 |
| Enrichment | Faker id_ID (customer_name, phone) |
| Database | PostgreSQL 16, DBeaver Community |
| Analytics | SQL — CTEs, Window Functions, NTILE, RFM |
| Visualization | Tableau Public, Looker Studio, Google Sheets |
| PDF | reportlab |

---

## 👩‍💻 Author

**Agatha Silalahi** — Data Scientist, Bank Indonesia Institute (BINS)
S2 Data Science Universitas Indonesia · AI/ML Engineering Pacmann

[![GitHub](https://img.shields.io/badge/GitHub-Agathahah-181717?style=flat-square&logo=github)](https://github.com/Agathahah)
[![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat-square&logo=tableau)](https://public.tableau.com/app/profile/agatha.silalahi)

---

## 📄 License

MIT

---
*Data export transaksi Shopee Indonesia (Kaggle) untuk keperluan edukasi dan riset.*
