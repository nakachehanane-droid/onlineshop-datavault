"""
Erzeugt die Testdaten für den fiktiven Onlineshop "NordLicht Wohnen".

Ladung 1 = Erstbefüllung (alle Stammdaten + Bestellungen Jan-Jun 2026)
Ladung 2 = Delta eine Woche später (geänderte Kunden, neue Kunden,
           Preisänderungen, neue Bestellungen, Statusänderungen)

Aufruf:  python tools/daten_erzeugen.py
Die Daten sind deterministisch (fester Seed) - jeder bekommt dieselben Zahlen.
"""
import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
BASIS = Path(__file__).resolve().parent.parent / "data"

VORNAMEN = ["Anna", "Ben", "Clara", "David", "Emma", "Felix", "Greta", "Hannes", "Ida", "Jonas",
            "Katrin", "Lukas", "Mia", "Noah", "Olga", "Paul", "Quirin", "Rosa", "Sven", "Tina",
            "Ulf", "Vera", "Willi", "Yasemin", "Zoe", "Ahmet", "Leila", "Marek", "Sofia", "Tom"]
NACHNAMEN = ["Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker",
             "Schulz", "Hoffmann", "Koch", "Richter", "Klein", "Wolf", "Schröder", "Neumann",
             "Yilmaz", "Kowalski", "Haddad", "Nguyen"]
STAEDTE = [("80331", "München"), ("10115", "Berlin"), ("20095", "Hamburg"), ("50667", "Köln"),
           ("60311", "Frankfurt am Main"), ("70173", "Stuttgart"), ("04109", "Leipzig"),
           ("90402", "Nürnberg"), ("01067", "Dresden"), ("28195", "Bremen")]
STRASSEN = ["Hauptstraße", "Bahnhofstraße", "Gartenweg", "Lindenallee", "Schulstraße",
            "Bergstraße", "Kirchplatz", "Am Markt", "Rosenweg", "Ringstraße"]
PRODUKTE = [
    ("Möbel", "Sofa Hygge 3-Sitzer", 899.00), ("Möbel", "Couchtisch Eiche", 249.00),
    ("Möbel", "Esstisch Fjord 180cm", 649.00), ("Möbel", "Stuhl Lund (2er Set)", 179.00),
    ("Möbel", "Bücherregal Birke", 199.00), ("Möbel", "Kommode Nord", 329.00),
    ("Leuchten", "Stehleuchte Bogen", 149.00), ("Leuchten", "Pendelleuchte Glas", 89.90),
    ("Leuchten", "Tischleuchte Messing", 69.90), ("Leuchten", "LED-Lichterkette 10m", 24.90),
    ("Textilien", "Wolldecke Grau", 59.90), ("Textilien", "Kissenhülle Leinen (2 Stk)", 29.90),
    ("Textilien", "Teppich Berber 160x230", 279.00), ("Textilien", "Vorhang Samt", 49.90),
    ("Deko", "Vase Keramik", 34.90), ("Deko", "Spiegel rund 60cm", 119.00),
    ("Deko", "Kerzenhalter Set", 19.90), ("Deko", "Bilderrahmen 30x40", 14.90),
    ("Küche", "Geschirrset 18-tlg", 129.00), ("Küche", "Gläser-Set 6 Stk", 39.90),
    ("Küche", "Schneidebrett Walnuss", 44.90), ("Küche", "Kaffeekanne Emaille", 32.90),
    ("Bad", "Handtuch-Set Bio", 49.90), ("Bad", "Badematte Baumwolle", 24.90),
    ("Bad", "Seifenspender Stein", 18.90),
]
STATUS = ["bezahlt", "versendet", "zugestellt"]


def schreibe(ordner: str, datei: str, kopf: list, zeilen: list):
    pfad = BASIS / ordner / datei
    pfad.parent.mkdir(parents=True, exist_ok=True)
    with open(pfad, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(kopf)
        w.writerows(zeilen)
    print(f"  {pfad.relative_to(BASIS.parent)}: {len(zeilen)} Zeilen")


def neuer_kunde(nr: int):
    vn, nn = random.choice(VORNAMEN), random.choice(NACHNAMEN)
    plz, stadt = random.choice(STAEDTE)
    email = f"{vn.lower()}.{nn.lower()}{nr % 100}@example.com".replace("ü", "ue").replace("ö", "oe")
    registriert = date(2025, 1, 1) + timedelta(days=random.randint(0, 520))
    return [f"K{nr:05d}", vn, nn, email, f"{random.choice(STRASSEN)} {random.randint(1, 120)}",
            plz, stadt, registriert.isoformat()]


def bestellungen(start_nr, anzahl, kunden_nrs, von: date, bis: date, preise):
    kopf_zeilen, pos_zeilen = [], []
    tage = (bis - von).days
    for i in range(anzahl):
        bnr = f"B{start_nr + i:06d}"
        datum = von + timedelta(days=random.randint(0, tage))
        status = random.choices(STATUS, weights=[1, 2, 6])[0] if datum < bis - timedelta(days=10) else random.choice(STATUS[:2])
        kopf_zeilen.append([bnr, random.choice(kunden_nrs), datum.isoformat(), status])
        for pos, pnr in enumerate(random.sample(list(preise), random.randint(1, 4)), start=1):
            pos_zeilen.append([bnr, pos, pnr, random.choice([1, 1, 1, 2, 3]), f"{preise[pnr]:.2f}"])
    return kopf_zeilen, pos_zeilen


def main():
    print("Ladung 1 ...")
    kunden = [neuer_kunde(n) for n in range(1, 121)]
    produkte = [[f"P{n:04d}", name, kat, f"{preis:.2f}"] for n, (kat, name, preis) in enumerate(PRODUKTE, start=1)]
    preise = {p[0]: float(p[3]) for p in produkte}
    b1, pos1 = bestellungen(1, 400, [k[0] for k in kunden], date(2026, 1, 1), date(2026, 6, 30), preise)

    schreibe("ladung_1", "kunden.csv", ["kunden_nr", "vorname", "nachname", "email", "strasse", "plz", "stadt", "registriert_am"], kunden)
    schreibe("ladung_1", "produkte.csv", ["produkt_nr", "produktname", "kategorie", "listenpreis_eur"], produkte)
    schreibe("ladung_1", "bestellungen.csv", ["bestell_nr", "kunden_nr", "bestelldatum", "status"], b1)
    schreibe("ladung_1", "bestellpositionen.csv", ["bestell_nr", "position", "produkt_nr", "menge", "einzelpreis_eur"], pos1)

    print("Ladung 2 (Delta) ...")
    # 8 Kunden ziehen um, 2 ändern ihre E-Mail
    geaendert = []
    for k in random.sample(kunden, 10)[:8]:
        neu = list(k)
        neu[5], neu[6] = random.choice([s for s in STAEDTE if s[1] != k[6]])
        neu[4] = f"{random.choice(STRASSEN)} {random.randint(1, 120)}"
        geaendert.append(neu)
    for k in random.sample(kunden, 2):
        neu = list(k)
        neu[3] = neu[3].replace("@example.com", "@mail.example.org")
        geaendert.append(neu)
    neue_kunden = [neuer_kunde(n) for n in range(121, 136)]

    # Preisänderungen + ein neues Produkt
    preis_neu = []
    for p in [produkte[0], produkte[6], produkte[12]]:
        neu = list(p)
        neu[3] = f"{float(p[3]) * 0.9:.2f}"  # 10 % Herbstrabatt
        preis_neu.append(neu)
        preise[p[0]] = float(neu[3])
    neues_produkt = ["P0026", "Sessel Ohrensessel Petrol", "Möbel", "499.00"]
    preise["P0026"] = 499.00

    alle_kunden = [k[0] for k in kunden + neue_kunden]
    b2, pos2 = bestellungen(401, 60, alle_kunden, date(2026, 7, 1), date(2026, 7, 7), preise)
    # Statusänderungen für ältere, noch nicht zugestellte Bestellungen
    status_upd = [[b[0], b[1], b[2], "zugestellt"] for b in b1 if b[3] != "zugestellt"][:25]
    # Ein absichtlicher Datenfehler für die Test-Aufgabe: negative Menge
    pos2[3][3] = -1

    schreibe("ladung_2", "kunden.csv", ["kunden_nr", "vorname", "nachname", "email", "strasse", "plz", "stadt", "registriert_am"], geaendert + neue_kunden)
    schreibe("ladung_2", "produkte.csv", ["produkt_nr", "produktname", "kategorie", "listenpreis_eur"], preis_neu + [neues_produkt])
    schreibe("ladung_2", "bestellungen.csv", ["bestell_nr", "kunden_nr", "bestelldatum", "status"], b2 + status_upd)
    schreibe("ladung_2", "bestellpositionen.csv", ["bestell_nr", "position", "produkt_nr", "menge", "einzelpreis_eur"], pos2)


if __name__ == "__main__":
    main()
