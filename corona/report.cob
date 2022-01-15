       identification division.
       program-id. Corona-Report is initial.

      *=================================================================

       environment division.
       input-output section.
       file-control.
       select DataFile assign to DataFileName
              organization is line sequential.
       select RptFile assign to "fallzahlen.rpt".

      *=================================================================

       data division.
       file section.
       fd DataFile.
       copy datarec replacing ==:tag:== by ==DF==.

       fd RptFile report is CasesReport.

      *-----------------------------------------------------------------

       working-storage section.
       copy states.

       01 DistrictName pic X(40).

       01 PrnDate.
          02 PrnDay pic 99.
          02 FILLER pic X value ".".
          02 PrnMonth pic 99.
          02 FILLER pic X value ".".
          02 PrnYear pic 9999.

      *-----------------------------------------------------------------

       linkage section.
       01 DataFileName pic X(27).

      *-----------------------------------------------------------------

       report section.
       rd CasesReport
          controls are FINAL, StateId-DF
          page limit is 66
          heading 1
          first detail 4
          last detail 54
          footing 56.

       01 type is report heading next group plus 1.
          02 line 1.
             03 column 8 pic X(66)
                value "Durchschnittliche Corona 7-Tage " &
                      "Fallzahlen der letzten sieben Tage".
          02 line 2.
             03 column 8 pic X(66)
                value "=================================" &
                      "=================================".
          02 line 3.
             03 column 8 pic X(6) value "Stand:".
             03 column 15 pic X(10) source PrnDate.

          02 line 4 value space.

       01 type is page heading.
          02 line is plus 1.
             03 column 9 pic X(4) value "Land".
             03 column 42 pic X(5) value "Kreis".
             03 column 67 pic X(10) value "Fallzahlen".
          02 line is plus 1.
             03 column 9 pic X(4) value "----".
             03 column 42 pic X(5) value "-----".
             03 column 67 pic X(10) value "----------".

       01 type is page footing.
          02 line is 60.
             03 column 70 pic X(7) value "Seite: ".
             03 column 77 pic Z9 source PAGE-COUNTER.

       01 DetailLine type is detail.
          02 line is plus 1.
             03 column 1 pic X(22) source StateName(StateId-DF)
                         group indicate.
             03 column 25 pic X(40) source DistrictName.
             03 column 69 pic Z(5)9 source Cases-DF.

       01 type is control footing StateId-DF next group plus 2.
          02 line is plus 2.
             03 column 50 pic X(11) value "Land gesamt".
             03 StateTotal column 69 pic Z(5)9 sum Cases-DF.

       01 type is control footing FINAL.
          02 line is plus 3.
             03 column 1 pic X(11) value "Deutschland".
             03 column 55 pic X(18) value "gesamt".
             03 column 69 pic Z(5)9 sum StateTotal.

      *=================================================================

       procedure division using DataFileName.
       open input DataFile
       open output RptFile
       read DataFile
         at end set EndOf-DF to true
       end-read

       move Day-DF to PrnDay
       move Month-DF to PrnMonth
       move Year-DF to PrnYear

       initiate CasesReport

       perform until EndOf-DF
         call "Corona-Districts"
              using by content DistrictId-DF
              by reference DistrictName

         generate DetailLine
         read DataFile
           at end set EndOf-DF to true
         end-read
       end-perform

       terminate CasesReport
       close DataFile, RptFile

       exit program.

       end program Corona-Report.
