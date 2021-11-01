     h option(*nodebugio : *srcstmt)

      *  Program Information
     d ProgStatus     sds
     d  Parms            *PARMS
     d  ProgName         *PROC
     d  ErrMsgID              40     46
     d  ErrMsg                91    169
     d  JobName              244    253
     d  Userid               254    263
     d  JobNumber            264    269

      *   Call Stack
     d FindCaller      PR                  Extpgm('QWVRCSTK')
     d                             2000a
     d                               10I 0
     d                                8a   CONST
     d                               56a
     d                                8a   CONST
     d                               15a

      *  Call Stack Data
     d Var             DS          2000
     d  BytAvl                       10I 0
     d  BytRtn                       10I 0
     d  Entries                      10I 0
     d  Offset                       10I 0
     d  EntryCount                   10I 0

      *  Call Stack Job Information
     d JobIdInf        DS
     d  JIDQName                     26a   Inz('*')
     d  JIDIntID                     16a
     d  JIDRes3                       2a   Inz(*loval)
     d  JIDThreadInd                 10I 0 Inz(1)
     d  JIDThread                     8a   Inz(*loval)

      *  Call Stack Program Names
     d Entry           DS           256
     d  EntryLen                     10I 0
     d  ReqstLvl                     10I 0 Overlay(Entry:21)
     d  PgmNam                       10a   Overlay(Entry:25)
     d  PgmLib                       10a   Overlay(Entry:35)

     d VarLen          s             10I 0 Inz(%size(Var))
     d ApiErr          s             15a
     d Caller          s             50a
     d WhoCalled       s             10a
     d i               s             10I 0

      /free

        CallP     FindCaller(Var:VarLen:'CSTK0100':JobIdInf
                  :'JIDF0100':ApiErr);
        For i = 1 to EntryCount;
           Entry = %subst(Var:Offset + 1);
           Caller = %trim(PgmLib) + '/' + %trim(PgmNam);
           If (PgmNam <> ProgName and WhoCalled = *blanks);
              WhoCalled = PgmNam;
           Endif;
           Offset = Offset + EntryLen;
        Endfor;

        dsply WhoCalled;

        *inlr = *on;
        Return;

      /end-free
