# Pipeline de Cadastro e Validação com Logstash

Projeto desenvolvido para a disciplina de **Banco de Dados II**, com o objetivo de demonstrar na prática o funcionamento do **Logstash** como ferramenta de pipeline de dados, integrado ao **Spring Boot** e ao **PostgreSQL**.

---

## Descrição do Projeto

A aplicação simula um sistema de cadastro de usuários com **validação e transformação automática de dados**. O usuário insere informações pelo terminal por meio de uma interface de menu desenvolvida em Spring Boot. Esses dados são armazenados em estado bruto no banco de dados e, em seguida, processados automaticamente pelo Logstash, que realiza limpeza, formatação e enriquecimento dos dados, gravando o resultado final em uma segunda tabela.

Esse fluxo demonstra o papel do Logstash como **middleware de dados**, atuando na camada de ETL (Extract, Transform, Load) entre duas tabelas do PostgreSQL.

---

## Fluxo de Funcionamento

```
Usuário digita no terminal
        ↓
[Spring Boot] coleta os dados e salva em cadastros_brutos (processado = false)
        ↓
[Logstash] detecta o novo registro não processado
        ↓
[Logstash - Filter] limpa, formata e enriquece os dados
        ↓
[Logstash - Output] insere os dados tratados em cadastros_processados
        ↓
[Logstash - Output] atualiza processado = true em cadastros_brutos
        ↓
Dados disponíveis e tratados no banco de dados
```

---

## Transformações Realizadas pelo Logstash

| Campo       | Dado bruto (exemplo)   | Após processamento    |
|-------------|------------------------|-----------------------|
| `nome`      | `"  joão silva "`      | `"João Silva"`        |
| `email`     | `"JOAO@EMAIL.COM"`     | `"joao@email.com"`    |
| `cpf`       | `"12345678900"`        | `"123.456.789-00"`    |
| `data_nasc` | `"15/08/2000"`         | `2000-08-15` (DATE)   |
| `idade`     | —                      | `24` (calculada)      |

---

## Estrutura do Projeto

```
projeto-logstash/
│
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/projectlogstash/projeto_logstash/
│   │   │       ├── ProjetoLogstashApplication.java   # Ponto de entrada da aplicação
│   │   │       ├── model/
│   │   │       │   └── CadastroBruto.java            # Entidade da tabela bruta
│   │   │       ├── repository/
│   │   │       │   └── CadastroBrutoRepository.java  # Persistência via Spring Data JPA
│   │   │       └── menu/
│   │   │           └── MenuCadastro.java             # Interface de menu no terminal
│   │   └── resources/
│   │       └── application.properties                # Configurações do banco e da aplicação
│   └── test/
│       └── java/
│           └── com/projectlogstash/projeto_logstash/
│               └── ProjetoLogstashApplicationTests.java
│
├── logstash/
│   └── pipeline/
│       └── cadastro.conf                             # Configuração do pipeline do Logstash
│
├── sql/
│   └── init.sql                                      # Script de criação das tabelas
│
├── .gitignore
├── HELP.md
├── mvnw
├── mvnw.cmd
├── pom.xml
└── README.md
```

---

## Estrutura do Banco de Dados

### Tabela `cadastros_brutos`
Recebe os dados exatamente como digitados pelo usuário, sem nenhum tratamento.

```sql
CREATE TABLE cadastros_brutos (
    id          SERIAL PRIMARY KEY,
    nome        TEXT,
    email       TEXT,
    cpf         TEXT,
    data_nasc   TEXT,
    criado_em   TIMESTAMP DEFAULT NOW(),
    processado  BOOLEAN DEFAULT FALSE
);
```

### Tabela `cadastros_processados`
Recebe os dados após limpeza, formatação e enriquecimento realizados pelo Logstash.

```sql
CREATE TABLE cadastros_processados (
    id              SERIAL PRIMARY KEY,
    nome            TEXT,
    email           TEXT,
    cpf             TEXT,
    data_nasc       DATE,
    idade           INTEGER,
    processado_em   TIMESTAMP DEFAULT NOW()
);
```

> O campo `processado` na tabela bruta é o controle utilizado pelo Logstash para identificar quais registros ainda precisam ser tratados.

---

## Tecnologias Utilizadas

| Tecnologia         | Versão recomendada |
|--------------------|--------------------|
| Java               | 17 ou 21           |
| Spring Boot        | 3.x                |
| Spring Data JPA    | Incluso no Spring Boot |
| PostgreSQL Driver  | Incluso via dependência Maven |
| Logstash           | 8.x                |
| PostgreSQL         | 15 ou 16           |

---

## Pré-requisitos

Antes de executar o projeto, certifique-se de ter instalado:

- [Java JDK 17+](https://adoptium.net/)
- [Apache Maven](https://maven.apache.org/)
- [PostgreSQL 15+](https://www.postgresql.org/download/)
- [Logstash 8.x](https://www.elastic.co/downloads/logstash)
- [Driver JDBC do PostgreSQL](https://jdbc.postgresql.org/download/) — necessário para o Logstash se conectar ao banco

---

## Como Executar

### 1. Banco de Dados

Crie o banco de dados e execute o script de inicialização:

```bash
psql -U postgres -c "CREATE DATABASE projetologstash;"
psql -U postgres -d projetologstash -f sql/init.sql
```

---

### 2. Aplicação Spring Boot

Acesse a pasta da aplicação, configure as credenciais do banco em `application.properties` e execute:

```bash
cd spring-app
mvn spring-boot:run
```

O menu de cadastro será exibido no terminal.

---

### 3. Pipeline do Logstash

Com o Logstash instalado, execute o pipeline apontando para o arquivo de configuração:

```bash
logstash -f logstash/pipeline/cadastro.conf
```

O Logstash passará a monitorar a tabela `cadastros_brutos` e processar os novos registros automaticamente.

---

## Configuração — `application.properties`

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/projetologstash
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=none
```

---

## Dependências Maven — `pom.xml`

```xml
<dependencies>

    <!-- Spring Boot -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>

    <!-- Spring Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- Driver PostgreSQL -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>

</dependencies>
```

---

## Autores

Desenvolvido por **Pedro Henrique Santos de Pontes** e **Artur Crispim de Andrade** para a disciplina de Banco de Dados II.