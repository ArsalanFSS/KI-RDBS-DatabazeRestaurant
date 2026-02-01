from sqlalchemy import create_engine, text

engine = create_engine("mysql+pymysql://root:1234@localhost/restaurant")

# Jídelníček
with engine.connect() as conn:
    result = conn.execute(text("""
        SELECT kategorie, nazev, cena FROM Jidlo ORDER BY kategorie, nazev"""))

    print("\nMENU:")
    
    kategorie_jidel = None
    for kategorie, nazev, cena in result:
        if kategorie != kategorie_jidel:
            print(f"\n{kategorie.upper()}")
            print("-----------")
            kategorie_jidel = kategorie

        print(f"  {nazev:20} {cena:6.1f} Kč")

# Nápoje
with engine.connect() as conn:
    result = conn.execute(text("""
        SELECT nk.typ, n.nazev, n.cena 
        FROM Napoj n
        JOIN Napoj_kategorie nk ON n.kategorie = nk.ID_kategorie
        ORDER BY nk.typ, n.nazev"""))
    # spojení s tabulkou kategorií
    print("\nNÁPOJE:")
    
    aktualni_kategorie = None
    for kategorie, nazev_napoj, cena in result:
        if kategorie != aktualni_kategorie:
            kategorie_clean = kategorie.strip()
            print(f"\n{kategorie_clean.upper()}")
            print("-----------")
            aktualni_kategorie = kategorie

        print(f"  {nazev_napoj:20} {cena:6.1f} Kč")