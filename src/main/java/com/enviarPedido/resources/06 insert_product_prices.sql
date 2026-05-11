INSERT INTO product_prices (
    product_id,
    price,
    valid_from,
    valid_until
)
SELECT
    id,
    price,
    NOW(),
    NULL
FROM products
WHERE price IS NOT NULL;