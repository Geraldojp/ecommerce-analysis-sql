CREATE TABLE order_reviews_dataset(
                                      review_id varchar(255),
                                      order_id varchar(255),
                                      review_score smallint,
                                      review_comment_tittle varchar(255),
                                      review_comment_message varchar(255),
                                      review_creation_date timestamp,
                                      review_answer_timestamp TIMESTAMP,
                                      PRIMARY KEY (review_id),
                                      FOREIGN KEY (order_id) REFERENCES orders_dataset (order_id)
);
ALTER TABLE order_items_dataset
    ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
        REFERENCES orders_dataset(order_id);
ALTER TABLE order_items_dataset
    ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id)
        REFERENCES products_dataset(product_id);
ALTER TABLE order_items_dataset
    ADD CONSTRAINT fk_seller_id FOREIGN KEY (seller_id)
        REFERENCES seller_dataset(seller_id);
ALTER TABLE order_payments_dataset
    ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
        REFERENCES orders_dataset(order_id);
ALTER TABLE order_reviews_dataset
    ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
        REFERENCES orders_dataset(order_id);
ALTER TABLE orders_dataset
    ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
        REFERENCES customer_dataset(customer_id);
