     H DFTACTGRP(*NO)

     FCUSTFILE  IF   E           K DISK

     D SubProc         PR
     D   NoCust                            Like(CustNo)

     D Date2ISO        PR             8S 0
     D   DateFld                       D   const

     D Today           S               D
     D InvDate         S              8S 0

      /free

           Today = %date();
           InvDate = Date2ISO(ToDay);
           Dsply Invdate;

      /end-free
     C                   Read      CUSTFILE
     C                   DoW       Not %Eof(CUSTFILE)
     C                   CallP     SubProc(CustNo)
     C                   Read      CUSTFILE
     C                   EndDo

     C                   Eval      *InLr = *On

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SubProc         B
     D SubProc         PI
     D   NoCust                            Like(CustNo)

     D Count           S                   Like(CustNo)

     C                   Eval      Count = Count + 1

     P                 E
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Convert date field to numeric field in YYYYMMDD format
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Date2ISO        B                   Export
     D Date2ISO        PI             8S 0
     D   DateFld                       D   const

     D Output          S              8S 0

      /free

           Output = %int(%char(DateFld : *ISO0));
           return Output;

      /end-free

     P                 E
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
