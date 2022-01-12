       IDENTIFICATION DIVISION.
       PROGRAM-ID. IsbnConv.
       AUTHOR. Andreas Suhre.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
         SELECT Isbn10File ASSIGN TO "isbn10.dat"
                ORGANIZATION IS LINE SEQUENTIAL.
         SELECT Isbn13File ASSIGN TO "isbn13.dat"
                ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD Isbn10File.
       01 Isbn10 PIC X(10).
          88 EndOfIsbn10File VALUE HIGH-VALUES.

       FD Isbn13File.
       01 Isbn13 PIC X(13).

       WORKING-STORAGE SECTION.
       01 Isbn10Prn PIC X/XXX/XXXXX/X.

       01 Isbn13Prn PIC XXX/X/XXX/XXXXX/X.

       01 ValidationResult PIC 9.
          88 ValidIsbn VALUE ZERO.
          88 InvalidIsbn VALUE 1.

       PROCEDURE DIVISION.
       Begin.
         OPEN INPUT Isbn10File
         OPEN OUTPUT Isbn13File
         PERFORM ReadRecord
         PERFORM UNTIL EndOfIsbn10File
           MOVE Isbn10 TO Isbn10Prn
           INSPECT Isbn10Prn REPLACING ALL "/" BY "-"
           DISPLAY Isbn10Prn " -> " WITH NO ADVANCING

           CALL "CheckIsbn10" USING BY CONTENT Isbn10
                                    BY REFERENCE ValidationResult
           IF InvalidIsbn
             DISPLAY "not valid"
           ELSE
             CALL "MakeIsbn13" USING BY CONTENT Isbn10
                                     BY REFERENCE Isbn13
             MOVE Isbn13 TO Isbn13Prn
             INSPECT Isbn13Prn REPLACING ALL "/" BY "-"
             DISPLAY Isbn13Prn
             WRITE Isbn13
           END-IF
           PERFORM ReadRecord
         END-PERFORM
         CLOSE Isbn10File, Isbn13File
       STOP RUN.

       ReadRecord.
         READ Isbn10File
           AT END SET EndOfIsbn10File TO TRUE
         END-READ.

      *===========================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. CheckIsbn10 IS INITIAL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 Idx PIC 99.

       01 Result PIC 999 VALUE ZERO.

       01 CheckNum PIC 99.

       LINKAGE SECTION.
       01 Isbn.
          02 IsbnNum PIC 9(9).
          02 IsbnDigits REDEFINES IsbnNum PIC 9 OCCURS 9 TIMES.
          02 IsbnChk PIC X.

       01 ChkResult PIC 9.
          88 Ok VALUE ZERO.
          88 NotOk VALUE 1.

       PROCEDURE DIVISION USING Isbn, ChkResult.
       Begin.
         PERFORM VARYING Idx FROM 1 BY 1 UNTIL Idx > 9
           COMPUTE Result = Result + Idx * IsbnDigits(Idx)
         END-PERFORM
         MOVE FUNCTION MOD(Result 11) TO Result
         IF IsbnChk = "X"
           MOVE 10 TO CheckNum
         ELSE
           MOVE IsbnChk TO CheckNum
         END-IF
         IF Result = CheckNum
           SET Ok TO TRUE
         ELSE
           SET NotOk TO TRUE
         END-IF
         EXIT PROGRAM.

       END PROGRAM CheckIsbn10.

      *-------------------------------------------

       IDENTIFICATION DIVISION.
       PROGRAM-ID. MakeIsbn13 IS INITIAL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 Idx PIC 99.

       01 Result PIC 999 VALUE 38. *> 9 + 3 * 7 + 8 = 38

       01 CheckNum PIC 9.

       LINKAGE SECTION.
       01 Isbn10.
          02 Isbn10Num PIC 9(9).
          02 Isbn10Digits REDEFINES Isbn10Num PIC 9 OCCURS 9 TIMES.
          02 FILLER PIC X.

       01 Isbn13 PIC X(13).

       PROCEDURE DIVISION USING Isbn10, Isbn13.
       Begin.
         PERFORM VARYING Idx FROM 1 BY 1 UNTIL Idx > 9
           IF FUNCTION MOD(Idx 2) = 0
             COMPUTE Result = Result + Isbn10Digits(Idx)
           ELSE
             COMPUTE Result = Result + 3 * Isbn10Digits(Idx)
           END-IF
         END-PERFORM
         MOVE FUNCTION MOD((10 - FUNCTION MOD(Result 10)) 10)
              TO CheckNum
         STRING
           "978" DELIMITED BY SIZE
           Isbn10Num DELIMITED BY SIZE
           CheckNum DELIMITED BY SIZE
         INTO Isbn13
         END-STRING
         EXIT PROGRAM.

       END PROGRAM MakeIsbn13.

      *===========================================

       END PROGRAM IsbnConv.
