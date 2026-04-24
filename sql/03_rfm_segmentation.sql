-- sql/03_rfm_segmentation.sql
-- RFM Segmentation with NTILE(4) scoring
-- NusaCommerce Analytics | Phase 2 | SQL-02

WITH reference_date AS (
    SELECT MAX(order_timestamp)::DATE AS max_date
    FROM orders WHERE status = 'Selesai'
),
customer_rfm_raw AS (
    SELECT
        o.customer_id,
        c.city,
        c.province,
        (SELECT max_date FROM reference_date)
            - MAX(o.order_timestamp)::DATE        AS recency_days,
        COUNT(DISTINCT o.order_id)                AS frequency,
        SUM(p.total_payment)                      AS monetary,
        MIN(o.order_timestamp)::DATE              AS first_order_date,
        MAX(o.order_timestamp)::DATE              AS last_order_date,
        AVG(p.total_payment)                      AS avg_order_value,
        SUM(o.total_qty)                          AS total_items_purchased,
        COUNT(DISTINCT DATE_TRUNC('month', o.order_timestamp)) AS active_months
    FROM orders o
    JOIN payments p  ON o.order_id = p.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.status = 'Selesai'
    GROUP BY o.customer_id, c.city, c.province
),
rfm_scores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
    FROM customer_rfm_raw
),
rfm_combined AS (
    SELECT *,
        (r_score + f_score + m_score) AS rfm_total_score,
        CONCAT(r_score, f_score, m_score) AS rfm_score_label,
        CASE
            WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score >= 2 AND m_score >= 2 THEN 'Potential Loyalists'
            WHEN r_score = 4 AND f_score <= 2                   THEN 'New Customers'
            WHEN r_score = 3 AND f_score <= 2 AND m_score <= 2  THEN 'Promising'
            WHEN r_score = 2 AND f_score >= 3 AND m_score >= 3  THEN 'At Risk'
            WHEN r_score = 2 AND f_score >= 2                   THEN 'Need Attention'
            WHEN r_score = 1 AND f_score >= 3                   THEN 'Cannot Lose Them'
            WHEN r_score = 1 AND f_score = 1 AND m_score = 1    THEN 'Lost'
            ELSE 'Hibernating'
        END AS segment
    FROM rfm_scores
)
SELECT
    customer_id, city, province,
    recency_days, frequency,
    ROUND(monetary, 0)        AS monetary,
    ROUND(avg_order_value, 0) AS avg_order_value,
    total_items_purchased, active_months,
    first_order_date, last_order_date,
    r_score, f_score, m_score,
    rfm_total_score, rfm_score_label, segment,
    CASE segment
        WHEN 'Champions'           THEN 1
        WHEN 'Loyal Customers'     THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'New Customers'       THEN 4
        WHEN 'Promising'           THEN 5
        WHEN 'Need Attention'      THEN 6
        WHEN 'At Risk'             THEN 7
        WHEN 'Cannot Lose Them'    THEN 8
        WHEN 'Hibernating'         THEN 9
        WHEN 'Lost'                THEN 10
        ELSE 11
    END AS segment_priority
FROM rfm_combined
ORDER BY rfm_total_score DESC, recency_days ASC;
