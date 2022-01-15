       identification division.
       program-id. Corona-Main.
       author. Andreas Suhre.

      *=================================================================

       environment division.
       input-output section.
       file-control.
       select WorkFile assign to "work.tmp".
       select CsvFile assign to "fallzahlen.csv"
              organization is line sequential.
       select DataFile assign to DataFileName
              organization is line sequential.
       select DistrictFile assign to "kreise.dat"
              organization is line sequential.
       select DateHeadersFile assign to DateHeadersFileName.
       select AverageFile assign to AverageFileName
              organization is line sequential.

      *=================================================================

       data division.
       file section.
       sd WorkFile.
       copy datarec replacing DataRec by WorkRec
                              ==:tag:== by ==WF==.

       fd CsvFile.
       01 CsvRec pic X(100).
          88 EndOf-CSV value high-values.

       fd DataFile.
       01 DataRec pic X(19).

       fd DistrictFile.
       01 DistrictRec.
          02 DistrictId-D pic 9(5).
          02 DistrictName-D pic X(40).

       fd DateHeadersFile.
       01 DateHeadersRec pic X(76).

       fd AverageFile.
       copy datarec replacing DataRec by AverageRec
                              ==:tag:== by ==AF==.

      *-----------------------------------------------------------------

       working-storage section.
       01 DataFileName pic X(14) value "fallzahlen.dat".
       01 DateHeadersFileName pic X(14) value "datumzeile.txt".
       01 AverageFileName pic X(27) value "fallzahlen-durchschnitt.dat".

       01 Ignored pic X.
       01 Idx pic 99.
       01 Answer pic X.

       01 DateHeaders occurs 7 times.
          02 Day-H pic 99.
          02 FILLER pic X.
          02 Month-H pic 99.
          02 FILLER pic X.
          02 Year-H pic 9999.

       01 DistrictId pic 9(5).
       01 DistrictName pic X(40).
       01 Cases pic 9(6) occurs 7 times.
       01 PrevDistrictId pic 9(5).
       01 PrevDate pic 9(8).
       01 DistrictTotal pic 9(6).

      *=================================================================

       procedure division.
       display "Neue Fallzahlen verarbeiten? [jN] " with no advancing
       accept Answer
       if Answer = "J" or "j"
         sort WorkFile on ascending key DistrictId-WF, Date-WF
              input procedure is InputProc
              output procedure is OutputProc
       end-if

       display "Ausgabe: [R]eport -- [C]SV-Datei -- [B]eides > "
               with no advancing
       accept Answer
       evaluate Answer
         when = "R" or "r" call "Corona-Report" using
                                by content AverageFileName
         when = "C" or "c" call "Corona-CSV" using
                                by content DataFileName
                                by content DateHeadersFileName
         when = "B" or "b" call "Corona-Report" using
                                by content AverageFileName
                           call "Corona-CSV" using
                                by content DataFileName
                                by content DateHeadersFileName
         when other display "Unbekannte Auswahl"
       end-evaluate

       stop run.

      *-----------------------------------------------------------------

       InputProc.
       open input CsvFile
       open output DataFile
       open output DistrictFile

       perform ReadCsvFile
       if not EndOf-CSV
         open output DateHeadersFile
           write DateHeadersRec
                 from CsvRec(12:function length(DateHeadersRec))
         close DateHeadersFile
         unstring CsvRec delimited by ","
           into Ignored, Ignored, Ignored, DateHeaders(1),
                DateHeaders(2), DateHeaders(3), DateHeaders(4),
                DateHeaders(5), DateHeaders(6), DateHeaders(7)
       end-if

       perform ReadCsvFile
       perform until EndOf-CSV
         unstring CsvRec delimited by ","
           into Ignored, DistrictName, DistrictId, Cases(1), Cases(2),
                Cases(3), Cases(4), Cases(5), Cases(6), Cases(7)

         move DistrictId to DistrictId-D, DistrictId-WF
         move DistrictName to DistrictName-D
         write DistrictRec

         perform varying Idx from 1 by 1 until Idx > 7
           move Day-H(Idx) to Day-WF
           move Month-H(Idx) to Month-WF
           move Year-H(Idx) to Year-WF
           move Cases(Idx) to Cases-WF
           release WorkRec
         end-perform

         perform ReadCsvFile
       end-perform

       close CsvFile, DataFile, DistrictFile.

      *-----------------------------------------------------------------

       ReadCsvFile.
       read CsvFile
         at end set EndOf-CSV to true
       end-read.

      *-----------------------------------------------------------------

       OutputProc.
       open output DataFile
       open output AverageFile

       return WorkFile
         at end set EndOf-WF to true
       end-return

       perform until EndOf-WF
         move DistrictId-WF to PrevDistrictId
         move zeros to DistrictTotal

         perform until PrevDistrictId not = DistrictId-WF or EndOf-WF
           write DataRec from WorkRec
           add Cases-WF to DistrictTotal
           move Date-WF to PrevDate

           return WorkFile
             at end set EndOf-WF to true
           end-return
         end-perform

         move PrevDistrictId to DistrictId-AF
         move PrevDate to Date-AF
         divide DistrictTotal by 7 giving Cases-AF rounded
         write AverageRec
       end-perform

       close DataFile, AverageFile.
