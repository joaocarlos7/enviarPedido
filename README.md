# Enviar Pedido

Sistema de catálogo e pedidos utilizando Spring Boot + PostgreSQL.

---

## Pré-requisitos

- [Git](https://git-scm.com/)
- [Java 17+](https://www.azul.com/downloads/) (projeto usa Azul JDK)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [IntelliJ IDEA](https://www.jetbrains.com/idea/) ou outro IDE Java
- [DBeaver](https://dbeaver.io/) (ou outro para gerenciar o banco)
- WhatsApp (número ativo) opcional, se quiser testar enviar mensagem.

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


## 5. Executar a aplicação

### Via IntelliJ IDEA

1. Abra o projeto no IntelliJ
2. Aguarde o Maven baixar as dependências
3. Opcional (para encaminhar o pedido no WhatsApp, acesse scripts.js edite a linha 148 com o número '55DD+número'
4. Localize a classe `enviarPedidoApplication.java`
5. Clique no botão **Run** (▶) ou use `Shift + F10`

### Via terminal

```bash
./mvnw spring-boot:run
```

Aguarde a mensagem:
```
Started PedidoFeitoApplication in X.XXX seconds
```

---

## 6. Acessar a API

A aplicação estará disponível em: **http://localhost:8080**

---

## Prints de Execução

![PRINTS](docs/images/)

---

## Autoria

```bash

Desenvolvido por João Carlos Vieira Machado.

LinkedIn: https://www.linkedin.com/in/jo%C3%A3o-carlos-machado-3ab280100/
