-- prumerny pocet zaznamu na tabulku
SELECT AVG(pocet) AS prumerny_pocet_zaznamu
FROM (
    SELECT COUNT(*) AS pocet FROM Jidlo
    UNION ALL SELECT COUNT(*) FROM Jidlo_menu
    UNION ALL SELECT COUNT(*) FROM Jidlo_kategorie
    UNION ALL SELECT COUNT(*) FROM Napoj
    UNION ALL SELECT COUNT(*) FROM Napoj_menu
    UNION ALL SELECT COUNT(*) FROM Napoj_kategorie
    UNION ALL SELECT COUNT(*) FROM Zamestnanec
    UNION ALL SELECT COUNT(*) FROM Stul
    UNION ALL SELECT COUNT(*) FROM kuchyn
) t;

-- vnoreny SELECT
--- Zamestnanci s platem vyssim nez prumerny plat
SELECT jmeno, prijmeni, plat
FROM Zamestnanec
WHERE plat > (
    SELECT AVG(plat) FROM Zamestnanec
);

--- Celkova cena jidel podle kategorie + poradi
SELECT 
    kategorie,
    SUM(cena) AS suma_cen,
    RANK() OVER (ORDER BY SUM(cena) DESC) AS poradi
FROM Jidlo
GROUP BY kategorie;

--- Pridani nadrizeneho zamestnance
ALTER TABLE Zamestnanec
ADD nadrizeny INT NULL,
ADD FOREIGN KEY (nadrizeny) REFERENCES Zamestnanec(ID_zamestnanec);
--
SELECT 
    z1.jmeno AS zamestnanec,
    z2.jmeno AS nadrizeny
FROM Zamestnanec z1
LEFT JOIN Zamestnanec z2 ON z1.nadrizeny = z2.ID_zamestnanec;

-- VIEW
--- Prehled objednavek: stul, zamestnanec, jidlo a cena
CREATE OR REPLACE VIEW v_objednavky AS
SELECT 
    k.ID_objednavka,
    s.ID_stul,
    z.jmeno,
    z.prijmeni,
    j.nazev AS jidlo,
    j.cena
FROM kuchyn k
INNER JOIN Stul s ON k.cislo_stul = s.ID_stul
INNER JOIN Zamestnanec z ON k.ID_zamestnanec = z.ID_zamestnanec
INNER JOIN Jidlo_menu jm ON k.ID_objednavka = jm.ID_objednavka
INNER JOIN Jidlo j ON jm.IDjidlo = j.ID_jidlo;

SELECT * FROM v_objednavky;
-- INDEX
--- Unikatni index
CREATE UNIQUE INDEX IF NOT EXISTS idx_jidlo_nazev
ON Jidlo(nazev);

INSERT INTO Jidlo values ('33', 'Tiramisu', 'jidlo', 12, 'Dezert');

-- Fulltext index
ALTER TABLE Jidlo
ADD FULLTEXT INDEX idx_jidlo_popis (popis);

SELECT * FROM Jidlo WHERE MATCH(popis) AGAINST('hranol');

-- FUNCTION
--- Celkova cena objednavky (jidlo)
DELIMITER $$

CREATE OR REPLACE FUNCTION celkova_cena_objednavky(p_objednavka INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE celkova_cena DECIMAL(10,2);

    SELECT SUM(j.cena * jm.kus)
    INTO celkova_cena
    FROM Jidlo_menu jm
    JOIN Jidlo j ON jm.IDjidlo = j.ID_jidlo
    WHERE jm.ID_objednavka = p_objednavka;

    RETURN IFNULL(celkova_cena, 0);
END$$


SELECT celkova_cena_objednavky(1);

-- TRANSACTION
--- Presun ceny mezi jidly 
START TRANSACTION;
UPDATE Jidlo
SET cena = cena - 10
WHERE ID_jidlo = 1;
UPDATE Jidlo
SET cena = cena + 10
WHERE ID_jidlo = 2;
COMMIT;

SELECT ID_jidlo, nazev, cena 
FROM Jidlo 
WHERE ID_jidlo IN (1, 2);

-- PROCEDURE + CURSOR + HANDLER
--- Zvysi cenu o 5%

DROP PROCEDURE IF EXISTS zvys_ceny_safe;

DELIMITER $$

CREATE PROCEDURE zvys_ceny_safe()
BEGIN
    UPDATE Jidlo SET cena = 100 WHERE cena IS NULL;
    
    UPDATE Jidlo
    SET cena = cena * 1.05;
    
    SELECT CONCAT('Ceny zvyseny o 5%. ', ROW_COUNT(), ' jídel.') AS Zprava;
END$$

DELIMITER ;

CALL zvys_ceny_safe();

-- TRIGGER (DELIMITER)
--- log zmeny ceny jidla
DROP TRIGGER IF EXISTS trg_cena_update;

DELIMITER $$

CREATE TRIGGER trg_cena_update
AFTER UPDATE ON Jidlo
FOR EACH ROW
BEGIN
    IF OLD.cena <> NEW.cena THEN
        INSERT INTO log_cen(
            ID_jidlo, nazev, kategorie, stara_cena, nova_cena, rozdil, procentni_zmena, datum_zmeny
        )
        VALUES (
            OLD.ID_jidlo, OLD.nazev, COALESCE(OLD.kategorie, 'Neznama'), 
            OLD.cena, NEW.cena, NEW.cena - OLD.cena,
            CASE 
                WHEN OLD.cena = 0 THEN 0
                ELSE ROUND(((NEW.cena - OLD.cena) / OLD.cena * 100), 2)
            END,
            NOW()
        );
    END IF;
END$$

DELIMITER ;

SELECT * FROM log_cen;

-- USER / ROLE
CREATE USER IF NOT EXISTS 'cisnik'@'localhost' IDENTIFIED BY 'heslo123';
GRANT SELECT, INSERT, UPDATE ON restaurant.* TO 'cisnik'@'localhost';
--- GRANT ALL PRIVILEGES ON restaurant.* TO 'cisnik'@'localhost';

FLUSH PRIVILEGES;
SHOW GRANTS;

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'cisnik'@'localhost';
DROP USER IF EXISTS 'cisnik'@'localhost';

UPDATE Jidlo SET cena = cena * 1.10 WHERE kategorie = 'Hlavní_chod';

-- LOCK
LOCK TABLE Jidlo WRITE; 
UNLOCK TABLES;

SELECT * FROM Jidlo;