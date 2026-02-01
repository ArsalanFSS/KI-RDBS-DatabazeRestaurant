DROP DATABASE IF EXISTS Restaurant;
CREATE DATABASE Restaurant;
USE Restaurant;

CREATE TABLE Jidlo_kategorie (
    ID_kategorie VARCHAR(50) PRIMARY KEY,
    kategorie_nazev VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Jidlo_kategorie.txt'
INTO TABLE Jidlo_kategorie
FIELDS TERMINATED BY '|';
SELECT * FROM Jidlo_kategorie;

CREATE TABLE Jidlo_menu (
    IDjidlo INT PRIMARY KEY,
    ID_objednavka INT,
    kus INT
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Jidlo_menu.txt'
INTO TABLE Jidlo_menu
FIELDS TERMINATED BY '|';
SELECT * FROM Jidlo_menu;

CREATE TABLE Jidlo (
    ID_jidlo INT PRIMARY KEY,
    nazev VARCHAR(50),
    popis TEXT,
    cena DECIMAL(10, 2),
    kategorie VARCHAR(50),
    FOREIGN KEY (ID_jidlo) REFERENCES Jidlo_menu (IDjidlo),
    FOREIGN KEY (kategorie) REFERENCES Jidlo_kategorie (ID_kategorie)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Jidlo.txt'
INTO TABLE Jidlo
FIELDS TERMINATED BY '|';
SELECT * FROM Jidlo;

CREATE TABLE Napoj_kategorie (
    ID_kategorie VARCHAR(50) PRIMARY KEY,
    typ VARCHAR(50)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Napoj_kategorie.txt'
INTO TABLE Napoj_kategorie
FIELDS TERMINATED BY '|';
SELECT * FROM Napoj_kategorie;

CREATE TABLE Napoj_menu (
    ID_napoj INT PRIMARY KEY,
    ID_objednavka INT,
    kus INT
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Napoj_menu.txt'
INTO TABLE Napoj_menu
FIELDS TERMINATED BY '|';
SELECT * FROM Napoj_menu;

CREATE TABLE Napoj (
    ID_napoj INT PRIMARY KEY,
    nazev VARCHAR(50),
    popis TEXT,
    cena DECIMAL(10, 2),
    kategorie VARCHAR(50),
    FOREIGN KEY (ID_napoj) REFERENCES Napoj_menu (ID_napoj),
    FOREIGN KEY (kategorie) REFERENCES Napoj_kategorie (ID_kategorie)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Napoj.txt'
INTO TABLE Napoj
FIELDS TERMINATED BY '|';
SELECT * FROM Napoj;

CREATE TABLE Stul (
    ID_stul INT PRIMARY KEY,
    kapacita INT
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Stul.txt'
INTO TABLE Stul
FIELDS TERMINATED BY '|';
SELECT * FROM Stul;

CREATE TABLE pozice_zam (
    nazev_pozice VARCHAR(50) PRIMARY KEY,
    plat DECIMAL(10, 2)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/pozice_zam.txt'
INTO TABLE pozice_zam
FIELDS TERMINATED BY '|';
SELECT * FROM pozice_zam;

CREATE TABLE Zamestnanec (
    ID_zamestnanec INT PRIMARY KEY,
    jmeno VARCHAR(50),
    prijmeni VARCHAR(50),
    pozice VARCHAR(50),
    plat DECIMAL(10, 2),
    FOREIGN KEY (pozice) REFERENCES pozice_zam (nazev_pozice)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/Zamestnanec.txt'
INTO TABLE Zamestnanec
FIELDS TERMINATED BY '|';
SELECT * FROM Zamestnanec;

CREATE TABLE kuchyn (
    ID_objednavka INT PRIMARY KEY,
    cislo_stul INT,
    ID_zamestnanec INT,
    FOREIGN KEY (cislo_stul) REFERENCES Stul (ID_stul),
    FOREIGN KEY (ID_zamestnanec) REFERENCES Zamestnanec (ID_zamestnanec)
);
LOAD DATA LOCAL INFILE 'F:/databaze_restaurant/data/kuchyn.txt'
INTO TABLE kuchyn
FIELDS TERMINATED BY '|';
SELECT * FROM kuchyn;

