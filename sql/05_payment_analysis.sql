-- sql/05_payment_analysis.sql
-- Payment Analysis: COD vs Digital, cancellation, discount utilization
-- NusaCommerce Analytics | Phase 2 | SQL-04

WITH payment_enriched AS (
    SELECT
        o.order_id, o.customer_id, o.status, o.order_timestamp,
        DATE_TRUNC('month', o.order_timestamp)::DATE   AS order_month,
        TO_CHAR(o.order_timestamp, 'YYYY-MM')          AS year_month,
        c.province,
        p.payment_method, p.total_payment,
        p.discount_amount,
        p.shipping_paid_by_buyer,
        o.total_qty,
        CASE WHEN p.payment_method = 'COD'
            THEN 'COD' ELSE 'Non-COD (Digital)' END    AS payment_category,
        CASE
            WHEN p.payment_method = 'COD'               THEN 'COD'
            WHEN p.payment_method ILIKE '%ShopeePay%'   THEN 'ShopeePay (E-Wallet)'
            WHEN p.payment_method ILIKE '%Online%'
              OR p.payment_method ILIKE '%Transfer%'
              OR p.payment_method ILIKE '%Bank%'        THEN 'Online Payment / Bank Transfer'
            ELSE 'Other Digital'
        END AS payment_category_detail,
        CASE WHEN o.status = 'Batal'   THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN o.status = 'Selesai' THEN 1 ELSE 0 END AS is_completed,
        CASE WHEN p.discount_amount > 0 THEN 1 ELSE 0 END AS has_discount,
        CASE WHEN p.total_payment >= 500000 THEN 1 ELSE 0 END AS is_high_value
    FROM orders o
    JOIN payments p  ON o.order_id = p.order_id
    JOIN customers c ON o.customer_id = c.customer_id
),
cod_comparison AS (
    SELECT
        payment_category,
        COUNT(DISTINCT order_id)     AS total_orders,
        SUM(is_completed)            AS completed_orders,
        SUM(is_cancelled)            AS cancelled_orders,
        ROUND(SUM(is_cancelled) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS cancellation_rate_pct,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)    AS total_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0) AS avg_order_value,
        SUM(CASE WHEN is_completed = 1 THEN discount_amount ELSE 0 END)  AS total_discount,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN discount_amount END), 0) AS avg_discount,
        SUM(has_discount)            AS orders_with_discount,
        ROUND(SUM(has_discount) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS discount_utilization_pct,
        SUM(is_high_value)           AS high_value_orders,
        ROUND(SUM(is_high_value) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS high_value_order_pct
    FROM payment_enriched
    GROUP BY payment_category
),
method_detail AS (
    SELECT
        payment_method, payment_category, payment_category_detail,
        COUNT(DISTINCT order_id)     AS total_orders,
        SUM(is_completed)            AS completed_orders,
        SUM(is_cancelled)            AS cancelled_orders,
        ROUND(SUM(is_cancelled) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS cancellation_rate_pct,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)    AS total_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0) AS avg_order_value,
        SUM(CASE WHEN is_completed = 1 THEN discount_amount ELSE 0 END)  AS total_discount,
        ROUND(SUM(has_discount) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS discount_utilization_pct,
        RANK() OVER (ORDER BY SUM(CASE WHEN is_completed = 1
            THEN total_payment ELSE 0 END) DESC) AS revenue_rank
    FROM payment_enriched
    GROUP BY payment_method, payment_category, payment_category_detail
),
monthly_trend AS (
    SELECT
        order_month, year_month, payment_category, payment_category_detail,
        COUNT(DISTINCT order_id)     AS monthly_orders,
        SUM(is_completed)            AS monthly_completed,
        SUM(is_cancelled)            AS monthly_cancelled,
        SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)    AS monthly_revenue,
        ROUND(AVG(CASE WHEN is_completed = 1 THEN total_payment END), 0) AS monthly_aov,
        SUM(has_discount)            AS monthly_discounted_orders,
        LAG(SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)) OVER (
            PARTITION BY payment_category_detail ORDER BY order_month
        ) AS prev_month_revenue,
        ROUND(
            (SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END)
            - LAG(SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END))
                OVER (PARTITION BY payment_category_detail ORDER BY order_month))
            / NULLIF(LAG(SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END))
                OVER (PARTITION BY payment_category_detail ORDER BY order_month), 0)
            * 100, 2
        ) AS mom_growth_pct,
        ROUND(
            SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END) * 100.0
            / NULLIF(SUM(SUM(CASE WHEN is_completed = 1 THEN total_payment ELSE 0 END))
                OVER (PARTITION BY order_month), 0), 2
        ) AS monthly_revenue_share_pct
    FROM payment_enriched
    GROUP BY order_month, year_month, payment_category, payment_category_detail
)
SELECT 'cod_vs_digital' AS analysis_level,
    cc.payment_category AS payment_method,
    cc.payment_category, cc.payment_category AS payment_category_detail,
    NULL::DATE AS order_month, NULL::VARCHAR AS year_month,
    cc.total_orders, cc.completed_orders, cc.cancelled_orders,
    cc.cancellation_rate_pct, cc.total_revenue, cc.avg_order_value,
    cc.total_discount, cc.avg_discount, cc.discount_utilization_pct,
    cc.high_value_orders, cc.high_value_order_pct,
    NULL::NUMERIC AS mom_growth_pct, NULL::NUMERIC AS monthly_revenue_share_pct,
    NULL::INT AS revenue_rank
FROM cod_comparison cc
UNION ALL
SELECT 'method_detail',
    md.payment_method, md.payment_category, md.payment_category_detail,
    NULL::DATE, NULL::VARCHAR,
    md.total_orders, md.completed_orders, md.cancelled_orders,
    md.cancellation_rate_pct, md.total_revenue, md.avg_order_value,
    md.total_discount, NULL::NUMERIC, md.discount_utilization_pct,
    NULL::BIGINT, NULL::NUMERIC,
    NULL::NUMERIC, NULL::NUMERIC, md.revenue_rank
FROM method_detail md
UNION ALL
SELECT 'monthly_trend',
    mt.payment_category_detail, mt.payment_category, mt.payment_category_detail,
    mt.order_month, mt.year_month,
    mt.monthly_orders, mt.monthly_completed, mt.monthly_cancelled,
    NULL::NUMERIC, mt.monthly_revenue, mt.monthly_aov,
    NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC,
    NULL::BIGINT, NULL::NUMERIC,
    mt.mom_growth_pct, mt.monthly_revenue_share_pct, NULL::INT
FROM monthly_trend mt
ORDER BY analysis_level, order_month NULLS FIRST, total_revenue DESC;
