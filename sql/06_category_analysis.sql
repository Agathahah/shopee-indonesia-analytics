-- sql/06_category_analysis.sql
-- Product Category Performance Analysis
-- NusaCommerce Analytics | Phase 2 | SQL-05

WITH category_metrics AS (
    SELECT
        p.product_id,
        p.category_name,
        p.num_categories,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END) AS completed_orders,
        SUM(CASE WHEN o.status = 'Batal' THEN 1 ELSE 0 END) AS cancelled_orders,
        SUM(CASE WHEN o.status = 'Selesai' THEN o.total_qty ELSE 0 END) AS total_items_sold,
        SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END) AS total_revenue,
        AVG(CASE WHEN o.status = 'Selesai' THEN py.total_payment END) AS avg_order_value,
        SUM(CASE WHEN o.status = 'Selesai' THEN py.discount_amount ELSE 0 END) AS total_discount,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        COUNT(DISTINCT CASE WHEN o.status = 'Selesai' THEN o.customer_id END) AS paying_customers,
        MIN(o.order_timestamp) AS first_order_date,
        MAX(o.order_timestamp) AS last_order_date
    FROM products p
    JOIN orders o ON p.product_id = o.product_id
    JOIN payments py ON o.order_id = py.order_id
    GROUP BY p.product_id, p.category_name, p.num_categories
),
category_ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY total_orders DESC) AS orders_rank,
        RANK() OVER (ORDER BY unique_customers DESC) AS customers_rank,
        ROUND(cancelled_orders * 100.0 / NULLIF(total_orders, 0), 2) AS cancellation_rate,
        ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_share_pct,
        ROUND(total_orders * 100.0 / SUM(total_orders) OVER (), 2) AS orders_share_pct,
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
    FROM category_metrics
),
monthly_category AS (
    SELECT
        p.category_name,
        DATE_TRUNC('month', o.order_timestamp)::DATE AS order_month,
        TO_CHAR(o.order_timestamp, 'YYYY-MM') AS year_month,
        COUNT(DISTINCT o.order_id) AS monthly_orders,
        SUM(CASE WHEN o.status = 'Selesai' THEN py.total_payment ELSE 0 END) AS monthly_revenue
    FROM products p
    JOIN orders o ON p.product_id = o.product_id
    JOIN payments py ON o.order_id = py.order_id
    GROUP BY p.category_name, DATE_TRUNC('month', o.order_timestamp), TO_CHAR(o.order_timestamp, 'YYYY-MM')
),
category_trend AS (
    SELECT
        category_name, order_month, year_month,
        monthly_orders, monthly_revenue,
        LAG(monthly_revenue) OVER (PARTITION BY category_name ORDER BY order_month) AS prev_month_revenue,
        ROUND(
            (monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY category_name ORDER BY order_month))
            / NULLIF(LAG(monthly_revenue) OVER (PARTITION BY category_name ORDER BY order_month), 0) * 100, 2
        ) AS mom_growth_pct
    FROM monthly_category
)
SELECT 'category_summary' AS analysis_level,
    cr.category_name,
    cr.num_categories,
    NULL::DATE AS order_month,
    NULL::VARCHAR AS year_month,
    cr.total_orders,
    cr.completed_orders,
    cr.cancelled_orders,
    cr.cancellation_rate,
    cr.total_items_sold,
    ROUND(cr.total_revenue, 0) AS total_revenue,
    ROUND(cr.avg_order_value, 0) AS avg_order_value,
    ROUND(cr.total_discount, 0) AS total_discount,
    cr.unique_customers,
    cr.paying_customers,
    cr.revenue_rank,
    cr.orders_rank,
    cr.revenue_share_pct,
    cr.orders_share_pct,
    cr.revenue_quartile,
    NULL::NUMERIC AS monthly_orders,
    NULL::NUMERIC AS monthly_revenue,
    NULL::NUMERIC AS mom_growth_pct,
    cr.first_order_date,
    cr.last_order_date
FROM category_ranked cr

UNION ALL

SELECT 'category_monthly_trend',
    ct.category_name,
    NULL::INTEGER,
    ct.order_month,
    ct.year_month,
    NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::BIGINT,
    NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
    NULL::BIGINT, NULL::BIGINT,
    NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::INT,
    ct.monthly_orders,
    ROUND(ct.monthly_revenue, 0),
    ct.mom_growth_pct,
    NULL::TIMESTAMP, NULL::TIMESTAMP
FROM category_trend ct
WHERE ct.category_name IN (
    SELECT category_name FROM category_ranked WHERE revenue_rank <= 20
)

ORDER BY analysis_level, revenue_rank NULLS LAST, order_month NULLS FIRST;
