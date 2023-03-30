CREATE TABLE IF NOT EXISTS annual_revenue AS
SELECT
    DATE_PART('year', od.order_purchase_timestamp) as years,
    SUM(oi.price + oi.freight_value) as item_revenue
FROM order_items_dataset as oi
         JOIN orders_dataset as od ON od.order_id = oi.order_id
WHERE od.order_status = 'delivered'
GROUP BY 1
ORDER BY 1 ASC;
CREATE TABLE IF NOT EXISTS cancel_rate AS
SELECT
    DATE_PART('year', od.order_purchase_timestamp) as years,
    COUNT(od.order_status) as total_canceled_order
FROM orders_dataset as od
WHERE od.order_status = 'canceled'
GROUP BY 1
ORDER BY 1 ASC;
CREATE TABLE IF NOT EXISTS cat AS(
    SELECT
        years,
        item_revenue,
        category
    FROM(SELECT
             DATE_PART('year', od.order_purchase_timestamp) as years,
             SUM(oi.price + oi.freight_value) as item_revenue,
             pd.product_category_name as category,
             RANK() OVER (PARTITION BY DATE_PART('year', od.order_purchase_timestamp) ORDER BY SUM(oi.price + oi.freight_value) DESC)
                                                            as ranked
         FROM order_items_dataset as oi
                  JOIN orders_dataset as od ON od.order_id = oi.order_id
                  JOIN products_dataset as pd ON pd.product_id = oi.product_id
         WHERE od.order_status = 'delivered'
         GROUP BY 1,3) as sub
    WHERE ranked = 1
);
CREATE TABLE IF NOT EXISTS cancel_cat AS(
    SELECT
        years,
        category,
        total_canceled_order
    FROM(SELECT
             DATE_PART('year', od.order_purchase_timestamp) as years,
             COUNT(od.order_status) as total_canceled_order,
             pd.product_category_name as category,
             RANK() OVER (PARTITION BY DATE_PART('year', od.order_purchase_timestamp) ORDER BY COUNT(od.order_status) DESC)
                                                            as ranked
         FROM orders_dataset as od
                  JOIN order_items_dataset as oi ON od.order_id = oi.order_id
                  JOIN products_dataset as pd ON pd.product_id = oi.product_id
         WHERE od.order_status = 'canceled'
         GROUP BY 1,3
        ) as sub
    WHERE ranked = 1
);
SELECT
    ar.years,
    cat.category as category_with_highest_revenue,
    cat.item_revenue as revenue_per_category,
    ar.item_revenue as total_revenue_per_year,
    cc.category as canceled_category,
    cc.total_canceled_order as highest_total_canceled_order_per_category,
    cr.total_canceled_order as total_canceled_order_per_year

FROM annual_revenue as ar
         JOIN cancel_cat as cc ON cc.years = ar.years
         JOIN cancel_rate as cr ON cr.years = ar.years
         JOIN cat ON cat.years = ar.years
