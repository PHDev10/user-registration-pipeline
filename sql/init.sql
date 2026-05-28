-- Tabela para receber os dados brutos digitados pelo usuário
CREATE TABLE cadastros_brutos (
    id SERIAL PRIMARY KEY,
    nome TEXT,
    email TEXT,
    cpf TEXT,
    data_nasc TEXT,
    criado_em TIMESTAMP DEFAULT NOW(),
    processado BOOLEAN DEFAULT FALSE
);

-- Tabela para receber os dados após processamento do Logstash
CREATE TABLE cadastros_processados (
    id SERIAL PRIMARY KEY,
    nome TEXT,
    email TEXT,
    cpf TEXT,
    data_nasc DATE,
    idade INTEGER,
    processado_em TIMESTAMP DEFAULT NOW()
);