      ////////////////////////////////////////////////////////////////
      //  Convert PF into Excel file                                //
      //  (c) Peter Colpaert - mailto:Peter.Colpaert@telenet.be     //
      ////////////////////////////////////////////////////////////////
     h dftactgrp(*no) actgrp(*caller)
     h debug(*yes) alwnull(*inputonly)
     h bnddir('QC2LE')
      //
      //
     d CpyPf2XlsV      pr                  ExtPgm('CPYPF2XLSV')
     d                               20a
     d                               10a
     d                             1024a
      //
     d CpyPf2XlsV      pi
     d  FileLib                      20a
     d  Member                       10a
     d  IfsFile                    1024a
      //
     d LibFile         s             20a
     d Count           S             10i 0 Inz(0)
     d C               S             10i 0 Inz(0)
     d name            S           1024    Inz('Sheet 1')
     d font_name       S           1024    Inz('Arial')
      //
     d  SpaceName      s             20a   Inz('CPYPF2XLS QTEMP')
      //
     d vApiErrDs       ds
     d  vbytpv                       10i 0 inz(%len(vApiErrDs))                 bytes provided
     d  vbytav                       10i 0 inz(0)                               bytes returned
     d  vmsgid                        7a                                        error msgid
     d  vresvd                        1a                                        reserved
     d  vrpldta                     128a                                        replacement data
      //
     D mMsgRtv         ds                  inz
     D mMsgRtvLen              9     12i 0                                      length msg retrieved
     D mMsgMessage            25    256                                         message retrieved
     D mMsgLen         s             10i 0 inz(%len(mMsgRtv))                   length of message
     d  Msgmic         s              7a
     d  Msgfil         s             20a
     d  MsgDta         s          32767a
     d  MsgLen         s             10i 0
     d  Msgtyp         s             10a
     d  Msgpgq         s             10a
     d  Msgstk         s             10i 0
     d  Msgkey         s              4a
     d  firstrun       s               n   inz(*off)
     d  UsrSpcPtr      s               *
     d  UsrSpcPtr2     s               *
      //
      //////////////////////////////////////////////////////////////////
      // Record structure for QUSRMBRD MBRD0200 format
      //////////////////////////////////////////////////////////////////
     DQUSM0200         DS
     D QUSBRTN03               1      4B 0
      //                                            Bytes Returned
     D QUSBAVL04               5      8B 0
      //                                            Bytes Available
     D QUSDFILN00              9     18
      //                                            Db File Name
     D QUSDFILL00             19     28
      //                                            Db File Lib
     D QUSMN03                29     38
      //                                             Member Name
     D QUSFILA01              39     48
      //                                             File Attr
     D QUSST01                49     58
      //                                             Src Type
     D QUSCD03                59     71
      //                                             Crt Date
     D QUSSCD                 72     84
      //                                             Src Change Date
     D QUSTD04                85    134
      //                                             Text Desc
     D QUSSFIL01             135    135
      //                                             Src File
     D QUSEFIL               136    136
      //                                             Ext File
     D QUSLFIL               137    137
      //                                             Log File
     D QUSOS                 138    138
      //                                             Odp Share
     D QUSERVED12            139    140
      //                                             Reserved
     D QUSNBRCR              141    144B 0
      //                                             Num Cur Rec
     D QUSNBRDR              145    148B 0
      //                                             Num Dlt Rec
     D QUSDSS                149    152B 0
      //                                             Dat Spc Size
     D QUSAPS                153    156B 0
      //                                             Acc Pth Size
     D QUSNBRDM              157    160B 0
      //                                             Num Dat Mbr
     D QUSCD04               161    173
      //                                             Change Date
     D QUSSD                 174    186
      //                                             Save Date
     D QUSRD                 187    199
      //                                             Rest Date
     D QUSED                 200    212
      //                                             Exp Date
     D QUSNDU                213    216B 0
      //                                             Nbr Days Used
     D QUSDLU                217    223
      //                                             Date Lst Used
     D QUSURD                224    230
      //                                             Use Reset Date
     D QUSRSV101             231    232
      //                                             Reserved1
     D QUSDSSM               233    236B 0
      //                                             Data Spc Sz Mlt
     D QUSAPSM               237    240B 0
      //                                             Acc Pth Sz Mlt
     D QUSMTC                241    244B 0
      //                                             Member Text Ccsid
     D QUSOAI                245    248B 0
      //                                             Offset Add Info
     D QUSLAI                249    252B 0
      //                                             Length Add Info
     D QUSNCRU               253    256U 0
      //                                             Num Cur Rec U
     D QUSNDRU               257    260U 0
      //                                             Num Dlt Rec U
     D QUSRSV203             261    266
      //                                             Reserved2
     d SndMsg          PR                  ExtPgm('QMHSNDPM')                   Send Program Message
     d                                7                                         Message ID
     d                               20                                         Message File
     d                            32767                                         Text
     d                               10i 0                                      Length
     d                               10                                         Type
     d                               10                                         Queue
     d                               10i 0                                      Stack Entry
     d                                4                                         Key
     db                                    like(vApiErrDS)
      //
     d RmvMsg          PR                  ExtPgm('QMHRMVPM')                   Remove Pgm Message
     d                                7                                         Message ID
     d                               20                                         Message File
     d                            32767                                         Text
     d                               10i 0                                      Length
     d                               10                                         Type
     d                               10                                         Queue
     d                               10i 0                                      Stack Entry
     d                                4                                         Key
     db                                    like(vApiErrDS)
      //
     d RtvMsg          PR                  ExtPgm('QMHRTVM')                    Retrieve Message
     d                              256                                         Message Retrieved
     d                               10i 0                                      Length of Message
     d                                8    const                                Requested format
     d                                7                                         Message ID
     d                               20    const                                Message File
     d                              128                                         Replacement Data
     d                               10i 0 const                                Length of Repl. Data
     d                               10    const                                Substitution Char
     d                               10    const                                Format Control Char
     db                                    like(vApiErrDS)
     d CrtUsrSpc       PR                  ExtPgm('QUSCRTUS')                   Create User Space
     d                               20                                         Qualified Name
     d                               10                                         Extended Attribute
     d                               10i 0                                      Initial Size
     d                                1                                         Initial Value
     d                               10                                         Public Authority
     d                               50                                         Description
     d                               10                                         Replace
     db                                    like(vApiErrDS)
      //
     d DltUsrSpc       PR                  ExtPgm('QUSDLTUS')                   Delete User Space
     d                               20                                         Qualified Name
     db                                    like(vApiErrDS)
      //
     d RtvSpcPtr       PR                  ExtPgm('QUSPTRUS')                   Retrieve Pointer
     d                               20                                         Qualified Name
     d                                 *                                        Pointer
     db                                    like(vApiErrDS)
      //
     d LstFld          PR                  ExtPgm('QUSLFLD')                    List Fields
     d                               20                                         User Space Name
     d                                8                                         Format Name
     d                               20                                         File Nam
     d                               10                                         Record Format Name
     d                                1                                         Override Processing
     db                                    like(vApiErrDS)
      //*************************************************************************
      // Procedure calls                                                        *
      //*************************************************************************
     d SndPgmMsg       PR
     d  MsgDta                    32767a   Value
      //
     d RmvPgmMsg       PR
      //
     d CrtSpc          PR
     d  Name                         20a   Value
      //
     d DltSpc          PR
     d  SpaceName                    20a   Value
      //
     d RtvPtr          PR              *
     d  SpaceName                    20a   Value
      //
     d ListFields      PR           256
     d  File                         10a   Value
     d  Library                      10a   Value
     d  RecFormat                    10a   Value
      //
     d RtvMbrD         pr                  ExtPgm('QUSRMBRD')
     d                            32767    Options(*varsize)                    Receiver Variable
     d                               10i 0 Const                                Rec. Var Length
     d                                8    Const                                Format Name
     d                               20    Const                                Qualified File Name
     d                               10    Const                                Member Name
     d                                1    Const                                Override processing
     db                                    like(vApiErrDS)
      /free
        LibFile = %trim(%subst(filelib:11:10)) + '/' +
                  %trim(%subst(filelib:1:10));
        CrtSpc(SpaceName);
        UsrSpcPtr = RtvPtr(SpaceName);
        If        Listfields(%subst(filelib:1:10):
                             %subst(filelib:11:10):
                             '*FIRST') = *blanks;
        // Check number of records <= 65537
        Reset Qusm0200;
        Reset vApiErrDs;
        RtvMbrD(QUSM0200:
                %len(QUSM0200):
                'MBRD0200':
                FileLib:
                '*FIRST':
                '0':
                vApiErrDs);
           If QUSNBRCR > 65536;
              DltSpc(SpaceName);
              Msgfil = 'QCPFMSG   *LIBL';
              MsgDta = '0000' + 'CPF0001: +
                  More than 65536 records not allowed in Excel';
              msgmic = 'CPD0006';
            //
              MsgLen = %len(%trim(MsgDta));
              Msgtyp = '*DIAG';
              Msgpgq = '*CTLBDY';
              Msgstk = 1;
              Msgkey = '    ';
              //
              reset vApiErrDs;
              SndMsg(
                  msgmic:
                  msgfil:
                  Msgdta:
                  MsgLen:
                  Msgtyp:
                  Msgpgq:
                  Msgstk:
                  Msgkey:
                  vApiErrDs);
              //
              msgmic = 'CPF0002';
              Msgfil = 'QCPFMSG   *LIBL';
              MsgDta = 'CPYPF2XLS';
              //
              MsgLen = %len(MsgDta);
              Msgtyp = '*ESCAPE';
              Msgstk = 1;
              Msgkey = '    ';
              //
              reset vApiErrDs;
              SndMsg(
                  msgmic:
                  msgfil:
                  Msgdta:
                  MsgLen:
                  Msgtyp:
                  Msgpgq:
                  Msgstk:
                  Msgkey:
                  vApiErrDs);
           Endif;
        DltSpc(SpaceName);
        *inlr = *on;
        Return;
        Else;
        DltSpc(SpaceName);
        RtvMsg(
            mMsgRtv :
            mMsgLen :
            'RTVM0100':
            vmsgid:
            'QCPFMSG   *LIBL':
            vrpldta:
            %len(vrpldta):
            '*YES      ':
            '*NO       ':
            vApiErrDs);
        if mMsgRtvLen > %len(mMsgMessage);
          mMsgRtvLen = %len(mMsgMessage);
        endif;
        //
        Msgfil = 'QCPFMSG   *LIBL';
        MsgDta = '0000' + vmsgid +': ' +
            %subst(mMsgMessage:1:mMsgRtvLen);
        msgmic = 'CPD0006';
        //
        MsgLen = %len(%trim(MsgDta));
        Msgtyp = '*DIAG';
        Msgpgq = '*CTLBDY';
        Msgstk = 1;
        Msgkey = '    ';
        //
        reset vApiErrDs;
        SndMsg(
            msgmic:
            msgfil:
            Msgdta:
            MsgLen:
            Msgtyp:
            Msgpgq:
            Msgstk:
            Msgkey:
            vApiErrDs);
        //
        msgmic = 'CPF0002';
        Msgfil = 'QCPFMSG   *LIBL';
        MsgDta = 'CPYPF2XLS';
        //
        MsgLen = %len(MsgDta);
        Msgtyp = '*ESCAPE';
        Msgstk = 1;
        Msgkey = '    ';
        //
        reset vApiErrDs;
        SndMsg(
            msgmic:
            msgfil:
            Msgdta:
            MsgLen:
            Msgtyp:
            Msgpgq:
            Msgstk:
            Msgkey:
            vApiErrDs);
       Endif;

      /end-free

      //*************************************************************************
      // Procedures                                                             *
      //*************************************************************************
      //
      // Send Program Message
      //
     p SndPgmMsg       B
     d SndPgmMsg       PI
     d MessageData                32767    Value
      //
      /FREE
       Msgmic = *blanks;
       Msgfil = *blanks;
       Msglen = 76;
       Msgtyp = '*INFO';
       Msgpgq = '*';
       Msgstk = 1;
       Msgkey = *blanks;
       SndMsg(
           Msgmic:
           Msgfil:
           MessageData:
           MsgLen:
           Msgtyp:
           Msgpgq:
           Msgstk:
           Msgkey:
           vApiErrDs);
       //
      /END-FREE
     p SndPgmMsg       E
      //
      // Remove Program Messages
      //
     p RmvPgmMsg       B
     d RmvPgmMsg       PI
      //
      /FREE
       Msgmic = *blanks;
       Msgfil = *blanks;
       Msgdta = *blanks;
       Msglen  = %len(%trim(msgDta));
       Msgtyp = '*INFO';
       Msgpgq = '*';
       Msgstk  = 1;
       Msgkey = *blanks;
       RmvMsg(
           Msgmic:
           Msgfil:
           MsgDta:
           MsgLen:
           Msgtyp:
           Msgpgq:
           Msgstk:
           Msgkey:
           vApiErrDs);
       //
      /END-FREE
     p RmvPgmMsg       E
      //
      // Create User Space
      //
     p CrtSpc          B
     d CrtSpc          PI
     d  SpaceName                    20    Value
      //
     d  ExtAttr        s             10    Inz(*blanks)
     d  InitSize       s             10i 0 Inz(32000)
     d  InitVal        s              1    Inz(X'00')
     d  Auth           s             10    Inz('*ALL')
     d  Text           s             50    Inz(*blanks)
     d  Replace        s             10    Inz('*YES')
      //
      /FREE
       CrtUsrSpc(
           SpaceName:
           ExtAttr:
           InitSize:
           InitVal:
           Auth:
           Text:
           Replace:
           vApiErrDs);
       //
      /END-FREE
     p CrtSpc          E
      //
      // Delete User Space
      //
     p DltSpc          B
     d DltSpc          PI
     d  SpaceName                    20    Value
      //
      /FREE
       DltUsrSpc(
           SpaceName:
           vApiErrDs);
       //
      /END-FREE
     p DltSpc          E
      //
      // Retrieve Pointer to User Space
      //
     p RtvPtr          B
     d RtvPtr          PI              *
     d  SpaceName                    20    Value
      //
     d  SpacePtr       s               *
      //
      /FREE
       RtvSpcPtr(
           SpaceName:
           SpacePtr:
           vApiErrDs);
       //
       Return SpacePtr;
       //
      /END-FREE
     p RtvPtr          E
      //
      // List Fields to User Space
      //
     p ListFields      B
     d ListFields      PI           256
     d  File                         10    Value
     d  Library                      10    Value
     d  RecFormat                    10    Value
      //
     d  QualName       s             20
     d  ListFormat     s             10    Inz('FLDL0100')
     d  Override       s              1    Inz('0')
      //
      /FREE
       QualName = File + Library;
       //
       LstFld(
           SpaceName:
           ListFormat:
           QualName:
           RecFormat:
           Override:
           vApiErrDs);
       //
       If vBytav = *zeros;
         Return *blanks;
       Else;
         RtvMsg(
             mMsgRtv :
             mMsgLen :
             'RTVM0100':
             vmsgid:
             'QCPFMSG   *LIBL':
             vrpldta:
             %len(vrpldta):
             '*YES      ':
             '*NO       ':
             vApiErrDs);
         if mMsgRtvLen > %len(mMsgMessage);
           mMsgRtvLen = %len(mMsgMessage);
         endif;
         Return vmsgid +': ' +
             %subst(mMsgMessage:1:mMsgRtvLen);
       Endif;
       //
      /END-FREE
     p ListFields      E
