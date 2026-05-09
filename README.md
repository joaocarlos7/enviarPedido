# pedidoFeito

API REST em Spring Boot para consulta de produtos com suporte a filtros, paginação e histórico de preços.

---

## Pré-requisitos

- [Git](https://git-scm.com/)
- [Java 17+](https://www.azul.com/downloads/) (projeto usa Azul JDK)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [IntelliJ IDEA](https://www.jetbrains.com/idea/) ou outro IDE Java
- [DBeaver](https://dbeaver.io/) (opcional, para gerenciar o banco)
- Número de Whatsapp Ativo(Colocar em: script.js linha: 148 entre ''')

---

## 1. Clonar o repositório

```bash
git clone https://github.com/joaocarlos7/pedidoFeito.git
cd pedidoFeito
```

---

## 2. Instalar o Docker Desktop

1. Acesse [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Baixe a versão para o seu sistema operacional (Mac, Windows ou Linux)
3. Instale e abra o Docker Desktop
4. Aguarde o ícone da baleia aparecer na barra de status — significa que o Docker está rodando

---

## 3. Subir o container do PostgreSQL

Na raiz do projeto (onde está o `docker-compose.yml`), execute:

```bash
docker compose up -d
```

Verifique se o container subiu:

```bash
docker ps
```

Deve aparecer um container chamado `pedidoFeito` com status `Up`.

**Credenciais do banco:**

| Campo   | Valor            |
|---------|------------------|
| Host    | localhost        |
| Porta   | 5432             |
| Banco   | pedidoFeitoDb    |
| Usuário | pedidoFeitoAdmin |
| Senha   | pedidofeito123   |

---

## 4. Criar as tabelas no banco

### Via DBeaver

1. Abra o DBeaver e crie uma nova conexão PostgreSQL com as credenciais acima
2. Expanda a conexão → **Bancos de dados → pedidoFeitoDb → Esquemas → public**
3. Abra o arquivo `src/main/resources/setup.sql` no DBeaver (**Arquivo → Abrir arquivo**)
4. **Importante:** verifique no seletor do editor SQL (canto superior direito) que o banco ativo é `pedidoFeitoDb` — não `postgres`. Para confirmar, execute: `SELECT current_database();`
5. Execute o bloco **1 — CRIAR TABELAS** (Ctrl+Enter ou botão Run)

### Via terminal

```bash
docker exec -i pedidoFeito psql -U pedidoFeitoAdmin -d pedidoFeitoDb < src/main/resources/setup.sql
```

---

## 5. Importar os produtos do CSV

### Passo 1 — Copiar o CSV para dentro do container

O comando `COPY` do PostgreSQL roda **dentro do container** e não tem acesso aos arquivos do seu computador. Por isso é necessário copiar o arquivo para dentro do container antes de executar a importação.

No terminal, na raiz do projeto:

```bash
docker cp src/main/resources/produtos.csv pedidoFeito:/tmp/produtos.csv
```

Verifique se o arquivo chegou:

```bash
docker exec pedidoFeito ls /tmp/produtos.csv
```

Deve retornar `/tmp/produtos.csv` sem erros.

### Passo 2 — Executar a importação

No DBeaver, abra o `setup.sql`, certifique-se de que o banco `pedidoFeitoDb` está selecionado no seletor do editor SQL, e execute o **bloco 2 — IMPORTAR DO CSV**.

O caminho no script já está configurado para `/tmp/produtos.csv` (dentro do container).

Ou via terminal:

```bash
docker exec -i pedidoFeito psql -U pedidoFeitoAdmin -d pedidoFeitoDb << 'EOF'
CREATE TEMP TABLE tmp_import (
    code VARCHAR(20), name VARCHAR(255), unit VARCHAR(10),
    price NUMERIC(10,2), category VARCHAR(100), page INT
);
COPY tmp_import FROM '/tmp/produtos.csv' DELIMITER ',' CSV HEADER;
INSERT INTO categories (name)
    SELECT DISTINCT category FROM tmp_import ON CONFLICT (name) DO NOTHING;
INSERT INTO products (code, name, unit, category_id)
    SELECT t.code, t.name, t.unit, c.id FROM tmp_import t
    JOIN categories c ON c.name = t.category ON CONFLICT (code) DO NOTHING;
INSERT INTO product_prices (product_id, price, valid_from)
    SELECT p.id, t.price, NOW() FROM tmp_import t
    JOIN products p ON p.code = t.code;
EOF
```

---

## 6. Configurar o application.properties

Verifique se o arquivo `src/main/resources/application.properties` está assim:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/pedidoFeitoDb
spring.datasource.username=pedidoFeitoAdmin
spring.datasource.password=pedidofeito123

spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

---

## 7. Executar a aplicação

### Via IntelliJ IDEA

1. Abra o projeto no IntelliJ
2. Aguarde o Maven baixar as dependências
3. Localize a classe `PedidoFeitoApplication.java`
4. Clique no botão **Run** (▶) ou use `Shift + F10`

### Via terminal

```bash
./mvnw spring-boot:run
```

Aguarde a mensagem:
```
Started PedidoFeitoApplication in X.XXX seconds
```

---

## 8. Acessar a API

A aplicação estará disponível em: **http://localhost:8080**

### Endpoints disponíveis

#### Produtos — `GET /products`

| Parâmetro  | Tipo   | Obrigatório | Descrição                        |
|------------|--------|-------------|----------------------------------|
| `search`   | string | não*        | Busca parcial pelo nome          |
| `code`     | string | não*        | Busca exata pelo código          |
| `category` | string | não*        | Filtra por categoria             |
| `page`     | int    | não         | Página (default: 0)              |
| `size`     | int    | não         | Itens por página (default: 20)   |

*Ao menos um dos três primeiros é obrigatório.

**Exemplos:**

```bash
# Buscar por nome
GET http://localhost:8080/products?search=açúcar

# Buscar por código
GET http://localhost:8080/products?code=9056

# Buscar por categoria
GET http://localhost:8080/products?category=Bebidas

# Combinar filtros com paginação
GET http://localhost:8080/products?search=vinho&category=Bebidas Alcoólicas&page=0&size=10
```

#### Categorias — `GET /categories`

Retorna todas as categorias cadastradas.

```bash
GET http://localhost:8080/categories
```

---

## 9. Atualizar preço de um produto

Execute no DBeaver ou psql substituindo `product_id` e o novo valor:

```sql
-- Fechar preço atual
UPDATE product_prices
SET valid_until = NOW()
WHERE product_id = 1 AND valid_until IS NULL;

-- Inserir novo preço vigente
INSERT INTO product_prices (product_id, price, valid_from)
VALUES (1, 29.90, NOW());
```

---

## Estrutura do projeto

```
src/main/java/com/PedidoFeito/
├── controller/
│   ├── CategoryController.java
│   └── ProductController.java
├── service/
│   ├── CategoryService.java
│   └── ProductService.java
├── repository/
│   ├── CategoryRepository.java
│   ├── ProductRepository.java
│   └── ProductPriceRepository.java
├── model/
│   ├── Category.java
│   ├── Product.java
│   └── ProductPrice.java
├── dto/
│   └── ProductResponse.java
└── PedidoFeitoApplication.java

src/main/resources/
├── application.properties
├── setup.sql
└── produtos.csv
```

---

## Estrutura do banco

```
categories
├── id   (PK)
└── name (UNIQUE)

products
├── id          (PK)
├── code        (UNIQUE)
├── name
├── unit
└── category_id (FK → categories.id)

product_prices
├── id
├── product_id  (FK → products.id)
├── price
├── valid_from
└── valid_until  ← NULL = preço atual | preenchido = histórico
```

---

## Parar o container

```bash
# Parar mantendo os dados
docker compose down

# Parar e remover todos os dados
docker compose down -v
```


---

## Autoria

```bash

Desenvolvido por João Carlos Vieira Machado.

LinkedIn: https://www.linkedin.com/in/jo%C3%A3o-carlos-machado-3ab280100/
