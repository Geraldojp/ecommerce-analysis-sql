SELECT
    opd.payment_type,
    count(opd.order_id)
FROM order_payments_dataset as opd
GROUP BY 1
ORDER BY 2 DESC;

SELECT
    payment_type,
    SUM(
            CASE
                WHEN years = 2016 THEN payment_type_counts ELSE 0
                END
        ) as year_2016,
    SUM(
            CASE
                WHEN years = 2017 THEN payment_type_counts ELSE 0
                END
        ) as year_2017,
    SUM(
            CASE
                WHEN years = 2018 THEN payment_type_counts ELSE 0
                END
        ) as year_2018,
    SUM(payment_type_counts) as total_payment_type_counts
FROM(
        SELECT
            DATE_PART('year',od.order_purchase_timestamp) as years,
            count(opd.payment_type) as payment_type_counts,
            opd.payment_type
        FROM order_payments_dataset as opd
                 JOIN orders_dataset as od ON od.order_id = opd.order_id
        GROUP BY 1,3
    ) as sub
GROUP BY 1
ORDER BY 2 DESC
