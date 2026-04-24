-- NusaCommerce Analytics Database Schema
-- Normalized from flat Indonesian e-commerce CSV data

-- 1. Customers table
-- customer_id: MD5 hash of Kota+Provinsi+faker_name (generated during ETL)
-- customer_name, phone: Generated using Faker id_ID locale
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

-- 2. Products table
-- product_id: MD5 hash of product_categories (generated during ETL)
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(32) PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    num_categories INTEGER NOT NULL DEFAULT 1
);

-- 3. Shipping methods table
-- shipping_id: MD5 hash of Opsi Pengiriman (generated during ETL)
CREATE TABLE IF NOT EXISTS shipping_methods (
    shipping_id VARCHAR(32) PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL,
    courier_name VARCHAR(100),
    service_type VARCHAR(100)
);

-- 4. Orders table
-- Links to customers, products, and shipping_methods
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(32) NOT NULL REFERENCES customers(customer_id),
    product_id VARCHAR(32) NOT NULL REFERENCES products(product_id),
    shipping_id VARCHAR(32) NOT NULL REFERENCES shipping_methods(shipping_id),
    total_qty INTEGER NOT NULL DEFAULT 0,
    total_weight_gr INTEGER NOT NULL DEFAULT 0,
    total_returned_qty INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(100) NOT NULL,
    cancellation_reason TEXT,
    order_timestamp TIMESTAMP NOT NULL,
    year_month VARCHAR(7) NOT NULL,
    source_file VARCHAR(255)
);

-- 5. Payments table
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL REFERENCES orders(order_id),
    payment_method VARCHAR(100) NOT NULL,
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    shipping_paid_by_buyer NUMERIC(15, 2) NOT NULL DEFAULT 0,
    estimated_shipping_discount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_payment NUMERIC(15, 2) NOT NULL DEFAULT 0,
    estimated_shipping_cost NUMERIC(15, 2) NOT NULL DEFAULT 0
);

-- Indexes for orders table
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_timestamp ON orders(order_timestamp);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_year_month ON orders(year_month);

-- Indexes for payments table
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_method ON payments(payment_method);
