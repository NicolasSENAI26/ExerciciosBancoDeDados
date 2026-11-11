CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(10, 2) NOT NULL
);

CREATE TABLE historico_carreira (
    id SERIAL PRIMARY KEY,
    func_id INT NOT NULL,
    cargo_ant VARCHAR(50),
    cargo_novo VARCHAR(50),
    sal_ant NUMERIC(10, 2),
    sal_novo NUMERIC(10, 2),
    data_alt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_carreira()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.cargo IS DISTINCT FROM NEW.cargo OR
       OLD.salario IS DISTINCT FROM NEW.salario THEN

        INSERT INTO historico_carreira
        (func_id, cargo_ant, cargo_novo, sal_ant, sal_novo)
        VALUES
        (OLD.id, OLD.cargo, NEW.cargo, OLD.salario, NEW.salario);

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER salvar_historico
AFTER UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION log_carreira();

INSERT INTO funcionarios (nome, cargo, salario)
VALUES ('Nicolas', 'Desenvolvedor Jr', 3500.00);

UPDATE funcionarios
SET cargo = 'Desenvolvedora Pleno', salario = 5500.00
WHERE id = 1;

SELECT * FROM historico_carreira;