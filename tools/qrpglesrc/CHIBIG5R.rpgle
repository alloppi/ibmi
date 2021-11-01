      *
      * Program name: CHIBIG5R
      * cvthc-Converts from a character value to the hexadecimal text of the character values
      *       (e.g., from 'A' to X'C1')
      *
      * cvtch-Converts from hexadecimal text to the character form of the hex values.
      *       (e.g., from X'C1' to 'A')
      *
     HDEBUG(*YES) BNDDIR('QC2LE') DFTACTGRP(*NO)
     FCHIBIG5FA UF   E             Disk
      *
     D cvthex1To2      PR                  extproc('cvthc')
     D  longReceiver                   *   value
     D  shortSource                    *   value
     D  receiverBytes                10i 0 value

     D*cvthex2To1      PR                  extproc('cvtch')
     D* shortReceiver                  *   value
     D* longSource                     *   value
     D* sourceBytes                  10i 0 value
      *
     D*charval         S              4a   inz('1F3D')
     D*hexval          S              5a   inz(X'C1C2C3C4C5')
     D*charResult      S             10a
     D*intResult       S              5i 0
      *
     D                 DS
     D w1Char4                        4A
     D w1Char2                 2      2A
      * convert from a character value '1F3D' to an integer
      * value x'1F3D'
     C*                  callp     cvthex2To1 (%addr(intResult)
     C*                                      : %addr(charval)
     C*                                      : %size(intResult) * 2)
      * convert from a hex value X'C1C2C3C4C5' to an character
      * value 'C1C2C3C4C5' (ABCDE)
     C*                  callp     cvthex1To2 (%addr(charResult)
     C*                                      : %addr(hexval)
     C*                                      : %size(charResult))
07170 *
07170C                   Read      CHIBIG5FAR                             97
     C                   Dow       *In97 = *Off
     C                   Eval      w1Char4 = BIG5CHAR
     C                   callp     cvthex1To2 (%addr(BIG5HEXA)
     C                                       : %addr(w1Char2)
     C                                       : %size(BIG5HEXA))
     C                   Update    CHIBIG5FAR                           99
     C                   If        *In99 = *Off
07170C                   Read      CHIBIG5FAR                             97
     C                   Else
     C                   Dump
     C                   Eval      *In97 = *On
     C                   EndIf
     C                   EndDo
      *
     C                   Return
