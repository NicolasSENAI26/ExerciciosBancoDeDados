CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    quarto INT NOT NULL,
    entrada DATE NOT NULL,
    saida DATE NOT NULL,
    diaria NUMERIC(10, 2) NOT NULL,
    total NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION processar_reserva()
RETURNS TRIGGER AS $$
DECLARE
    dias INT;
BEGIN
    IF NEW.saida <= NEW.entrada THEN
        RAISE EXCEPTION 'A data de saida precisa ser maior que a entrada!';
    END IF;

    dias := NEW.saida - NEW.entrada;

    NEW.total := dias * NEW.diaria;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_reserva
BEFORE INSERT OR UPDATE ON reservas
FOR EACH ROW
EXECUTE FUNCTION processar_reserva();

-- Teste que deu errado
INSERT INTO reservas (quarto, entrada, saida, diaria)
VALUES (101, '2026-11-10', '2026-11-05', 200.00);

-- Teste que deu certo
INSERT INTO reservas (quarto, entrada, saida, diaria)
VALUES (101, '2026-11-01', '2026-11-06', 200.00);

SELECT * FROM reservas;