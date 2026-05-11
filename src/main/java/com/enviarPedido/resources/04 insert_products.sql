INSERT INTO products (
    code,
    name,
    unit,
    price,
    category_id
)
SELECT
    p.code,
    p.name,
    p.unit,
    p.price,
    c.id
FROM products_import p
JOIN categories c
    ON c.name = p.category;