-- sql/02_revenue_trend.sql
-- Revenue Trend Analysis: Monthly, MoM Growth, Running Total, Top 10 Province
-- NusaCommerce Analytics | Phase 2 | SQL-01

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_timestamp)::DATE      AS order_month,
        TO_CHAR(o.order_timestamp, 'YYYY-MM')             AS year_month,
        EXTRACT(YEAR FROM o.order_timestamp)              AS order_year,
        EXTRACT(MONTH FROM o.order_timestamp)             AS order_month_num,
        c.province,
        COUNT(DISTINCT o.order_id)                        AS total_orders,
        SUM(p.total_payment)                              AS total_revenue,
        AVG(p.total_payment)                              AS avg_order_value,
        SUM(o.total_qty)                                  AS total_items_sold,
        COUNT(DISTINCT o.customer_id)                     AS unique_customers
    FROM orders o
    JOIN payments p  ON o.order_id = p.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.status = 'Selesai'
      AND o.order_timestamp IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5
),
province_rank AS (
    SELECT
        province,
        SUM(total_revenue) AS province_total_revenue,
        RANK() OVER (ORDER BY SUM(total_revenue) DESC) AS revenue_rank
    FROM monthly_revenue
    GROUP BY province
),
top10_provinces AS (
    SELECT province FROM province_rank WHERE revenue_rank <= 10
),
national_monthly AS (
    SELECT
        order_month, year_month, order_year, order_month_num,
        SUM(total_orders)     AS national_orders,
        SUM(total_revenue)    AS national_revenue,
        AVG(avg_order_value)  AS national_aov,
        SUM(total_items_sold) AS national_items,
        SUM(unique_customers) AS national_customers
    FROM monthly_revenue
    GROUP BY 1, 2, 3, 4
),
national_with_growth AS (
    SELECT
        order_month, year_month, order_year, order_month_num,
        national_orders, national_revenue, national_aov,
        national_items, national_customers,
        LAG(national_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
        ROUND(
            (national_revenue - LAG(national_revenue) OVER (ORDER BY order_month))
            / NULLIF(LAG(national_revenue) OVER (ORDER BY order_month), 0) * 100, 2
        ) AS mom_growth_pct,
        SUM(national_revenue) OVER (
            ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_revenue,
        ROUND(AVG(national_revenue) OVER (
            ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 0) AS rolling_3m_avg_revenue
    FROM national_monthly
),
province_monthly AS (
    SELECT
        mr.order_month, mr.year_month, mr.province,
        pr.revenue_rank,
        mr.total_orders       AS province_orders,
        mr.total_revenue      AS province_revenue,
        mr.avg_order_value    AS province_aov,
        mr.unique_customers   AS province_customers,
        LAG(mr.total_revenue) OVER (
            PARTITION BY mr.province ORDER BY mr.order_month
        ) AS province_prev_revenue,
        ROUND(
            (mr.total_revenue - LAG(mr.total_revenue) OVER (
                PARTITION BY mr.province ORDER BY mr.order_month
            )) / NULLIF(LAG(mr.total_revenue) OVER (
                PARTITION BY mr.province ORDER BY mr.order_month
            ), 0) * 100, 2
        ) AS province_mom_growth_pct,
        ROUND(
            mr.total_revenue * 100.0
            / SUM(mr.total_revenue) OVER (PARTITION BY mr.order_month), 2
        ) AS province_revenue_share_pct
    FROM monthly_revenue mr
    JOIN top10_provinces tp ON mr.province = tp.province
    JOIN province_rank pr   ON mr.province = pr.province
)
SELECT
    ng.order_month, ng.year_month, ng.order_year, ng.order_month_num,
    ng.national_orders, ng.national_revenue,
    ROUND(ng.national_aov, 0)        AS national_aov,
    ng.national_items, ng.national_customers,
    ng.prev_month_revenue, ng.mom_growth_pct,
    ng.running_total_revenue, ng.rolling_3m_avg_revenue,
    pm.province,
    pm.revenue_rank                  AS province_rank,
    pm.province_orders, pm.province_revenue,
    ROUND(pm.province_aov, 0)        AS province_aov,
    pm.province_customers,
    pm.province_prev_revenue, pm.province_mom_growth_pct,
    pm.province_revenue_share_pct
FROM national_with_growth ng
LEFT JOIN province_monthly pm ON ng.order_month = pm.order_month
ORDER BY ng.order_month, pm.revenue_rank;
