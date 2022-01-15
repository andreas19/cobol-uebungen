       identification division.
       program-id. Corona-CSV is initial.

      *=================================================================

       environment division.
       input-output section.
       file-control.
       select WorkFile assign to "work.tmp".
       select DataFile assign to DataFileName
              organization is line sequential.
       select CsvFile assign to "fallzahlen-laender.csv"
              organization is line sequential.
       select DateHeadersFile assign to DateHeadersFileName.

      *=================================================================

       data division.
       file section.
       sd WorkFile.
       copy datarec replacing DataRec by WorkRec
                              ==:tag:== by ==WF==.

       fd DataFile.
       01 FILLER pic X(19).

       fd CsvFile.
       01 CsvRec pic X(100).

       fd DateHeadersFile.
       01 DateHeadersRec pic X(76).

      *-----------------------------------------------------------------

       working-storage section.
       copy states.

       01 HeaderLine.
          02 FILLER pic X(5) value "Land,".
          02 DateHeaders pic X(76).

       01 PrevStateId pic 99.
       01 PrevDate pic 9(8).
       01 Cases pic 9(6).
       01 PrnCases pic Z(5)9.
       01 StrPos pic 999.

      *-----------------------------------------------------------------

       linkage section.
       01 DataFileName pic X(14).
       01 DateHeadersFileName pic X(14).

      *=================================================================

       procedure division using DataFileName, DateHeadersFileName.
       open input DateHeadersFile
       read DateHeadersFile
       close DateHeadersFile

       sort WorkFile on ascending StateId-WF, Date-WF
                     using DataFile
                     output procedure OutputProc

       exit program.

      *-----------------------------------------------------------------

       OutputProc.
       open output CsvFile
       move DateHeadersRec to DateHeaders
       write CsvRec from HeaderLine

       return WorkFile
         at end set EndOf-WF to true
       end-return

       perform until EndOf-WF
         move StateName(StateId-WF) to CsvRec
         move function length(function trim(StateName(StateId-WF)))
              to StrPos
         add 1 to StrPos
         move StateId-WF to PrevStateId

         perform until StateId-WF not equal to PrevStateId or EndOf-WF
            move zeros to Cases
            move Date-WF to PrevDate

            perform until Date-WF not equal to PrevDate
                       or StateId-WF not equal to PrevStateId
                       or EndOf-WF
              add Cases-WF to Cases

              return WorkFile
                at end set EndOf-WF to true
              end-return
            end-perform

            move Cases to PrnCases
            string "," delimited by size
                   function trim(PrnCases) delimited by size
                   into CsvRec
                   with pointer StrPos
         end-perform

         write CsvRec
       end-perform

       close CsvFile.

       end program Corona-CSV.
