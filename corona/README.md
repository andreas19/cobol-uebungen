# Corona

Dieses Programm erzeugt auf Wunsch aus der Datei *fallzahlen.csv* die Dateien *fallzahlen.dat*
und *fallzahlen-durchschnitt.dat* mit dem folgenden Format:

    Kreisschlüssel mit führender Null (5 Zeichen)
    Datum JJJJMMTT (8 Zeichen)
    7-Tage Fallzahl (6 Zeichen)
    
    Sortierung: Kreisschlüssel, Datum

Das Datum wird in der Datei *fallzahlen-durchschnitt.dat* auf das jüngste Datum des betrachteten
Zeitraums gesetzt.

Anschließend können eine CSV-Datei (*fallzahlen-laender.csv*) mit den Fallzahlen der Länder
und ein Report (*fallzahlen.rpt*) mit den durchschnittlichen 7-Tage Fallzahlen erstellt werden.

Das Programm behandelt keine Fehler (z. B. fehlende Dateien o. ä.).

Die Daten in der Datei *fallzahlen.csv* stammen aus dem Tabellenblatt *LK_7-Tage-Fallzahl (fixiert)*
(Stand: 10.01.2022) einer [Excel-Datei des RKI][rki]. Alle Daten (außer denen der letzten sieben Tage)
und die Zeilen ober- und unterhalb der Tabelle wurden gelöscht und die Tabelle als CSV-Datei exportiert
(Feldtrenner: Komma, Zeichensatz: ISO 8859-15). Die Spalte *LKNR* enthält den [Kreisschlüssel][wiki]
der auch das Land kodiert, so dass eine Zuordnung Kreis -> Land möglich ist.

## Kompilieren

`cobc -xO -o corona main.cob report.cob districts.cob csv.cob`


[rki]:https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Fallzahlen_Kum_Tab.html
[wiki]:https://de.wikipedia.org/wiki/Amtlicher_Gemeindeschl%C3%BCssel#Aufbau
