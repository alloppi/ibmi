     H DFTACTGRP(*NO)
      *
      * The prototype:
     D SndPgmMsg       pr                  extpgm('QMHSNDPM')
     D  MsgID                         7a   Const
     D  MsgFName                     20a   Const
     D  MsgDta                    32767a   Const Options(*Varsize)
     D  MsgDtaLength                  9b 0 Const
     D  MsgType                      10a   Const
     D  CallStackE                   10a   Const Options(*Varsize)
     D  CallStackC                    9b 0 Const
     D  MsgKey                        4a
     D  Error                     32767a         Options(*Varsize)
      *  Optional Parameter Group 1
     D  CallStackEL                   9b 0 Const Options(*Nopass)
     D  CallStackEQ                  20a   Const Options(*Nopass)
     D  DspPgmMsgWait                 9b 0 Const Options(*Nopass)
      *  Optional Parameter Group 2
     D  CallStackEDT                 10a   Const Options(*Nopass)
     D  MsgCCSID                      9b 0 Const Options(*Nopass)

      * The System Data Structure;
     Dpsds            sds
     D ZZProcName                    10a
     D ZZStatus                       5s 0
     D ZZPrevSts                      5s 0
     D ZZSrcLneNbr                    8a
     D ZZRoutine                      8a
     D ZZParms                        3s 0
     D ZZExcType                      3a
     D ZZExcNbr                       4a
     D ZZReserve1                     4a
     D ZZMsgWrkAra                   30a
     D ZZPgmLib                      10a
     D ZZExcDta                      80a
     D ZZ9001ID                       4a
     D ZZLastFile1                   10a
     D ZZUnused1                      6a
     D ZZJobDate                      8a
     D ZZCentury                      2s 0
     D ZZLastFile2                    8a
     D ZZFileSts                     35a
     D ZZJobName                     10a
     D ZZUserID                      10a
     D ZZJobNbr                       6s 0
     D ZZJobRunDte                    6s 0
     D ZZSysDate                      6s 0
     D ZZSysTime                      6s 0
     D ZZCompDate                     6
     D ZZCompTime                     6
     D ZZCompLvl                      4a
     D ZZSrcFileName                 10a
     D ZZSrcFileLib                  10a
     D ZZSrcFileMbr                  10a
     D ZZPgmOfProc                   10a
     D ZZModOfProc                   10a
     D ZZSid2128                      2s 0
     D ZZSid228235                    2s 0
     D ZZCurrentUser                 10a
     D ZZUnused2                     62a

      * In the program which wants to send a message, a simple CALLP works as
     C                   eval      MsgDta = 'This is a test message'
     C                   callp     SndMsgErr('CPF9898':MsgDta:%size(MsgDta))

     C                   eval      *inlr = *on
      *
      * Procedure for sending:
     P SndMsgErr       b                   export
      *
     D SndMsgErr       pi
     D  MsgID                         7a   Const
     D* PgmMsgQ                      10a   Const
     D  MsgDta                    32767a   Const Options(*Varsize : *Nopass)
     D  MsgDtaLen                     9b 0 Const Options(*Nopass)
     D*
     D  PgmMsgDta      s                   like(MsgDta)
     D  PgmDtaLen      s                   like(MsgDtaLen)
     D  MsgKeyA        s              4a
     D* PgmCllStck     s             10a   inz('*')
     D  PgmCllStck     s             10a   inz(*blanks)
     D  PgmCllStckC    s              9b 0 inz(0)
     D  CallStackEL    s              9b 0 inz(10)
     D  CallStackEQ    s             20a   inz('*NONE')
     D  DspPgmMsgWait  s              9b 0 inz(*zeros)
     D  CallStackEDT   s             10a   inz('*CHAR')
     D  MsgCCSID       s              9b 0 inz(0)
      *
     C                   reset                   errc0100
      * This contains the name of program invoking the Procedure
     C                   eval      PgmCllStck = ZZPgmofProc
      *  This is used when defining the PGMMSGQ for DSPF
     C                   if        %parms = 1
     C                   eval      PgmMsgDta = *blanks
     C                   eval      PgmDtaLen = *zeros
     C                   else
     C                   eval      PgmMsgDta = MsgDta
     C                   eval      PgmDtaLen = MsgDtaLen
     C                   endif
     C                   callp     SndPgmMsg(MsgId:
      * Named constant, can be replaced
     C                                       DwhMsg:
     C                                       PgmMsgDta:
     C                                       PgmDtaLen:
     C                                       msgtypinfo:
     C                                       PgmCllStck:
     C                                       PgmCllStckC:
     C                                       MsgKeyA:
     C                                       errc0100)
     C                   return
     P SndMsgErr       e

