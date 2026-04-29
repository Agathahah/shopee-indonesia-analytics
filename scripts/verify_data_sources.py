"""
NusaCommerce Analytics — Data Source Verification Script
=========================================================
Script ini memverifikasi SEMUA sumber data yang benar-benar digunakan
dalam project NusaCommerce Analytics.

Jalankan dari root folder project:
    cd ~/nusacommerce-analytics
    source .venv/bin/activate
    python scripts/verify_data_sources.py

Output: ringkasan lengkap semua data source, row counts, kolom, dan origin.
"""

import sys
import hashlib
from pathlib import Path

# ── Warna terminal ────────────────────────────────────────────────────────────
GREEN  = "\033[92m"
YELLOW = "\033[93m"
RED    = "\033[91m"
BLUE   = "\033[94m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

def ok(msg):   print(f"  {GREEN}✅ {msg}{RESET}")
def warn(msg): print(f"  {YELLOW}⚠️  {msg}{RESET}")
def err(msg):  print(f"  {RED}❌ {msg}{RESET}")
def head(msg): print(f"\n{BOLD}{BLUE}{'─'*60}\n  {msg}\n{'─'*60}{RESET}")
def info(msg): print(f"     {msg}")


# ══════════════════════════════════════════════════════════════════════════════
# 1. RAW SOURCE FILE
# ══════════════════════════════════════════════════════════════════════════════
def check_raw_source():
    head("1. RAW SOURCE FILE  (data/raw/)")

    raw_dir = Path("data/raw")
    if not raw_dir.exists():
        err("Folder data/raw/ tidak ditemukan")
        return

    # Main file
    main_file = raw_dir / "all_months_clean.csv"
    if main_file.exists():
        size_mb = main_file.stat().st_size / 1_048_576
        # hitung baris
        with open(main_file, "r", encoding="utf-8") as f:
            lines = sum(1 for _ in f)
        ok(f"all_months_clean.csv  ({size_mb:.1f} MB, {lines:,} baris termasuk header)")

        # baca header untuk konfirmasi separator dan kolom
        with open(main_file, "r", encoding="utf-8") as f:
            header = f.readline().strip()
        sep = ";" if ";" in header else ","
        cols = header.split(sep)
        info(f"Separator : '{sep}'")
        info(f"Kolom ({len(cols)}):")
        for i, c in enumerate(cols, 1):
            info(f"  {i:2}. {c}")

        # checksum untuk reproducibility
        md5 = hashlib.md5(open(main_file, "rb").read()).hexdigest()
        info(f"MD5       : {md5}")
    else:
        err("all_months_clean.csv TIDAK DITEMUKAN")

    # Sub-folders
    for folder in ["Clean_Dataset", "RAW_PUBLIC_Dataset"]:
        p = raw_dir / folder
        if p.exists():
            sub_files = list(p.rglob("*.csv"))
            ok(f"{folder}/  ({len(sub_files)} CSV di dalamnya)")
            for sf in sub_files[:5]:
                size_kb = sf.stat().st_size / 1024
                info(f"    {sf.relative_to(raw_dir)}  ({size_kb:.0f} KB)")
        else:
            warn(f"{folder}/ tidak ada")


# ══════════════════════════════════════════════════════════════════════════════
# 2. POSTGRESQL DATABASE
# ══════════════════════════════════════════════════════════════════════════════
def check_postgresql():
    head("2. POSTGRESQL DATABASE  (nusacommerce)")

    try:
        import psycopg2
    except ImportError:
        err("psycopg2 tidak terinstall — jalankan: pip install psycopg2-binary")
        return

    # Coba beberapa kombinasi koneksi yang pernah dipakai di project ini
    connection_attempts = [
        {"dbname": "nusacommerce", "user": "agathasilalahi",   "host": "localhost", "port": 5432},
        {"dbname": "nusacommerce", "user": "nusacommerce_user","host": "localhost",
         "password": "nusacommerce2025", "port": 5432},
    ]

    conn = None
    for params in connection_attempts:
        try:
            conn = psycopg2.connect(**params, connect_timeout=5)
            ok(f"Koneksi berhasil  (user={params['user']})")
            break
        except Exception:
            pass

    if conn is None:
        err("Tidak bisa konek ke PostgreSQL. Pastikan service berjalan:")
        info("brew services start postgresql@16")
        return

    cur = conn.cursor()

    # Tabel
    cur.execute("""
        SELECT tablename, pg_total_relation_size(quote_ident(tablename))
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename;
    """)
    tables = cur.fetchall()
    info(f"\n  Tabel ({len(tables)}):")
    for tbl, size in tables:
        cur.execute(f"SELECT COUNT(*) FROM {tbl}")
        cnt = cur.fetchone()[0]
        info(f"    {tbl:<25} {cnt:>7,} baris   ({size/1024:.0f} KB)")

    # Views
    cur.execute("""
        SELECT viewname FROM pg_views
        WHERE schemaname = 'public' AND viewname LIKE 'vw_%'
        ORDER BY viewname;
    """)
    views = cur.fetchall()
    info(f"\n  Views ({len(views)}):")
    for (v,) in views:
        cur.execute(f"SELECT COUNT(*) FROM {v}")
        cnt = cur.fetchone()[0]
        info(f"    {v:<30} {cnt:>7,} baris")

    conn.close()


# ══════════════════════════════════════════════════════════════════════════════
# 3. TABLEAU DATA SOURCE
# ══════════════════════════════════════════════════════════════════════════════
def check_tableau_source():
    head("3. TABLEAU DATA SOURCE  (data/tableau/)")

    tableau_dir = Path("data/tableau")
    if not tableau_dir.exists():
        err("Folder data/tableau/ tidak ditemukan")
        return

    files = sorted(tableau_dir.glob("*.csv")) + sorted(tableau_dir.glob("*.txt"))
    if not files:
        err("Tidak ada file di data/tableau/")
        return

    try:
        import pandas as pd
    except ImportError:
        err("pandas tidak terinstall")
        return

    for f in files:
        size_kb = f.stat().st_size / 1024
        if f.suffix == ".csv":
            try:
                df = pd.read_csv(f, nrows=0)
                # hitung baris tanpa load semua
                with open(f) as fh:
                    rows = sum(1 for _ in fh) - 1
                ok(f"{f.name:<40} {rows:>7,} baris  {size_kb:.0f} KB  ({len(df.columns)} kolom)")
                info(f"    Kolom: {list(df.columns)[:6]}{'...' if len(df.columns)>6 else ''}")
            except Exception as e:
                warn(f"{f.name}  — error baca: {e}")
        else:
            ok(f"{f.name:<40} {size_kb:.0f} KB  (pipe-separated backup)")


# ══════════════════════════════════════════════════════════════════════════════
# 4. LOOKER STUDIO DATA SOURCE (Google Sheets)
# ══════════════════════════════════════════════════════════════════════════════
def check_looker_source():
    head("4. LOOKER STUDIO DATA SOURCE  (data/sheets/  &  Google Sheets)")

    # Cek file lokal
    sheets_dir = Path("data/sheets")
    if sheets_dir.exists():
        csvs = sorted(sheets_dir.glob("*.csv"))
        if csvs:
            try:
                import pandas as pd
                for f in csvs:
                    df = pd.read_csv(f, nrows=0)
                    with open(f) as fh:
                        rows = sum(1 for _ in fh) - 1
                    ok(f"{f.name:<40} {rows:>7,} baris  ({len(df.columns)} kolom)")
            except Exception as e:
                warn(f"Error baca sheets CSV: {e}")
        else:
            warn("data/sheets/ ada tapi kosong")
    else:
        warn("data/sheets/ tidak ditemukan — upload ke Google Sheets dilakukan manual")

    # Info Google Sheets
    info("")
    info("Google Sheets (manual upload, koneksi ke Looker Studio):")
    info("  URL  : https://docs.google.com/spreadsheets/d/1xgA86FiKKJJcH0qDe-qLbsP5bny9mkW9AolIwGqwRGI")
    info("  Tabs : revenue_monthly | rfm_summary | shipping_summary | category_analysis")
    info("  Akses: Anyone with link (public)")


# ══════════════════════════════════════════════════════════════════════════════
# 5. EXPORTED ANALYTICS CSVs
# ══════════════════════════════════════════════════════════════════════════════
def check_exports():
    head("5. EXPORTED ANALYTICS CSVs  (data/exports/)")

    exports_dir = Path("data/exports")
    if not exports_dir.exists():
        err("Folder data/exports/ tidak ditemukan")
        return

    expected = {
        "dashboard_executive.csv":      "vw_dashboard_executive  → Tableau source awal",
        "dashboard_revenue_monthly.csv":"vw_revenue_monthly      → Looker Studio tab 1",
        "dashboard_rfm_summary.csv":    "vw_rfm_summary          → Looker Studio tab 2",
        "dashboard_shipping_summary.csv":"vw_shipping_summary    → Looker Studio tab 3",
        "category_analysis.csv":        "sql/06_category_analysis.sql → Looker Studio tab 4",
        "data_quality_report.csv":      "sql/01_data_quality.sql → profiling hasil",
        "revenue_trend.csv":            "sql/02_revenue_trend.sql",
        "rfm_segmentation.csv":         "sql/03_rfm_segmentation.sql",
        "shipping_performance.csv":     "sql/04_shipping_performance.sql",
        "payment_analysis.csv":         "sql/05_payment_analysis.sql",
    }

    try:
        import pandas as pd
    except ImportError:
        pd = None

    for fname, desc in expected.items():
        fpath = exports_dir / fname
        if fpath.exists():
            size_kb = fpath.stat().st_size / 1024
            if pd:
                try:
                    df = pd.read_csv(fpath, nrows=0)
                    with open(fpath) as fh:
                        rows = sum(1 for _ in fh) - 1
                    ok(f"{fname}")
                    info(f"    {rows:>7,} baris  {size_kb:.0f} KB  → {desc}")
                except Exception:
                    ok(f"{fname}  ({size_kb:.0f} KB)  → {desc}")
            else:
                ok(f"{fname}  ({size_kb:.0f} KB)  → {desc}")
        else:
            warn(f"{fname} tidak ada  → {desc}")


# ══════════════════════════════════════════════════════════════════════════════
# 6. RINGKASAN LINEAGE
# ══════════════════════════════════════════════════════════════════════════════
def print_lineage():
    head("6. DATA LINEAGE — NusaCommerce Analytics")
    print(f"""
  {BOLD}SUMBER ASLI:{RESET}
    Kaggle Dataset: bakitacos/indonesia-e-commerce-sales-and-shipping-20232025
    File           : data/raw/all_months_clean.csv
    Format         : CSV semicolon-separated, Bahasa Indonesia
    Baris          : 18,868 (termasuk cancelled/returned)

  {BOLD}INGESTION:{RESET}
    scripts/ingest.py  →  PostgreSQL database: nusacommerce
    5 tabel: orders (18,868) | customers (404) | products (679)
           | shipping_methods (45) | payments (18,868)
    Enrichment: Faker('id_ID') untuk customer_name, phone

  {BOLD}SQL ANALYTICS  (hanya status=Selesai = 16,045 baris):{RESET}
    sql/02_revenue_trend.sql        → data/exports/revenue_trend.csv
    sql/03_rfm_segmentation.sql     → data/exports/rfm_segmentation.csv
    sql/04_shipping_performance.sql → data/exports/shipping_performance.csv
    sql/05_payment_analysis.sql     → data/exports/payment_analysis.csv
    sql/06_category_analysis.sql    → data/exports/category_analysis.csv

  {BOLD}POSTGRESQL VIEWS (single source of truth):{RESET}
    vw_dashboard_executive  (16,045 baris)  → Tableau
    vw_revenue_monthly      (588 baris)     → Looker Studio tab 1
    vw_rfm_summary          (404 baris)     → Looker Studio tab 2
    vw_shipping_summary     (45 baris)      → Looker Studio tab 3
    vw_category_summary     (640 baris)     → Looker Studio tab 4

  {BOLD}DASHBOARD DATA SOURCE:{RESET}
    Tableau Public  : data/tableau/dashboard_executive_clean.csv
                      (dari vw_dashboard_executive, 23 kolom, 16,045 baris)
    Looker Studio   : Google Sheets (manual upload dari data/exports/)
                      URL: https://docs.google.com/spreadsheets/d/
                           1xgA86FiKKJJcH0qDe-qLbsP5bny9mkW9AolIwGqwRGI

  {BOLD}CATATAN PENTING:{RESET}
    - Dataset adalah data SIMULASI (bukan data Shopee resmi)
    - Slug Kaggle yang BENAR: bakitacos/indonesia-e-commerce-sales-and-shipping-20232025
    - Slug 'dikisahkan/...' di README lama adalah SALAH — sudah/perlu dikoreksi
    - Nama 'NusaCommerce' adalah nama portfolio project, bukan nama platform asli
""")


# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print(f"\n{BOLD}{'═'*60}")
    print("  NusaCommerce Analytics — Data Source Verification")
    print(f"{'═'*60}{RESET}")

    # Cek kita di folder yang benar
    if not Path("data").exists():
        err("Jalankan dari root folder project: cd ~/nusacommerce-analytics")
        sys.exit(1)

    check_raw_source()
    check_postgresql()
    check_tableau_source()
    check_looker_source()
    check_exports()
    print_lineage()

    print(f"\n{BOLD}{'═'*60}")
    print("  Verifikasi selesai.")
    print(f"{'═'*60}{RESET}\n")
