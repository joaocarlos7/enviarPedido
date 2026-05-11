DROP TABLE IF EXISTS products_import;

CREATE TEMP TABLE products_import (
    code INTEGER,
    name TEXT,
    unit VARCHAR(10),
    price NUMERIC(10,2),
    category TEXT
);