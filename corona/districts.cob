       identification division.
       program-id. Corona-Districts.

      *=================================================================
       environment division.
       input-output section.
       file-control.
       select DistrictFile assign to "kreise.dat"
              organization is line sequential.

      *=================================================================

       data division.
       file section.
       fd DistrictFile.
       01 DistrictRec.
          88 EndOf-D value high-values.
          02 DistrictId-D pic 9(5).
          02 DistrictName-D pic X(40).

      *-----------------------------------------------------------------

       working-storage section.
       copy states.

       01 DistrictTable.
          02 District-T occurs 411 times indexed by TableIdx.
             03 DistrictId-T pic 9(5).
             03 DistrictName-T pic X(40).

       01 FILLER pic 9 value zero.
          88 TableInitialized value 1.

       01 Idx pic 999 value zero.

      *-----------------------------------------------------------------

       linkage section.
       01 DistrictId pic 9(5).
       01 DistrictName pic X(40).

      *=================================================================

       procedure division using DistrictId, DistrictName.
       if not TableInitialized
         open input DistrictFile

         read DistrictFile
           at end set EndOf-D to true
         end-read

         perform until EndOf-D
           add 1 to Idx
           move DistrictRec to District-T(Idx)

           read DistrictFile
             at end set EndOf-D to true
           end-read
         end-perform

         close DistrictFile

         set TableInitialized to true
       end-if

       move 1 to TableIdx
       search District-T
         at end move "unbekannt" to DistrictName
         when DistrictId-T(TableIdx) = DistrictId
              move DistrictName-T(TableIdx) to DistrictName
       end-search

       exit program.

       end program Corona-Districts.
