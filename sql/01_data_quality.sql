-- sql/01_data_quality.sql
-- Data Quality Check Report
-- NusaCommerce Analytics | Phase 2 | SQL-00

-- Table row counts
SELECT 'table_counts' AS check_type,
    'customers' AS table_name, COUNT(*)::TEXT AS metric_value, NULL AS details
FROM customers
UNION ALL
SELECT 'table_counts', 'products', COUNT(*)::TEXT, NULL FROM products
UNION ALL
SELECT 'table_counts', 'shipping_methods', COUNT(*)::TEXT, NULL FROM shipping_methods
UNION ALL
SELECT 'table_counts', 'orders', COUNT(*)::TEXT, NULL FROM orders
UNION ALL
SELECT 'table_counts', 'payments', COUNT(*)::TEXT, NULL FROM payments

UNION ALL

-- Null checks for critical columns
SELECT 'null_check', 'orders.order_timestamp', COUNT(*)::TEXT,
    'Rows with NULL order_timestamp'
FROM orders WHERE order_timestamp IS NULL

UNION ALL
SELECT 'null_check', 'orders.customer_id', COUNT(*)::TEXT,
    'Rows with NULL customer_id'
FROM orders WHERE customer_id IS NULL

UNION ALL
SELECT 'null_check', 'orders.status', COUNT(*)::TEXT,
    'Rows with NULL or empty status'
FROM orders WHERE status IS NULL OR status = ''

UNION ALL
SELECT 'null_check', 'payments.total_payment', COUNT(*)::TEXT,
    'Rows with NULL total_payment'
FROM payments WHERE total_payment IS NULL

UNION ALL
SELECT 'null_check', 'payments.payment_method', COUNT(*)::TEXT,
    'Rows with NULL or empty payment_method'
FROM payments WHERE payment_method IS NULL OR payment_method = ''

UNION ALL

-- Orphan record checks
SELECT 'orphan_check', 'orders.customer_id', COUNT(*)::TEXT,
    'Orders with non-existent customer_id'
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL
SELECT 'orphan_check', 'orders.product_id', COUNT(*)::TEXT,
    'Orders with non-existent product_id'
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL
SELECT 'orphan_check', 'orders.shipping_id', COUNT(*)::TEXT,
    'Orders with non-existent shipping_id'
FROM orders o
LEFT JOIN shipping_methods sm ON o.shipping_id = sm.shipping_id
WHERE sm.shipping_id IS NULL

UNION ALL
SELECT 'orphan_check', 'payments.order_id', COUNT(*)::TEXT,
    'Payments with non-existent order_id'
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- Status distribution
SELECT 'status_distribution', status, COUNT(*)::TEXT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)::TEXT || '%'
FROM orders
GROUP BY status

UNION ALL

-- Date range check
SELECT 'date_range', 'min_order_date', MIN(order_timestamp)::TEXT, NULL FROM orders
UNION ALL
SELECT 'date_range', 'max_order_date', MAX(order_timestamp)::TEXT, NULL FROM orders

UNION ALL

-- Duplicate checks
SELECT 'duplicate_check', 'orders.order_id', COUNT(*)::TEXT,
    'Duplicate order_ids'
FROM (
    SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1
) dupes

UNION ALL

-- Value range checks
SELECT 'value_range', 'total_payment_negative', COUNT(*)::TEXT,
    'Payments with negative total_payment'
FROM payments WHERE total_payment < 0

UNION ALL
SELECT 'value_range', 'total_qty_negative', COUNT(*)::TEXT,
    'Orders with negative total_qty'
FROM orders WHERE total_qty < 0

UNION ALL
SELECT 'value_range', 'total_payment_zero_completed', COUNT(*)::TEXT,
    'Completed orders with zero payment'
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.status = 'Selesai' AND p.total_payment = 0

UNION ALL

-- Summary statistics
SELECT 'summary_stats', 'avg_order_value', ROUND(AVG(total_payment), 2)::TEXT, NULL
FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE o.status = 'Selesai'

UNION ALL
SELECT 'summary_stats', 'median_order_value',
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_payment)::NUMERIC, 2)::TEXT, NULL
FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE o.status = 'Selesai'

UNION ALL
SELECT 'summary_stats', 'total_revenue', ROUND(SUM(total_payment), 2)::TEXT, NULL
FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE o.status = 'Selesai'

UNION ALL
SELECT 'summary_stats', 'completion_rate',
    ROUND(SUM(CASE WHEN status = 'Selesai' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)::TEXT || '%', NULL
FROM orders

ORDER BY check_type, table_name;
