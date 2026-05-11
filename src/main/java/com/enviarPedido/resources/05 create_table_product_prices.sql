CREATE TABLE product_prices (
                                id BIGSERIAL PRIMARY KEY,
                                product_id BIGINT NOT NULL,
                                price NUMERIC(10,2) NOT NULL,
                                valid_from TIMESTAMP NOT NULL DEFAULT NOW(),
                                valid_until TIMESTAMP NULL,

                                CONSTRAINT fk_product_prices_product
                                    FOREIGN KEY (product_id)
                                        REFERENCES products(id)
                                        ON DELETE CASCADE
);