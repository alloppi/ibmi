      ************************************************************
      *
      *  To compile:
      *
      *         CRTBNDRPG PGM(XXX/DQSERVER) SRCFILE(XXX/QRPGLESRC)
      *                          - or -
      *                    Option 14 from PDM
      *
      ************************************************************
     D Que             s             10    Inz('CLNTSVRQ')
     D Lib             s             10    Inz('*LIBL')
     D Len             s              5  0 Inz(50)
     D*Wait            s              5  0 Inz(-1)
     D Wait            s              5  0 Inz(10)
     D Data            ds            50
     D   MessageType                  2
     D   Real_Data                   48

     D SendEscMsg      pr                  extpgm('QMHSNDPM')
     D   MsgID                        7    const
     D   MsgFile                     20    const
     D   MsgDta                      80    const
     D   MsgDtaLen                   10i 0 const
     D   MsgType                     10    const
     D   MsgQ                        10    const
     D   MsgQNbr                     10i 0 const
     D   MsgKey                       4
     D   ErrorDS                     16

     D ErrorDS         ds            16
     D   BytesProv                   10i 0 inz(16)
     D   BytesAvail                  10i 0
     D   ExceptionID                  7

     D MsgDta          s             80
     D MsgKey          s              4

     C                   DoU       *InLr

     C                   Call      'QRCVDTAQ'
     C                   Parm                    Que
     C                   Parm                    Lib
     C                   Parm                    Len
     C                   Parm                    Data
     C                   Parm                    Wait

     C                   Select

     C                   When      MessageType = 'OH'
     C*                  Call      'SOMEPGM'
     C*                  Parm                    Real_Data
     C                   callp     SendEscMsg ('CPF9898':
     C                               'QCPFMSG   QSYS':
     C                               Real_Data:
     C                               %len(Real_Data):
     C                               '*ESCAPE':
     C                               '*':
     C                               2:
     C                               MsgKey:
     C                               ErrorDS)

     C                   When      MessageType = '99'
     C                   Leave

      * Other WHEN logic to accept data from other clients could go here.

     C                   EndSl

     C                   EndDo

     C                   Eval      *InLr = *On

