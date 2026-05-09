CREATE TABLE public.produtos (
                                 code     INTEGER      NOT NULL,
                                 name     VARCHAR(200) NOT NULL,
                                 unit     VARCHAR(10)  NOT NULL,
                                 price    NUMERIC(10,2) NOT NULL,
                                 category VARCHAR(50)  NOT NULL,
                                 page     INTEGER      NOT NULL,
                                 CONSTRAINT pk_produtos PRIMARY KEY (code)
);