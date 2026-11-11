CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clientes_deletados_log (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION apagar_cliente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO clientes_deletados_log (cliente_id, nome, email)
    VALUES (OLD.id, OLD.nome, OLD.email);

    UPDATE clientes
    SET ativo = FALSE
    WHERE id = OLD.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER apagar_cliente_log
BEFORE DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION apagar_cliente();

INSERT INTO clientes (nome, email)
VALUES ('Manuela Urbano', 'manuelabobona@email.com');

DELETE FROM clientes WHERE id = 1;

SELECT * FROM clientes;
SELECT * FROM clientes_deletados_log;