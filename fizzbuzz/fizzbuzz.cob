       identification division.
       program-id. FizzBuzz.
       author. Andreas Suhre.

      *=================================================================

       data division.
       working-storage section.
       01 Idx pic 999.
       01 Lim pic 999 value 100.
       01 Prn pic ZZ9.

      *=================================================================

       procedure division.

       perform varying Idx from 1 by 1 until Idx > Lim
         evaluate true
           when function mod(Idx 15) = 0
                display "FizzBuzz" no advancing
           when function mod(Idx 3) = 0
                display "Fizz" no advancing
           when function mod(Idx 5) = 0
                display "Buzz" no advancing
           when other
                move Idx to Prn
                display function trim(Prn) no advancing
         end-evaluate
         if Idx < Lim
           display ", " no advancing
         end-if
       end-perform
       display space

       stop run.
