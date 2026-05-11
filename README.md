# Enviar Pedido

API REST em Spring Boot para consulta de produtos com suporte a filtros, paginação e histórico de preços.

---

## Pré-requisitos

- [Git](https://git-scm.com/)
- [Java 17+](https://www.azul.com/downloads/) (projeto usa Azul JDK)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [IntelliJ IDEA](https://www.jetbrains.com/idea/) ou outro IDE Java
- [DBeaver](https://dbeaver.io/) (ou outro para gerenciar o banco)

---

## 1. Clonar o repositório

```bash
git clone https://github.com/joaocarlos7/enviarPedido.git
cd enviarPedido
```

---

## 2. Instalar o Docker Desktop

1. Acesse [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Baixe a versão para o seu sistema operacional (Windows, Linux, Mac)
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

Deve aparecer um container chamado `enviarPedido` com status `Up`.

**Credenciais do banco:**

| Campo   | Valor        |
|---------|--------------|
| Host    | localhost    |
| Porta   | 5432         |
| Banco   | enviarPedido |
| Usuário | adm123       |
| Senha   | adm123       |

---

## 4. Criar as tabelas no banco

### No DBeaver

1. Abra o DBeaver e crie uma nova conexão PostgreSQL com as credenciais acima
2. Copie o arquivo CSV para dentro do container:
```bash
docker cp ./src/main/java/com/enviarPedido/resources/produtos.csv enviarPedido:/tmp/produtos.csv
```
4. Para criar as tabelas e importar os dados, rode os scripts em ordem da pasta resources no Script SQL do Dbeaver.

---

## 5. Configurar o application.properties

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
