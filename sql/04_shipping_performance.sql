-- sql/04_shipping_performance.sql
-- Shipping Performance Analysis
-- NusaCommerce Analytics | Phase 2 | SQL-03

WITH order_shipping AS (
    SELECT
        o.order_id, o.customer_id, o.status, o.order_timestamp,
        c.city, c.province,
        sm.shipping_id, sm.courier_name, sm.service_type,
        p.total_payment,
        p.shipping_paid_by_buyer,
        p.estimated_shipping_discount,
        o.total_qty, o.total_weight_gr,
        CASE WHEN o.status = 'Batal'    THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN o.status = 'Selesai'  THEN 1 ELSE 0 END AS is_completed
    FROM orders o
    JOIN payments p           ON o.order_id = p.order_id
    JOIN customers c          ON o.customer_id = c.customer_id
    LEFT JOIN shipping_methods sm ON o.shipping_id = sm.shipping_id
),
courier_summary AS (
    SELECT
        COALESCE(courier_name, 'Unknown') AS courier,
        COUNT(DISTINCT order_id)     AS total_orders,
        SUM(is_completed)            AS completed_orders,
        SUM(is_cancelled)            AS cancelled_orders,
        ROUND(SUM(is_cancelled) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS cancellation_rate_pct,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)        AS total_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0)     AS avg_order_value,
        SUM(CASE WHEN is_completed = 1 THEN shipping_paid_by_buyer ELSE 0 END) AS total_shipping_collected,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN shipping_paid_by_buyer END), 0) AS avg_shipping_cost,
        SUM(CASE WHEN is_completed = 1 THEN total_qty ELSE 0 END)            AS total_items_shipped,
        SUM(CASE WHEN is_completed = 1 THEN total_weight_gr ELSE 0 END)      AS total_weight_gr
    FROM order_shipping
    GROUP BY courier_name
),
service_type_summary AS (
    SELECT
        COALESCE(courier_name, 'Unknown')      AS courier,
        COALESCE(service_type, 'Unknown') AS service_type,
        COUNT(DISTINCT order_id)          AS total_orders,
        SUM(is_completed)                 AS completed_orders,
        SUM(is_cancelled)                 AS cancelled_orders,
        ROUND(SUM(is_cancelled) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS cancellation_rate_pct,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)    AS total_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0) AS avg_order_value,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN shipping_paid_by_buyer END), 0) AS avg_shipping_cost
    FROM order_shipping
    GROUP BY courier_name, service_type
),
province_courier AS (
    SELECT
        COALESCE(province, 'Unknown') AS province,
        COALESCE(courier_name, 'Unknown')  AS courier,
        COUNT(DISTINCT order_id)      AS total_orders,
        SUM(is_completed)             AS completed_orders,
        SUM(is_cancelled)             AS cancelled_orders,
        ROUND(SUM(is_cancelled) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS cancellation_rate_pct,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)    AS total_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0) AS avg_order_value,
        RANK() OVER (
            PARTITION BY courier_name ORDER BY COUNT(DISTINCT order_id) DESC
        ) AS province_rank_per_courier
    FROM order_shipping
    GROUP BY province, courier_name
)
SELECT 'courier_summary' AS analysis_level,
    cs.courier, NULL::VARCHAR AS service_type, NULL::VARCHAR AS province,
    cs.total_orders, cs.completed_orders, cs.cancelled_orders,
    cs.cancellation_rate_pct, cs.total_revenue, cs.avg_order_value,
    cs.total_shipping_collected, cs.avg_shipping_cost,
    cs.total_items_shipped, cs.total_weight_gr,
    NULL::INT AS province_rank_per_courier,
    ROUND(cs.total_orders * 100.0 / SUM(cs.total_orders) OVER (), 2) AS order_share_pct,
    ROUND(cs.total_revenue * 100.0 / SUM(cs.total_revenue) OVER (), 2) AS revenue_share_pct
FROM courier_summary cs
UNION ALL
SELECT 'service_type_detail', sts.courier, sts.service_type, NULL::VARCHAR,
    sts.total_orders, sts.completed_orders, sts.cancelled_orders,
    sts.cancellation_rate_pct, sts.total_revenue, sts.avg_order_value,
    NULL::BIGINT, sts.avg_shipping_cost, NULL::BIGINT, NULL::BIGINT,
    NULL::INT, NULL::NUMERIC, NULL::NUMERIC
FROM service_type_summary sts
UNION ALL
SELECT 'province_courier_matrix', pc.courier, NULL::VARCHAR, pc.province,
    pc.total_orders, pc.completed_orders, pc.cancelled_orders,
    pc.cancellation_rate_pct, pc.total_revenue, pc.avg_order_value,
    NULL::BIGINT, NULL::NUMERIC, NULL::BIGINT, NULL::BIGINT,
    pc.province_rank_per_courier, NULL::NUMERIC, NULL::NUMERIC
FROM province_courier pc
WHERE pc.province_rank_per_courier <= 10
ORDER BY analysis_level, courier, total_orders DESC;
