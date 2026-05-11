COPY products_import(code, name, unit, price, category)
FROM '/tmp/produtos.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    ENCODING 'UTF8'
);

SELECT * FROM products_import LIMIT 10;