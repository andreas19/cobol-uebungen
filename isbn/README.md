# IsbnConv

Dieses Programm liest die Datei *isbn10.dat* im aktuellen Arbeitsverzeichnis,
prüft jede ISBN10 (eine pro Zeile) auf Gültigkeit, konvertiert die gültigen
Nummern in ISBN13 und schreibt sie in die Datei *isbn13.dat* (ebenfalls im
aktuellen Arbeitsverzeichnis).

## Kompilieren

`cobc -x -O isbnconv.cob`

## Beispiel

Eingabedatei *isbn10.dat*:

    3492230385
    3492230380
    047149691X
    047149690X
    3519100843

Anzeige:

    3-492-23038-5 -> 978-3-492-23038-4
    3-492-23038-0 -> not valid
    0-471-49691-X -> 978-0-471-49691-5
    0-471-49690-X -> not valid
    3-519-10084-3 -> 978-3-519-10084-3

Ausgabedatei *isbn13.dat*:

    9783492230384
    9780471496915
    9783519100843
