       identification division.
       program-id. FizzBuzz.
       author. Andreas Suhre.

      *=================================================================

       data division.
       working-storage section.
       01 Lim constant as 100.
       01 Idx pic 999.
       01 Prn pic ZZ9.

      *=================================================================

       procedure division.

       perform varying Idx from 1 by 1 until Idx > Lim
         evaluate function mod(Idx 3) also function mod(Idx 5)
           when 0 also 0
                display "FizzBuzz" no advancing
           when 0 also any
                display "Fizz" no advancing
           when any also 0
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
