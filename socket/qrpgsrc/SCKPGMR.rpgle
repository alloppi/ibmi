      *====================================================================*
      * Program name: SCKPGMR                                              *
      * Purpose.....: TU Enquiry Program (Socket Program)                  *
      * Spec        :                                                      *
      *                                                                    *
      * Date written: 2007/02/07                                           *
      *                                                                    *
      * Create this Socket Program with the following Commands:            *
      * - CrtRpgMod command                                                *
      * - CrtPgm, specifying BndSrvPgm(SCKSVRR) ACTGRP(*CALLER)            *
      *                                                                    *
      * Note:                                                              *
      * The Service Program (SCKSVRR) must be created prior to creating    *
      * this program.                                                      *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2007/02/07 Alan                       New                          *
      *====================================================================*
     HDEBUG(*YES)
     H*Option( *SrcStmt ) DftActGrp( *No ) BndDir( 'QC2LE' )
     H Option( *SrcStmt ) BndDir( 'QC2LE' )
      *
     FSCKPGMF    UF A E           K Disk    COMMIT
      *
      * Prototype Definitions
     D opn_tcp         pr            10i 0
     D bnd_tcp         pr            10i 0
     d                               10i 0 Const
     d                               10i 0 Const
     d                               10i 0 Const
     D con_tcp         pr            10i 0
     d                               10i 0 Const
     d                               30
     d                                2  0 Const
     d                                5  0 Const
     D snd_tcp         pr            10i 0
     d                               10i 0 Const
     d                            32650
     D rcv_tcp         pr            10i 0
     d                               10i 0 Const
     d                            32650
     D cls_tcp         pr            10i 0
     d                               10i 0 Const
      *
     d Translate       pr                  ExtPgm('QDCXLATE')
     d   Length                       5P 0 Const
     d   Data                     32650A   Options(*Varsize)
     d   Table                       10A   Const
03341 *
03341d get_errno       pr              *   ExtProc('__errno')
03341d errno           s             10I 0 based(p_errno)
03341 *
03341d strerror        pr              *   ExtProc('strerror')
03341d    errunm                     10I 0 value
03341d errtxt          s            200A
      *
      * Parameters - Input
     D P_EnqD          S               D
     D P_EnqSeq        S              5P 0
     D P_EnqData       S           2000A
     D P_System        S              8A
     D RtnCde          S              2P 0
      * Parameters - PS0126R
     D P_OpnClo        S              1A
     D P_SlotOpn       S              2P 0
     D P_SlotRtn       S              2P 0
     D P_SLRtnCde      S              2P 0
      * Other variables
     D ScktNum         S             10I 0
     D RetCode         S             10I 0
     D Str             S          32650
     D Risc            S             30
     D PortNbr         S              5  0
     D WkFldLen        S              5P 0
     D WkSpace         S              5P 0
     D $a              S              5P 0                                      Cut Position (W)
     D $b              S              5P 0                                      Cut Position (W)
     D $X              S              5P 0                                      Cut Position (W)
     D $Y              S              5P 0                                      Start Position (W)
     D WkChk1          S             10A
     D WkChk2          S             10A
     D WkRmdCnt        S              5P 0
     D WkTermin        S               N
02822D WkPWD           S               N
07535D*W_EnqData       S           2000A
07535D W_EnqData       S            600A
     D W_Str           S          32650
     D Rpt_Str         S              5P 0
     D W_Report        S               N
     D W_RcvLen        S             10I 0
     **-- IFS    variables: -------------------------------------------**
     D FILE_o          S               *
     D String          S            512A
     D rc              S             10i 0
     D Idx             S              5u 0
     D FilNam          S             21A   inz('/TUEF/TUyyyymmdd12345')
     D Char_8A         S              8A
     **-- IFS    constants: -------------------------------------------**
     D LF              c                   x'25'
     **-- IFS stream file functions: ----------------------------------**
     Dopen             PR              *   ExtProc( '_C_IFS_fopen' )
     D                                 *   Value Options( *String )
     D                                 *   Value Options( *String )
     **
     Dfgets            Pr              *   ExtProc( '_C_IFS_fgets' )
     D                                 *   Value
     D                               10i 0 Value
     D                                 *   Value
     **
     Dfputs            Pr            10i 0 ExtProc( '_C_IFS_fputs' )
     D                                 *   Value Options( *String )
     D                                 *   Value
     **
     Dclose            Pr            10i 0 ExtProc( '_C_IFS_fclose' )
     D                                 *   Value
      *
02570D W1Cmd           S            200A
02570D W1CmdLen        S             15P 5
02570D W1ReadCnt       S              1P 0
      *
     C     *Entry        Plist
     C                   Parm                    P_EnqD
     C                   Parm                    P_EnqSeq
     C                   Parm                    P_EnqData
     C                   Parm                    P_System
     C                   Parm                    RtnCde
      *
      * Main Logic
     C                   Exsr      @SckFnt
     C   99              Goto      $EndPgm
      *
     C     $EndPgm       Tag
      * Close IFS File
      * i.e. actually data to file
     C                   Eval      rc = close( FILE_o )
     C                   If        Not *In99
     C                   Commit
     C                   Else
     C                   RolBk
     C                   EndIf
      *
     C                   Eval      *INLR = *On
     C                   Return
      *===================================================================*
      * @SckFnt - Scoket Functions                                        *
      *===================================================================*
     C     @SckFnt       BegSr
      * Open the socket
     C                   Eval      ScktNum = Opn_Tcp
     C                   If        ScktNum = -1
     C                   Eval      *In99 = *On
     C                   Eval      RtnCde = 1
     C     '0003'        Dump
     C                   GoTo      $XSckFnt
     C                   EndIf
      *
      * Connect
      * Con_Tcp(socket descriptor, the server's IP address, the length of the IP address, and the
      *         port on which the server program is listening)
     C                   Eval      RetCode = Con_Tcp( ScktNum: RISC: 14:
     C                                                PortNbr )
     C                   If        RetCode = -1
03341 *
03341C                   Eval      p_errno = get_errno()
03341C                   Eval      errtxt = %str(strerror(errno))
03341 *
     C                   Eval      *In99 = *On
     C                   Eval      RtnCde = 1
     C     '0004'        Dump
     C                   GoTo      $XSckFnt
     C                   EndIf
      * Send Request to Host
      * Convert Text to ASCII
     C                   Eval      W_EnqData = P_EnqData
07535C                   callp     Translate(600: W_EnqData: 'QTCPASC')
     C                   Eval      Str = W_EnqData
     C                   Eval      RetCode = Snd_Tcp( ScktNum: Str )
     C                   If        RetCode = -1
     C                   Eval      *In99 = *On
     C                   Eval      RtnCde = 1
     C     '0005'        Dump
     C                   GoTo      $XSckFnt
     C                   EndIf
      * Receive
02570C                   Eval      w1ReadCnt = 1
     C                   Dou       WkTermin = *On
02477C     $Receive      Tag
     C                   Eval      Str = *Blank
     C                   Eval      RetCode = Rcv_Tcp( ScktNum: Str )
02820C                   If        WkPWD = *On
02820C     '9998'        Dump
02820C                   EndIf
02477C                   If        RetCode = 0
02477C     '0007'        Dump
      *
02570C                   Eval      W1Cmd   = 'DLYJOB DLY(1)'
02570C                   Eval      W1CmdLen = %Len(%Trim(W1Cmd))
02570C                   Call      'QCMDEXC'                            99
02570C                   Parm                    W1Cmd
02570C                   Parm                    W1CmdLen
02570C                   If        *In99
02570C     '0008'        Dump
02570C                   Eval      RtnCde = 2
02570C                   GoTo      $XSckFnt
02570C                   EndIf
02570C                   Eval      w1ReadCnt = w1ReadCnt + 1
      * Loop 5 time only
02570C                   If        w1ReadCnt = 6
02570C                   Eval      RtnCde = 2
02570C                   GoTo      $XSckFnt
02570C                   EndIf
      *
02477C                   GoTo      $Receive
02477C                   EndIf
      *
02477C*                  If        RetCode <= 0
02477C                   If        RetCode < 0
03341 *
03341C                   Eval      p_errno = get_errno()
03341C                   Eval      errtxt = %str(strerror(errno))
03341 *
     C     '0006'        Dump
     C                   Eval      *In99 = *On
     C                   Eval      RtnCde = 2
     C                   GoTo      $XSckFnt
     C                   EndIf
      *
     C                   Eval      W_Str = Str
     C                   Eval      W_RcvLen = RetCode
      * Convert Text to EBCDIC
     C                   callp     Translate(W_RcvLen: Str: 'QTCPEBC')
      *
     C     X'13'         SCAN      Str                                    80
     C   80              Eval      WkTermin = *On
      *
     C     'ES02**'      SCAN      Str           $b                       88
     C                   If        *In88
      * 'ES02**' found, move pointing b$ just right after 'ES02**', and W_RcvLen is the length such
      * as '............     ES02**'
      *     <--     W_RcvLen    -->
      *
     C                   Eval      W_RcvLen = $b + 5
     C                   Eval      $b = $b + 6
     C                   Else
      * 'ES02**' not yet found
     C                   Eval      $b = 1
     C                   If        W_Report = *Off
     C                   Eval      $a = 6
     C                   DoU       $b > 5 or $b > W_RcvLen
     C                   Eval      %Subst(WkChk1:$a:1) =
     C                             %Subst(Str:$b:1)
     C                   Eval      $a = $a + 1
     C                   Eval      $b = $b + 1
     C     'ES02**'      SCAN      WkChk1                                 88
     C                   If        *In88
     C                   Eval      W_RcvLen = $b - 1
     C                   Leave
     C                   EndIf
     C                   EndDo
      *
     C                   If        Not *In88
     C                   Eval      WkChk2 = WkChk1
     C                   Eval      WkChk1 = *Blank
     C                   If        $b > 5
     C                   Eval      WkChk1 = %Subst(Str:W_RcvLen-4:5)
     C                   Else
     C                   Eval      %Subst(WkChk1:1:5)    =
     C                             %Subst(WkChk2:$a-5:5)
     C                   EndIf
     C                   EndIf
     C                   EndIf
     C                   EndIf
      *
     C                   If        W_Report = *Off
      * Received Length < Space left
     C                   Select
     C                   When      W_RcvLen < WkSpace
     C                   Eval      %Subst(TUERRD:$Y:W_RcvLen) =
     C                             %Subst(Str:$X:W_RcvLen)
     C                   If        WkTermin or *In88
     C                   Eval      TUERSN = TUERSN + 1
     C                   Exsr      @UpdTUEF
     C   99              Leave
     C                   EndIf
     C                   If        WkTermin = *Off
     C                   Eval      $Y = $Y + W_RcvLen
     C                   Eval      $X = 1
     C                   Eval      WkSpace = WkSpace - W_RcvLen
     C                   EndIf
      *
      * Received Length = Space left
     C                   When      W_RcvLen = WkSpace
     C                   Eval      %Subst(TUERRD:$Y:W_RcvLen) =
     C                             %Subst(Str:$X:W_RcvLen)
     C                   Eval      TUERSN = TUERSN + 1
     C                   Exsr      @UpdTUEF
     C   99              Leave
      *
     C                   If        WkTermin = *Off
     C                   Eval      TUERRD = *Blank
     C                   Eval      $Y = 1
     C                   Eval      $X = 1
     C                   Eval      WkSpace = WkFldLen
     C                   EndIf
      *
      * Received Length > Space left
     C                   When      W_RcvLen > WkSpace
     C                   Eval      %Subst(TUERRD:$Y:WkSpace) =
     C                             %Subst(Str:$X:WkSpace)
     C                   Eval      TUERSN = TUERSN + 1
     C                   Exsr      @UpdTUEF
     C   99              Leave
      *                                                                 99
     C                   Eval      TUERRD = *Blank
     C                   Eval      $Y = 1
     C                   Eval      $X = WkSpace + 1
     C                   Eval      WkRmdCnt = W_RcvLen - WkSpace
      *
     C                   Eval      %Subst(TUERRD:$Y:WkRmdCnt) =
     C                             %Subst(Str:$X:WkRmdCnt)
     C                   If        WkTermin or *In88
     C                   Eval      TUERSN = TUERSN + 1
     C                   Exsr      @UpdTUEF
     C   99              Leave
     C                   EndIf
      *
     C                   If        WkTermin = *Off
     C                   Eval      $Y = $Y + WkRmdCnt
     C                   Eval      $X = 1
     C                   Eval      WkSpace = WkFldLen - WkRmdCnt
     C                   EndIf
      *
     C                   EndSl
     C                   EndIf
      *
      * Write the Report Data to Stream File
     C                   If        W_Report = *On and
     C                             W_RcvLen > *Zero
      * Start from pointer $b
     C                   Eval      rc = fputs(%Subst(Str:$b:RetCode-$b+1) +
     C                                  LF : FILE_o)
     **
     C                   EndIf
     C                   EndDo
      *
     C     $XSckFnt      Tag
     C                   Eval      RetCode = Cls_Tcp( ScktNum )
      *
     C                   Endsr
      *===================================================================*
      * @UpdTUEF - Update file SCKPGMF
      *===================================================================*
     C     @UpdTUEF      BegSr
     C                   Move      P_EnqD        TUETCD
     C                   Eval      TUETSN = P_EnqSeq
02820C                   Exsr      @PWD_DM
     C                   Write     SCKPGMFR                              99
     C   99'0001'        DUMP
     C   99              Eval      RtnCde = 2
     C   99              Goto      $XUpdTUEF
      *
     C                   If        W_Report = *Off and
     C                             *In88    = *On
     C                   Eval      W_Report = *On
     **-- open files, implicit conversion to job codepage:
     C                   Eval      FILE_o = open( %TrimR( FilNam )
     C                                     : 'w')
     **-- open files error, dump
     C                   If        FILE_o =  *Null
     C                   Eval      *In99 = *On
     C     '0002'        DUMP
     C                   Endif
      *
     C                   EndIf
      *
     C     $XUpdTUEF     TAG
     C                   EndSr
02820 *===================================================================*
02820 * @PWD_DM - Dump for Pass Word changing                              *
02820 *===================================================================*
02820C     @PWD_DM       Begsr
02820C                   If        %Subst(TUERRD:52:2) = 'PW'
02820C     '9999'        Dump
02820C                   Eval      WkPWD = *On
02820C                   EndIf
02820C                   EndSr
      *===================================================================*
      * Initialization                                                     *
      *===================================================================*
     C     *INZSR        Begsr
     C                   Eval      WkFldLen = 32650
     C                   Eval      WkSpace  = WkFldLen
     C                   Eval      $Y = 1
     C                   Eval      $X = 1
     C                   Eval      WkRmdCnt = *Zero
     C                   Eval      WkTermin = *Off
     C                   Eval      W_Report = *Off
     C                   Eval      TUERSN   = *Zero
     C                   Eval      TUERRD   = *Blank
02820C                   Eval      WkPWD    = *Off
      * Setup the File Name for TU Report in IFS
     C     *ISO0         Move      P_EnqD        Char_8a
     C                   Eval      FilNam = '/SCKF/SCK' + Char_8a
     C                              + %SubSt(%EditW(p_EnqSeq:'0     '):2)
      * Determine the IP address and Port Number
     C                   If        P_System  = 'PRODSYS '
     C                   Eval      RISC = '172.19.1.123'
     C                   Eval      PortNbr = 25009
     C                   Else
     C                   Eval      RISC = '172.19.1.124'
     C                   Eval      PortNbr = 26001
     C                   EndIf
     C                   EndSr
