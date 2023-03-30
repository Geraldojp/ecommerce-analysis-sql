WITH avg_mau AS(
    SELECT
        active_year,
        round(avg(total_customer), 2) as avg_customer
    FROM (
             SELECT
                 (COUNT(DISTINCT(cd.customer_unique_id))) as total_customer,
                 EXTRACT(year from od.order_purchase_timestamp) as active_year,
                 EXTRACT(month from od.order_purchase_timestamp) as active_month
             FROM customer_dataset as cd
                      LEFT JOIN orders_dataset as od ON od.customer_id = cd.customer_id
             GROUP BY 2, 3
         ) as mau
    GROUP BY 1
),
     new_customer AS(
         SELECT
             years,
             count(customer_unique_id) as total_new_customer
         FROM(
                 SELECT
                     cd.customer_unique_id,
                     min(extract(year from od.order_purchase_timestamp)) as years
                 FROM customer_dataset as cd
                          LEFT JOIN orders_dataset as od ON od.customer_id = cd.customer_id
                 GROUP BY 1
             ) as nc
         GROUP BY 1
     ),
     repeat_order AS(
         SELECT
             years,
             count(customer) as customer_repeat_order
         FROM(
                 SELECT
                     DISTINCT(cd.customer_unique_id) as customer,
                             EXTRACT(year from ord.order_purchase_timestamp) as years
                 FROM customer_dataset as cd
                          LEFT JOIN orders_dataset as ord on cd.customer_id = ord.customer_id
                 GROUP BY 1,2
                 HAVING COUNT(cd.customer_unique_id) > 1
             ) as ro
         GROUP BY 1
     ),
     avg_order AS(
         SELECT
             years,
             round(avg(total_order),2) as avg_order
         FROM(
                 SELECT
                     DISTINCT(cd.customer_unique_id) as customer,
                             COUNT(od.order_id) as total_order,
                             EXTRACT(year from order_purchase_timestamp) as years
                 FROM customer_dataset as cd
                          LEFT JOIN orders_dataset as od ON od.customer_id = cd.customer_id
                 GROUP BY 1,3
             ) as ao
         GROUP BY 1
     )
SELECT
    avg_mau.active_year as year,
    avg_mau.avg_customer as monthly_active_user,
    new_customer.total_new_customer,
    repeat_order.customer_repeat_order,
    avg_order.avg_order
FROM avg_mau
         JOIN new_customer on avg_mau.active_year = new_customer.years
         JOIN repeat_order on avg_mau.active_year = repeat_order.years
         JOIN avg_order on avg_mau.active_year = avg_order.years
ORDER BY 1 ASC
