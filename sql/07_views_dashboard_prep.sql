-- sql/07_views_dashboard_prep.sql
-- Dashboard-Ready Views for Looker Studio / Tableau
-- NusaCommerce Analytics | Phase 2 | SQL-06

-- Drop existing views if any
DROP VIEW IF EXISTS vw_dashboard_executive CASCADE;
DROP VIEW IF EXISTS vw_revenue_monthly CASCADE;
DROP VIEW IF EXISTS vw_rfm_summary CASCADE;
DROP VIEW IF EXISTS vw_shipping_summary CASCADE;
DROP VIEW IF EXISTS vw_payment_summary CASCADE;
DROP VIEW IF EXISTS vw_category_summary CASCADE;
DROP VIEW IF EXISTS vw_province_summary CASCADE;

-- 1. Executive Dashboard View
CREATE VIEW vw_dashboard_executive AS
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT p.product_id) AS total_products,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    SUM(CASE WHEN o.status = 'Selesai' THEN o.total_qty ELSE 0 END) AS total_items_sold,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.discount_amount ELSE 0 END), 0) AS total_discounts,
    MIN(o.order_timestamp)::DATE AS first_order_date,
    MAX(o.order_timestamp)::DATE AS last_order_date
FROM orders o
JOIN payments py ON o.order_id = py.order_id
JOIN products p ON o.product_id = p.product_id;

-- 2. Monthly Revenue View
CREATE VIEW vw_revenue_monthly AS
SELECT
    DATE_TRUNC('month', o.order_timestamp)::DATE AS order_month,
    TO_CHAR(o.order_timestamp, 'YYYY-MM') AS year_month,
    EXTRACT(YEAR FROM o.order_timestamp)::INT AS order_year,
    EXTRACT(MONTH FROM o.order_timestamp)::INT AS order_month_num,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    SUM(CASE WHEN o.status = 'Selesai' THEN o.total_qty ELSE 0 END) AS total_items_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(DISTINCT CASE WHEN o.status = 'Selesai' THEN o.customer_id END) AS paying_customers
FROM orders o
JOIN payments py ON o.order_id = py.order_id
WHERE o.order_timestamp IS NOT NULL
GROUP BY 1, 2, 3, 4
ORDER BY order_month;

-- 3. RFM Summary View
CREATE VIEW vw_rfm_summary AS
WITH reference_date AS (
    SELECT MAX(order_timestamp)::DATE AS max_date FROM orders WHERE status = 'Selesai'
),
customer_rfm AS (
    SELECT
        o.customer_id,
        c.city,
        c.province,
        (SELECT max_date FROM reference_date) - MAX(o.order_timestamp)::DATE AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(py.total_payment) AS monetary
    FROM orders o
    JOIN payments py ON o.order_id = py.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.status = 'Selesai'
    GROUP BY o.customer_id, c.city, c.province
),
rfm_scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
rfm_segmented AS (
    SELECT *,
        CASE
            WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score >= 2 AND m_score >= 2 THEN 'Potential Loyalists'
            WHEN r_score = 4 AND f_score <= 2 THEN 'New Customers'
            WHEN r_score = 3 AND f_score <= 2 AND m_score <= 2 THEN 'Promising'
            WHEN r_score = 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
            WHEN r_score = 2 AND f_score >= 2 THEN 'Need Attention'
            WHEN r_score = 1 AND f_score >= 3 THEN 'Cannot Lose Them'
            WHEN r_score = 1 AND f_score = 1 AND m_score = 1 THEN 'Lost'
            ELSE 'Hibernating'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS customer_pct,
    ROUND(AVG(recency_days), 0) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary), 0) AS avg_monetary,
    ROUND(SUM(monetary), 0) AS total_monetary,
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (), 2) AS revenue_pct
FROM rfm_segmented
GROUP BY segment
ORDER BY total_monetary DESC;

-- 4. Shipping Summary View
CREATE VIEW vw_shipping_summary AS
SELECT
    COALESCE(sm.courier_name, 'Unknown') AS courier,
    COALESCE(sm.service_type, 'Unknown') AS service_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.shipping_paid_by_buyer END), 0) AS avg_shipping_cost,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM orders o
JOIN payments py ON o.order_id = py.order_id
LEFT JOIN shipping_methods sm ON o.shipping_id = sm.shipping_id
GROUP BY sm.courier_name, sm.service_type
ORDER BY total_orders DESC;

-- 5. Payment Summary View
CREATE VIEW vw_payment_summary AS
SELECT
    py.payment_method,
    CASE WHEN py.payment_method ILIKE '%COD%' THEN 'COD' ELSE 'Digital' END AS payment_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.discount_amount ELSE 0 END), 0) AS total_discounts,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM orders o
JOIN payments py ON o.order_id = py.order_id
GROUP BY py.payment_method
ORDER BY total_revenue DESC;

-- 6. Category Summary View
CREATE VIEW vw_category_summary AS
SELECT
    p.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    SUM(CASE WHEN o.status = 'Selesai' THEN o.total_qty ELSE 0 END) AS total_items_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    RANK() OVER (ORDER BY SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END) DESC) AS revenue_rank
FROM products p
JOIN orders o ON p.product_id = o.product_id
JOIN payments py ON o.order_id = py.order_id
GROUP BY p.category_name
ORDER BY total_revenue DESC;

-- 7. Province Summary View
CREATE VIEW vw_province_summary AS
SELECT
    c.province,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END), 0) AS total_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END), 0) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    RANK() OVER (ORDER BY SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END) DESC) AS revenue_rank,
    ROUND(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END) * 100.0 /
        SUM(SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END)) OVER (), 2) AS revenue_share_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments py ON o.order_id = py.order_id
GROUP BY c.province
ORDER BY total_revenue DESC;

-- Confirmation
SELECT 'Views created successfully' AS status;
