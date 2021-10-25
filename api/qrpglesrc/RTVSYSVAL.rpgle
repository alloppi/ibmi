     DQWCRDR00         DS
     D*                                             Qwc Rsval Data Rtnd
     D QWCNSVR                 1      4B 0
     D*                                             Number Sys Vals Rtnd
     D QWCOSVT                 5      8B 0
     D*
     D Data                           1    dim(2096)

     D QWCSV00         DS          2096
     D  QWCSV01                      10    OVERLAY(QWCSV00:00001)
     D  QWCTD01                       1    OVERLAY(QWCSV00:00011)
     D  QWCIS03                       1    OVERLAY(QWCSV00:00012)
     D  QWCLD01                       9B 0 OVERLAY(QWCSV00:00013)
     D  QWCDATA01                  2080    OVERLAY(QWCSV00:00017)

     DQUSEC            DS           116    inz
     D QUSBPRV                 1      4B 0 inz(116)
     D QUSBAVL                 5      8B 0 inz(0)
     D QUSEI                   9     15
     D QUSERVED               16     16
     D QUSED01                17    116

     D LockedCon       c                   'System value was locked'
     D MoveInd         S              5  0
     D NbrOfVals       S             10i 0 Inz(1)
     D OutData         s             50
     D ReceiveLen      S             10i 0 Inz(2104)
     D SysValue        s             10

     DBinaryCvt        DS
     D BinaryNbr               1      4B 0

     c     *entry        Plist
     c                   Parm                    SysValue

      * Call the api to get the information you want
     C                   Call      'QWCRSVAL'
     C                   Parm                    QwcRdr00
     C                   Parm                    ReceiveLen
     C                   Parm                    NbrofVals
     C                   Parm                    SysValue
     C                   Parm                    QusEc

      * Process the data from the API
     c                   Eval      MoveInd = Qwcosvt - 7
     c                   Movea     Data(MoveInd) QwcSV00

     c                   Select
      *  Value was locked, couldn't get it
     c                   When      QwcIs03 = 'L'
     c                   Movel     LockedCon     OutData
      *  Character data
     c                   When      QwcTd01 = 'C'
     c                   Movel     QwcData01     OutData
      *  Binary data
     c                   When      QwcTd01 = 'B'
     c                   Movel     QwcData01     BinaryCvt
     c                   Movel     BinaryNbr     OutData
     c                   Endsl

      * Display system value
     c     OutData       dsply
     c                   Eval      *inlr = *on
