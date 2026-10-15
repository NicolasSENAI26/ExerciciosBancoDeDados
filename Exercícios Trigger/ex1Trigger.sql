CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    nome_item VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0
);

CREATE OR REPLACE FUNCTION fn_valida_estoque_minimo()
RETURNS TRIGGER $$
BEGIN
	IF NEW.quantidade < 0 THEN


$$ LANGUAGE plpgsql;