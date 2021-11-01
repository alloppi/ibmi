      *=======================================================================================*
      * Program name: CHKCHIR                                                                 *
      * Purpose.....: Check Invalid Chinese Character in String                               *
      *                                                                                       *
      * Remark......: R_Found = 'Y' : 1. If char. X'FE' is found and                          *
      *                                     DB char. in White List (CHKCHIFB) is NOT found or *
      *                               2. If DB char. in Black List (CHKCHIFA) is found        *
      *                               3. If X'FE' is found but NOT within '0E' '0F'           *
      *                                                                                       *
      * Date written: 2019/09/02                                                              *
      *                                                                                       *
      * Modification:                                                                         *
      * Date       Name       Pre  Ver  Mod#  Remarks                                         *
      * ---------- ---------- --- ----- ----- ------------------------------------------------*
      * 2019/09/02 Alan        AC             New                                             *
      *=======================================================================================*
     H Debug(*Yes)
     FCHKCHIFA  IF   E           K Disk                                         Char. Black List
     FCHKCHIFB  IF   E           K Disk                                         Char. White List

     D P_String        S            900A                                        Checking String
     D P_StrLen        S              3P 0                                      Length of String
     D R_Found         S              1A                                        Invalid Char. Found
      *
      * Working variable
     D w1Str           S                   Like(P_String) Inz
     D w1StrLen        S                   Like(P_StrLen) Inz
     D w1Found         S                   Like(R_Found)
     D w1FEFnd         S                   Like(R_Found)
      *
     D w1ChkStart      S                   Like(P_StrLen)                       Start Posit to check
     D w10E            S                   Like(P_StrLen)                       '0E' Position
     D w10F            S                   Like(P_StrLen)                       '0F' Position
     D w1FE            S                   Like(P_StrLen)                       'FE' Position
     D w1ByteIdx       S                   Like(P_StrLen)                       Byte Position
      *
     D w1Byte          S              1A   Inz                                  Single Byte
     D w1DB            S              2A   Inz                                  Double Byte
     D w1DBC           S              1P 0 Inz                                  Double Byte Count
      *
     D K_CODE          S                   Like(XRBLKC)
      *
     C     *Entry        PList
     C                   Parm                    P_String
     C                   Parm                    P_StrLen
     C                   Parm                    R_Found
      *
      * Initial working variable
     C                   Eval      w1Str    = %subst(P_String: 1: P_StrLen)
     C                   Eval      w1StrLen = P_StrLen
     C                   Eval      w1Found  = 'N'
      *
      * Checking if string is not blank
     C                   If        w1Str <> *Blank
      *
     C                   Eval      w1ChkStart = 1
      *
      * Find all chinese starting positions by looping the whole string
     C                   DoU       w1ChkStart = w1StrLen
     C                   Eval      w10E = %scan(x'0E': w1Str: w1ChkStart)
      *
      * Find all chinese ending position
     C                   If        w10E > 0
     C                   Eval      w10F = %scan(x'0F': w1Str: w10E)
     C                   If        w10F > w1StrLen
     C                   Eval      w10F = 0
     C                   EndIf
     C                   Else
     C                   Eval      w10F = 0
     C                   EndIf
      *
      * Check invalid character in chinese string
     C                   If        w10E > 0 and w10F > 0
     C                   Eval      w1ByteIdx  = w10E + 1
      *
     C                   DoW       w1ByteIdx  <  w10F     and
     C                             w1ByteIdx  <= w1StrLen
      *
     C                   Eval      w1Byte  = %subst(w1Str:w1ByteIdx:1)
      *
      * Find X'FE' for both 1st and 2nd Byte
     C                   If        w1Byte  = X'FE'
     C                   Eval      w1FEFnd = 'Y'
     C                   EndIf
      *
     C                   Eval      w1DBC = w1DBC + 1
      *
      * Formation of double byte from 1st byte
     C                   If        w1DBC = 1
     C                   Eval      %subst(w1DB:1:1) = w1Byte
     C                   EndIf
      *
      * Formation of double byte from 2nd byte
     C                   If        w1DBC = 2
     C                   Eval      %subst(w1DB:2:1) = w1Byte
      *
      * Check double byte in white list
      *   return 'Y' if double byte contains 'FE' and not found in white list
     C                   If        w1FEFnd = 'Y'
     C                   Eval      K_CODE = X'0E' + w1DB + X'0F'
     C     K_CODE        Chain     CHKCHIFBR                          96
     C                   If        *In96
     C                   Eval      w1Found  = 'Y'
     C                   Goto      $EndPgm
     C                   EndIf
     C                   EndIf
      *
      * Check Double Byte in Black List
      *   return 'Y' if double byte found in black list
     C                   Eval      K_CODE = X'0E' + w1DB + X'0F'
     C     K_CODE        Chain     CHKCHIFAR                          96
     C                   If        Not *In96
     C                   Eval      w1Found  = 'Y'
     C                   Goto      $EndPgm
     C                   EndIf
      * Reset
     C                   Eval      w1DBC   = 0
     C                   Eval      w1FEFnd = *Blank
      *
     C                   EndIf
      *
     C                   Eval      w1ByteIdx = w1ByteIdx + 1
     C                   EndDo
      *
      * Set checking position to found next chinese string
     C                   Eval      w1ChkStart = w10F + 1
     C                   If        w1ChkStart > w1StrLen
     C                   Eval      w1ChkStart = w1StrLen
     C                   EndIf
      *
     C                   EndIf                                                  EndIf w1DBC = 2
      *
      * If no more chinese string not found, set checking position to last value and leave the loop
     C                   If        w10E = 0
     C                   Eval      w1ChkStart = w1StrLen
     C                   EndIf
      *
     C                   EndDo
      *
      * Seach x'FE' in single byte (in case they are Unicode)
     C                   Eval      w1ChkStart = 1
     C                   DoW       w1ChkStart < w1StrLen
     C                   Eval      w1FE = %scan(x'FE': w1Str: w1ChkStart)
      *
      * If x'FE' found
     C                   If        w1FE > 0
     C                   Eval      w10E = %scan(x'0E': w1Str: w1FE)
     C                   Eval      w10F = %scan(x'0F': w1Str: w1FE)
      * x'0F' not found (not Big5), error
      *   FE ......
      * Found x'0F' before x'0E' (not within Big5) and x10E <> 0 (another Big5),  error
      *   FE ...  0E .... 0F => error,
      *   FE .... 0F...0E....0F => NOT error,  FE ...0F... => NOT error
     C                   If        w10F = 0
     C                             or (w10E < w10F and w10E <> 0)
     C                   Eval      w1Found = 'Y'
     C                   Goto      $EndPgm
     C                   Else
     C                   Eval      w1ChkStart = w10F + 1
     C                   EndIf
      *
      * x'FE' not found, just leave
     C                   Else
     C                   Leave
     C                   EndIf                                                  EndIf w1FE > 0
     C                   EndDo
      *
     C                   EndIf
      *
     C     $EndPgm       Tag
     C                   If        w1Found = 'Y'
     C     '0001'        Dump
     C                   EndIf
     C                   Eval      R_Found = w1Found
     C                   Eval      *InLr = *On
      *
