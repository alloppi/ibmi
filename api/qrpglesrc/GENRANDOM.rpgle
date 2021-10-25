     H DFTACTGRP(*NO) ACTGRP('QILE')

     D CEERAN0         PR
     D   seed                        10I 0
     D   ranno                        8F
     D   fc                          12A   options(*omit)

     D seed            s             10I 0 inz(0)
     D rand            s              8F
     D result          s              5P 0

      /free

          CEERAN0( seed : rand : *omit );
          result = %int(rand * 100) + 1;

          // "result" now contains a number between 1 and 100.
          dsply result;

          return;
      /end-free
