       identification division.
       program-id. Adressbuch.
       author. Andreas Suhre.

      *=================================================================

       environment division.
       input-output section.
       file-control.
         select optional DataFile assign to "addressbook.dat"
                organization is indexed
                access mode is dynamic
                record key is Name-D
                alternate record key is Location-D with duplicates
                file status is FileStatus.

      *=================================================================

       data division.
       file section.
       FD DataFile.
       01 DataRec.
          02 Name-D     pic X(50).
          02 Street-D   pic X(50).
          02 Location-D pic X(50).
          02 Date-D     pic X(14).
          02 Time-D     pic X(8).

      *-----------------------------------------------------------------

       working-storage section.
       01 FileStatus pic XX value spaces.
          88 FileStatusOK           value "00".
          88 FileStatusEOF          value "10".
          88 FileStatusKeyExists    value "22".
          88 FileStatusKeyNotExists value "23".

       01 MainMenuSeletion pic X value space.
          88 NewSelected    values "N" "n".
          88 EditSelected   values "B" "b".
          88 DeleteSelected values "E" "e".
          88 SearchSelected values "S" "s".
          88 PrintSelected  values "A" "a".
          88 ExitSelected   values "X" "x".

       01 AddressRec.
          02 Name-A     pic X(50).
          02 Street-A   pic X(50).
          02 Location-A pic X(50).
          02 Date-A     pic X(14).
          02 Time-A     pic X(8).

       01 PrevLocation pic X(50).

      *=================================================================

       procedure division.

       open i-o DataFile

       perform until ExitSelected
         display "Neu:        N"
         display "Bearbeiten: B"
         display "Entfernen : E"
         display "Suchen:     S"
         display "Ausgabe:    A"
         display "Beenden:    X"
         display "> " no advancing
         accept MainMenuSeletion
         evaluate true
           when NewSelected perform NewEntry
           when EditSelected perform EditEntry
           when DeleteSelected perform DeleteEntry
           when SearchSelected perform SearchEntries
           when PrintSelected perform PrintEntries
         end-evaluate
         display space
       end-perform

       close DataFile

       stop run.

      *-----------------------------------------------------------------

       NewEntry.
       display space
       display "Neuer Eintrag"
       display " Name:    " no advancing
       accept Name-A
       if Name-A equal to spaces
         display "Kein Name eingegeben"
       else
         display " Strasse: " no advancing
         accept Street-A
         display " Ort:     " no advancing
         accept Location-A
         accept Date-A from date YYYYMMDD
         accept Time-A from time
         write DataRec from AddressRec
           invalid key
             if FileStatusKeyExists
               display "Name existiert bereits"
             else
               display "Fehler: " FileStatus
             end-if
           not invalid key display "Adresse hinzugefuegt"
         end-write
       end-if
       .

      *-----------------------------------------------------------------

       EditEntry.
       display space
       display "Eintrag bearbeiten"
       display " Name: " no advancing
       accept Name-A
       move Name-A to Name-D
       read DataFile record
         key is Name-D
         invalid key
           if FileStatusKeyNotExists
             display "Name existiert nicht"
           else
             display "Fehler: " FileStatus
           end-if
       end-read
       if FileStatusOK
         display " Strasse: " Street-D
         display " > " no advancing
         accept Street-A
         if Street-A equal to spaces
           move Street-D to Street-A
         end-if
         display " Ort: " Location-D
         display " > " no advancing
         accept Location-A
         if Location-A equal to spaces
           move Location-D to Location-A
         end-if
         accept Date-A from date YYYYMMDD
         accept Time-A from time
         rewrite DataRec from AddressRec
           invalid key display "Fehler: " FileStatus
         end-rewrite
       end-if
       .

      *-----------------------------------------------------------------

       DeleteEntry.
       display space
       display "Eintrag entfernen"
       display " Name: " no advancing
       accept Name-A
       move Name-A to Name-D
       delete DataFile record
         invalid key
           if FileStatusKeyNotExists
             display "Name existiert nicht"
           else
             display "Fehler: " FileStatus
           end-if
         not invalid key display "Adresse entfernt"
       end-delete
       .

      *-----------------------------------------------------------------

       SearchEntries.
       display space
       display "Eintraege suchen"
       display "Ort: " no advancing
       accept Location-D
       read DataFile
         key is Location-D
         invalid key
           if FileStatusKeyNotExists
             display "Keine Eintraege gefunden"
           else
             display "Fehler: " FileStatus
           end-if
       end-read
       if FileStatusOK
         move Location-D to PrevLocation
         perform until FileStatusEOF
                       or Location-D not equal to PrevLocation
           display space Name-D
           read DataFile next record
         end-perform
       end-if
       .

      *-----------------------------------------------------------------

       PrintEntries.
       display space
       display "Ausgabe"
       move spaces to Name-D
       start DataFile key is greater than Name-D
         invalid key
           if FileStatusKeyNotExists
             display "Keine Eintraege vorhanden"
           else
             display "Fehler: " FileStatus
           end-if
       end-start
       if FileStatusOK
         read DataFile next record
         perform until FileStatusEOF
           display space
           display " Name:    " Name-D
           display " Strasse: " Street-D
           display " Ort:     " Location-D
           display " Datum:   " no advancing
           display Date-D(7:2) "." Date-D(5:2) "." Date-D(1:4)
           display " Zeit:    " no advancing
           display Time-D(1:2) ":" Time-D(3:2) ":" Time-D(5:2)
           read DataFile next record
         end-perform
       end-if
       .
