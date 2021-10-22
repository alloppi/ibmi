      *************************************************************
      *
      *  To compile:
      *
      *         CRTBNDRPG PGM(XXX/DQCLIENT) SRCFILE(XXX/QRPGLESRC)
      *                          - or -
      *                    Option 14 from PDM
      *
      *************************************************************
     D Que             s             10    Inz('CLNTSVRQ')
     D Lib             s             10    Inz('*LIBL')
     D Len             s              5  0 Inz(50)
     D Data            s             50
     D OrderNumber     s             10

     C     *Entry        PList
     C                   Parm                    OrderNumber

     C                   Eval      Data = 'OH' + OrderNumber
     C                   If        OrderNumber = *Blank
     C                   Eval      Data = '99'
     C                   EndIf

     C                   Call      'QSNDDTAQ'
     C                   Parm                    Que
     C                   Parm                    Lib
     C                   Parm                    Len
     C                   Parm                    Data

     C                   Eval      *InLr = *On
