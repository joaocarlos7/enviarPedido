DROP TABLE IF EXISTS public.produtos;

CREATE TABLE public.produtos (
                                 code        INTEGER         NOT NULL,
                                 name        VARCHAR(200)    NOT NULL,
                                 unit        VARCHAR(10)     NOT NULL,
                                 price       NUMERIC(10,2)   NOT NULL,
                                 category    VARCHAR(50)     NOT NULL,
                                 page        INTEGER         NOT NULL,
                                 CONSTRAINT pk_produtos PRIMARY KEY (code)
);

CREATE INDEX idx_produtos_category ON public.produtos (category);
CREATE INDEX idx_produtos_price    ON public.produtos (price);
CREATE INDEX idx_produtos_name     ON public.produtos USING gin(to_tsvector('portuguese', name));

-- Confirm
SELECT tablename, schemaname
FROM pg_tables
WHERE tablename = 'produtos';