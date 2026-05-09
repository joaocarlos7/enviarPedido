-- =============================================================
-- SETUP - pedidoFeito
-- Execute na ordem: 1_create_tables, 2_import, 3_update_price
-- =============================================================


-- =============================================================
-- 1. CRIAR TABELAS
-- =============================================================

CREATE TABLE IF NOT EXISTS categories (
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
    id          BIGSERIAL PRIMARY KEY,
    code        VARCHAR(20)  NOT NULL UNIQUE,
    name        VARCHAR(255) NOT NULL,
    unit        VARCHAR(10)  NOT NULL,
    category_id BIGINT NOT NULL REFERENCES categories(id)
);

-- Tabela unificada de preços (atual + histórico)
-- Preço atual  : valid_until IS NULL
-- Preço antigo : valid_until IS NOT NULL
CREATE TABLE IF NOT EXISTS product_prices (
    id          BIGSERIAL PRIMARY KEY,
    product_id  BIGINT         NOT NULL REFERENCES products(id),
    price       NUMERIC(10, 2) NOT NULL,
    valid_from  TIMESTAMP      NOT NULL DEFAULT NOW(),
    valid_until TIMESTAMP      NULL
);

-- Índices úteis para as queries do ProductService
CREATE INDEX IF NOT EXISTS idx_product_prices_product_current
    ON product_prices(product_id) WHERE valid_until IS NULL;

CREATE INDEX IF NOT EXISTS idx_products_code  ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_name  ON products(name);


-- =============================================================
-- 2. IMPORTAR DO CSV
-- Ajuste o caminho abaixo para o caminho absoluto do arquivo
-- no seu sistema antes de executar.
-- =============================================================

-- Passo 2a: tabela temporária para receber o CSV bruto
CREATE TEMP TABLE tmp_import (
    code     VARCHAR(20),
    name     VARCHAR(255),
    unit     VARCHAR(10),
    price    NUMERIC(10, 2),
    category VARCHAR(100),
    page     INT
);

-- Passo 2b: copiar o CSV para a tabela temporária
-- ATENÇÃO: substitua o caminho abaixo pelo caminho real do arquivo no seu computador
COPY tmp_import (code, name, unit, price, category, page)
FROM '/tmp/produtos.csv'
DELIMITER ','
CSV HEADER;

-- Passo 2c: inserir categorias únicas
INSERT INTO categories (name)
SELECT DISTINCT category FROM tmp_import
ON CONFLICT (name) DO NOTHING;

-- Passo 2d: inserir produtos
INSERT INTO products (code, name, unit, category_id)
SELECT
    t.code,
    t.name,
    t.unit,
    c.id
FROM tmp_import t
JOIN categories c ON c.name = t.category
ON CONFLICT (code) DO NOTHING;

-- Passo 2e: inserir preços atuais (valid_until NULL = preço vigente)
INSERT INTO product_prices (product_id, price, valid_from)
SELECT
    p.id,
    t.price,
    NOW()
FROM tmp_import t
JOIN products p ON p.code = t.code;

DROP TABLE tmp_import;


-- =============================================================
-- 3. ATUALIZAR PREÇO DE UM PRODUTO
-- Fecha o preço atual e insere o novo como vigente.
-- Substitua :product_id e :novo_preco pelos valores reais.
-- =============================================================

-- Fechar preço atual
UPDATE product_prices
SET valid_until = NOW()
WHERE product_id = :product_id
  AND valid_until IS NULL;

-- Inserir novo preço vigente
INSERT INTO product_prices (product_id, price, valid_from)
VALUES (:product_id, :novo_preco, NOW());


-- =============================================================
-- CONSULTAS ÚTEIS
-- =============================================================

-- Preço atual de todos os produtos
SELECT p.code, p.name, p.unit, c.name AS category, pp.price
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN product_prices pp ON pp.product_id = p.id AND pp.valid_until IS NULL
ORDER BY p.name;

-- Histórico de preços de um produto específico
SELECT pp.price, pp.valid_from, pp.valid_until
FROM product_prices pp
JOIN products p ON p.id = pp.product_id
WHERE p.code = '9056'
ORDER BY pp.valid_from DESC;
