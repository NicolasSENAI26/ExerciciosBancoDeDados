CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    qtd INT NOT NULL DEFAULT 0
);

CREATE OR REPLACE FUNCTION validar_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.qtd < 0 THEN
        RAISE EXCEPTION 'O estoque não pode ser negativo!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_estoque
BEFORE INSERT OR UPDATE ON estoque
FOR EACH ROW
EXECUTE FUNCTION validar_estoque();