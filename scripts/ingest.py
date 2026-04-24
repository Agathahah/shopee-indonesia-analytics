#!/usr/bin/env python3
"""
NusaCommerce Data Ingestion Script
Ingests raw CSV data into normalized PostgreSQL tables.
"""

import hashlib
import pandas as pd
import psycopg2
from faker import Faker

# Database connection config
DB_CONFIG = {
    'dbname': 'nusacommerce',
    'user': 'nusacommerce_user',
    'password': 'nusacommerce2025',
    'host': 'localhost'
}

CSV_PATH = 'data/raw/all_months_clean.csv'


def generate_id(value: str) -> str:
    """Generate MD5 hash ID (first 20 characters)."""
    return hashlib.md5(value.encode()).hexdigest()[:20]


def parse_shipping_method(method_name: str) -> tuple:
    """Parse courier_name and service_type from shipping method string."""
    if pd.isna(method_name) or not method_name:
        return (None, None)
    if '-' in method_name:
        parts = method_name.split('-', 1)
        return (parts[0].strip(), parts[1].strip())
    return (method_name.strip(), None)


def build_customers_df(df: pd.DataFrame) -> pd.DataFrame:
    """Build customers table with Faker-generated names and phones."""
    fake = Faker('id_ID')
    Faker.seed(42)

    unique_locations = df[['Kota/Kabupaten', 'Provinsi']].drop_duplicates()

    customers = []
    for _, row in unique_locations.iterrows():
        city = str(row['Kota/Kabupaten']).strip()
        province = str(row['Provinsi']).strip()
        customer_id = generate_id(city + province)
        customers.append({
            'customer_id': customer_id,
            'customer_name': fake.name(),
            'city': city,
            'province': province,
            'phone': fake.phone_number()
        })

    return pd.DataFrame(customers)


def build_products_df(df: pd.DataFrame) -> pd.DataFrame:
    """Build products table from unique product categories."""
    unique_categories = df[['product_categories', 'num_product_categories']].drop_duplicates(
        subset=['product_categories']
    )

    products = []
    for _, row in unique_categories.iterrows():
        category = str(row['product_categories']).strip()
        product_id = generate_id(category)
        num_cats = pd.to_numeric(row['num_product_categories'], errors='coerce')
        products.append({
            'product_id': product_id,
            'category_name': category,
            'num_categories': int(num_cats) if pd.notna(num_cats) else 1
        })

    return pd.DataFrame(products)


def build_shipping_methods_df(df: pd.DataFrame) -> pd.DataFrame:
    """Build shipping methods table from unique shipping options."""
    unique_methods = df['Opsi Pengiriman'].dropna().unique()

    shipping_methods = []
    for method in unique_methods:
        method_name = str(method).strip()
        if not method_name:
            continue
        shipping_id = generate_id(method_name)
        courier_name, service_type = parse_shipping_method(method_name)
        shipping_methods.append({
            'shipping_id': shipping_id,
            'method_name': method_name,
            'courier_name': courier_name,
            'service_type': service_type
        })

    return pd.DataFrame(shipping_methods)


def build_orders_df(df: pd.DataFrame, customers_df: pd.DataFrame,
                    products_df: pd.DataFrame, shipping_df: pd.DataFrame) -> pd.DataFrame:
    """Build orders table with foreign key mappings."""
    customer_lookup = dict(zip(
        customers_df['city'] + customers_df['province'],
        customers_df['customer_id']
    ))
    product_lookup = dict(zip(products_df['category_name'], products_df['product_id']))
    shipping_lookup = dict(zip(shipping_df['method_name'], shipping_df['shipping_id']))

    orders = []
    for _, row in df.iterrows():
        city = str(row['Kota/Kabupaten']).strip()
        province = str(row['Provinsi']).strip()
        category = str(row['product_categories']).strip()
        shipping_method = str(row['Opsi Pengiriman']).strip() if pd.notna(row['Opsi Pengiriman']) else ''

        customer_id = customer_lookup.get(city + province)
        product_id = product_lookup.get(category)
        shipping_id = shipping_lookup.get(shipping_method)

        if not all([customer_id, product_id, shipping_id]):
            continue

        order_timestamp = pd.to_datetime(row['Waktu Pesanan Dibuat'], errors='coerce')
        if pd.isna(order_timestamp):
            continue
        year_month = order_timestamp.strftime('%Y-%m')

        orders.append({
            'order_id': str(row['order_id']).strip(),
            'customer_id': customer_id,
            'product_id': product_id,
            'shipping_id': shipping_id,
            'total_qty': int(pd.to_numeric(row['total_qty'], errors='coerce') or 0),
            'total_weight_gr': int(pd.to_numeric(row['total_weight_gr'], errors='coerce') or 0),
            'total_returned_qty': int(pd.to_numeric(row['total_returned_qty'], errors='coerce') or 0),
            'status': str(row['Status Pesanan']).strip() if pd.notna(row['Status Pesanan']) else '',
            'cancellation_reason': str(row['Alasan Pembatalan']).strip() if pd.notna(row['Alasan Pembatalan']) and row['Alasan Pembatalan'] != '' else None,
            'order_timestamp': order_timestamp,
            'year_month': year_month,
            'source_file': str(row['source_file']).strip() if pd.notna(row['source_file']) else None
        })

    return pd.DataFrame(orders)


def build_payments_df(df: pd.DataFrame) -> pd.DataFrame:
    """Build payments table from payment-related columns."""
    payments = []
    for _, row in df.iterrows():
        order_id = str(row['order_id']).strip()

        payment_method = row['Metode Pembayaran']
        if pd.isna(payment_method) or payment_method == '':
            payment_method = 'Unknown'
        else:
            payment_method = str(payment_method).strip()

        payments.append({
            'order_id': order_id,
            'payment_method': payment_method,
            'discount_amount': pd.to_numeric(row['Total Diskon'], errors='coerce'),
            'shipping_paid_by_buyer': pd.to_numeric(row['Ongkos Kirim Dibayar oleh Pembeli'], errors='coerce'),
            'estimated_shipping_discount': pd.to_numeric(row['Estimasi Potongan Biaya Pengiriman'], errors='coerce'),
            'total_payment': pd.to_numeric(row['Total Pembayaran'], errors='coerce'),
            'estimated_shipping_cost': pd.to_numeric(row['Perkiraan Ongkos Kirim'], errors='coerce')
        })

    payments_df = pd.DataFrame(payments)
    numeric_cols = ['discount_amount', 'shipping_paid_by_buyer', 'estimated_shipping_discount',
                    'total_payment', 'estimated_shipping_cost']
    for col in numeric_cols:
        payments_df[col] = payments_df[col].fillna(0)

    return payments_df


def insert_customers(cursor, customers_df: pd.DataFrame) -> int:
    """Insert customers into database."""
    query = """
        INSERT INTO customers (customer_id, customer_name, city, province, phone)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """
    data = [tuple(row) for row in customers_df[['customer_id', 'customer_name', 'city', 'province', 'phone']].values]
    cursor.executemany(query, data)
    return len(data)


def insert_products(cursor, products_df: pd.DataFrame) -> int:
    """Insert products into database."""
    query = """
        INSERT INTO products (product_id, category_name, num_categories)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING
    """
    data = [tuple(row) for row in products_df[['product_id', 'category_name', 'num_categories']].values]
    cursor.executemany(query, data)
    return len(data)


def insert_shipping_methods(cursor, shipping_df: pd.DataFrame) -> int:
    """Insert shipping methods into database."""
    query = """
        INSERT INTO shipping_methods (shipping_id, method_name, courier_name, service_type)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """
    data = [tuple(row) for row in shipping_df[['shipping_id', 'method_name', 'courier_name', 'service_type']].values]
    cursor.executemany(query, data)
    return len(data)


def insert_orders(cursor, orders_df: pd.DataFrame) -> int:
    """Insert orders into database."""
    query = """
        INSERT INTO orders (order_id, customer_id, product_id, shipping_id, total_qty,
                           total_weight_gr, total_returned_qty, status, cancellation_reason,
                           order_timestamp, year_month, source_file)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """
    columns = ['order_id', 'customer_id', 'product_id', 'shipping_id', 'total_qty',
               'total_weight_gr', 'total_returned_qty', 'status', 'cancellation_reason',
               'order_timestamp', 'year_month', 'source_file']
    data = [tuple(None if pd.isna(v) else v for v in row) for row in orders_df[columns].values]
    cursor.executemany(query, data)
    return len(data)


def insert_payments(cursor, payments_df: pd.DataFrame) -> int:
    """Insert payments into database."""
    query = """
        INSERT INTO payments (order_id, payment_method, discount_amount, shipping_paid_by_buyer,
                             estimated_shipping_discount, total_payment, estimated_shipping_cost)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING
    """
    columns = ['order_id', 'payment_method', 'discount_amount', 'shipping_paid_by_buyer',
               'estimated_shipping_discount', 'total_payment', 'estimated_shipping_cost']
    data = [tuple(row) for row in payments_df[columns].values]
    cursor.executemany(query, data)
    return len(data)


def get_table_counts(cursor) -> dict:
    """Get row counts for all tables."""
    tables = ['customers', 'products', 'shipping_methods', 'orders', 'payments']
    counts = {}
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        counts[table] = cursor.fetchone()[0]
    return counts


def main():
    print(f"Reading CSV from {CSV_PATH}...")
    df = pd.read_csv(CSV_PATH, sep=';', encoding='utf-8')
    print(f"Loaded {len(df)} rows from CSV")

    print("\nBuilding normalized tables...")
    customers_df = build_customers_df(df)
    print(f"  Customers: {len(customers_df)} unique")

    products_df = build_products_df(df)
    print(f"  Products: {len(products_df)} unique")

    shipping_df = build_shipping_methods_df(df)
    print(f"  Shipping methods: {len(shipping_df)} unique")

    orders_df = build_orders_df(df, customers_df, products_df, shipping_df)
    print(f"  Orders: {len(orders_df)} rows")

    payments_df = build_payments_df(df)
    valid_order_ids = set(orders_df['order_id'])
    payments_df = payments_df[payments_df['order_id'].isin(valid_order_ids)]
    print(f"  Payments: {len(payments_df)} rows")

    print("\nConnecting to PostgreSQL...")
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()

        print("Inserting data...")
        insert_customers(cursor, customers_df)
        print("  Customers inserted")

        insert_products(cursor, products_df)
        print("  Products inserted")

        insert_shipping_methods(cursor, shipping_df)
        print("  Shipping methods inserted")

        insert_orders(cursor, orders_df)
        print("  Orders inserted")

        insert_payments(cursor, payments_df)
        print("  Payments inserted")

        conn.commit()
        print("\nData committed successfully!")

        counts = get_table_counts(cursor)
        print("\nFinal row counts:")
        for table, count in counts.items():
            print(f"  {table}: {count}")

        cursor.close()

    except Exception as e:
        print(f"\nError during ingestion: {e}")
        if conn:
            conn.rollback()
            print("Transaction rolled back")
        raise

    finally:
        if conn:
            conn.close()
            print("\nConnection closed")


if __name__ == '__main__':
    main()
