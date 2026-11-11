CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT TRUE
);


CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    funcionario_id INT REFERENCES funcionarios(id),
    email VARCHAR(100) NOT NULL UNIQUE,
    senha TEXT NOT NULL
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);


CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    funcionario_id INT REFERENCES funcionarios(id),
    categoria_id INT REFERENCES categorias(id),
    status VARCHAR(30) DEFAULT 'Pendente'
    CHECK (status IN ('Pendente', 'Em andamento', 'Concluida')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_entrega DATE NOT NULL
);


CREATE TABLE historico_tarefas (
    id SERIAL PRIMARY KEY,
    tarefa_id INT REFERENCES tarefas(id),
    acao VARCHAR(100),
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION login(
    p_email VARCHAR,
    p_senha VARCHAR
)
RETURNS TEXT AS $$
DECLARE
    senha_banco TEXT;
BEGIN
    SELECT senha INTO senha_banco
    FROM usuarios
    WHERE email = p_email;

    IF senha_banco IS NULL THEN
        RETURN 'Email ou senha incorretos';
    END IF;

    IF senha_banco = crypt(p_senha, senha_banco) THEN
        RETURN 'Login realizado';
    ELSE
        RETURN 'Email ou senha incorretos';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION salva_historico()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_tarefas (tarefa_id, acao)
    VALUES (NEW.id, 'Tarefa criada');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER salva_historico
AFTER INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION salva_historico();

--não fiz o segundo trigger pq não consegui fazer a outra function

CREATE VIEW painel_principal AS
SELECT
    f.nome AS funcionario,
    t.titulo,
    c.nome AS categoria,
    t.data_entrega,
    t.status
FROM tarefas t
JOIN funcionarios f ON t.funcionario_id = f.id
JOIN categorias c ON t.categoria_id = c.id;


CREATE VIEW prazos AS
SELECT
    t.titulo,
    f.nome AS responsavel,
    t.data_entrega,
    t.status,
    t.data_entrega - CURRENT_DATE AS dias_restantes
FROM tarefas t
JOIN funcionarios f ON t.funcionario_id = f.id
ORDER BY t.data_entrega ASC;

INSERT INTO funcionarios (nome, email, ativo) VALUES
('Nicolas', 'nicolas@email.com', TRUE),
('Guilherme', 'guilherme@email.com', TRUE),
('Manuela', 'manuela@email.com', TRUE);

INSERT INTO usuarios (funcionario_id, email, senha) VALUES
(1, 'nicolas@email.com', '123456',),
(2, 'guilherme@email.com', '123456',),
(3, 'manuela@email.com', '123456',);

INSERT INTO categorias (nome) VALUES
('A fazer'),
('Desenvolvimento'),
('Concluido');

INSERT INTO tarefas (titulo, descricao, funcionario_id, categoria_id, data_entrega) VALUES
('Fazer trabalho', 'Terminar atividade da escola', 1, 1, '2026-11-15'),
('Criar sistema', 'Fazer o sistema da empresa', 2, 2, '2026-11-20'),
('Organizar arquivos', 'Separar os documentos', 3, 3, '2026-11-25');

--os comandos para testar estava sem tempo então optei por não colocar