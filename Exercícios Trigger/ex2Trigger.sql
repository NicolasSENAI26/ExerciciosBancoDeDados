CREATE TABLE contas (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    saldo NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE movimentacoes (
    id SERIAL PRIMARY KEY,
    conta INT REFERENCES contas(id),
    tipo VARCHAR(1) CHECK (tipo IN ('C', 'D')),
    valor NUMERIC(10, 2) NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION atualizar_saldo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'C' THEN
        UPDATE contas
        SET saldo = saldo + NEW.valor
        WHERE id = NEW.conta;

    ELSE
        UPDATE contas
        SET saldo = saldo - NEW.valor
        WHERE id = NEW.conta;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualizar_conta
AFTER INSERT ON movimentacoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_saldo();