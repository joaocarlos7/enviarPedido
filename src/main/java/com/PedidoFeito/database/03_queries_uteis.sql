COPY public.produtos (code, name, unit, price, category, page)
    FROM '/caminho/absoluto/produtos.csv'
    DELIMITER ','
    CSV HEADER
    ENCODING 'UTF8';