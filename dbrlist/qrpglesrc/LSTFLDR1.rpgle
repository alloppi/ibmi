      *=============================================================== =
      * To compile:
      *
      *
      *     CRTBNDRPG PGM(xxx/LSTFLDR1) SRCFILE(xxx/QRPGLESRC)
      *
      *=============================================================== =
      *
      * List Record Formats
      *
      *=============================================================== =
     FLstFldD1  CF   E             WORKSTN SFILE(LSTFldSFL:RRN1)
      **----------------------------------------------------------------
      *
      **************************************************************************
     D Cmds            PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const
      *
     D CmdString       S            200a
      **************************************************************************
      * User Space Variables
      **************************************************************************
     D qUserNm         S             20a
     D qText           S             50a
     D eXtAtr          S             10a    INZ('*JOB')
     D iNzSize         S             10i 0  INZ(5000)
     D iNVal           S              1a    INZ(X'00')
     D pUbAut          S             10a    INZ('*ALL')
     D rEplace         S             10a    INZ('*YES')
     D qStart          S             10i 0
     D qLen            S             10i 0
      *
      **************************************************************************
      * List Data Generic Header
      **************************************************************************
     D HdrSection      Ds
     D  UserArea                     64
     D  GenHdrSiz                    10i 0
     D  StrucLevel                    4
     D  FormatName                    8
     D  ApiUsed                      10
     D  CreateStamp                  13
     D  InfoStatus                    1
     D  SizeUsUsed                   10i 0
     D  InpParmOff                   10i 0
     D  InpParmSiz                   10i 0
     D  HeadOffset                   10i 0
     D  HeaderSize                   10i 0
     D  ListOffset                   10i 0
     D  ListSize                     10i 0
     D  ListNumber                   10i 0
     D  EntrySize                    10i 0
      *
      ****************************************************************
      * Miscellaneous Variables
      ****************************************************************
     D RRn1            S              5  0
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'
     D hi              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D IFile           S             10a
     D ILib            S             10a
     D IFmt            S             10a
     D SavRec#         S              2  0
      ****************************************
      * Input format for API QUSLFLD
      ****************************************
     D  IFormatName    S              8a
     D  IQFileName     S             20a
     D  IRecFmt        S             10a
     D  IOverride      S              1a
      ****************************************
      * Output format for API QUSLFLD
      ****************************************
     D FLDL0100        DS
     D  FieldName                    10a
     D  DataType                      1a
     D  Use                           1a
     D  OutBuffPos                   10i 0
     D  InBuffPos                    10i 0
     D  FldLen                       10i 0
     D  Digits                       10i 0
     D  Decimals                     10i 0
     D  FldText                      50a
     D  EditCode                      2a
     D  ColumnHead1                  20a
     D  ColumnHead2                  20a
     D  ColumnHead3                  20a
     D  IntrnlFldName                10a
     D  AltrnFldName                 30a
     D  LenAltFldNam                 10i 0
     D  NumDBCS                      10i 0
     D  NullsAllowed                  1a
     D  DateTimeFmt                   4a
     D  DateTimeSep                   4a
     D  VarLenFldInd                  1a
     D  FldTxtCCSID                  10i 0
     D  FldDtaCCSID                  10i 0
     D  FldClmCCSID                  10i 0
     D  FldEdtWCCSID                 10i 0
     D  UCS2DsplLen                  10i 0
     D  FldDtaEncSch                 10i 0
     D  MaxLrgObjFLn                 10i 0
     D  PadLenLgObj                  10i 0
     D  LenUsrDefNam                 10i 0
     D  UsrDefTypNam                128a
     D  UsrDefTypLib                 10a
     D  DataLinkCtl                   1a
     D  DataLinkInt                   1a
     D  DataLinkRd                    1a
     D  DataLinkWt                    1a
     D  DataLinkRcv                   1a
     D  DataLinkUnl                   1a
     D  DspPrtRow#                   10i 0
     D  DspPrtCol#                   10i 0
     D  RowID                         1a
     D  IDCol                         1a
     D  GennedBy                      1a
     D  IDColCycle                    1a
     D  IDColOStr                    31  0
     D  IDColCStr                    31  0
     D  IDColInc                     10i 0
     D  IDColMnVal                   31  0
     D  ODColMxVal                   31  0
     D  IDColCache                   10i 0
     D  Rsvrd                        11a
      *******************************************************
      * Generic API Error Data Structure
      *******************************************************
     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256
      *
     C     *Entry        Plist
     C                   Parm                    IFile
     C                   Parm                    ILib
     C                   Parm                    IFmt
      *
     C                   If        IFile <> *Blanks
     C                              and ILib <> *Blanks
     C                   Exsr      UsrSpcRtns
      *
     C                   Eval      ILibFil = %Trimr(ILib) + '/' + %Trimr(IFile)
     C                             + '/' + %Trimr(IFmt)
      *
     C                   Dow       *In03 = *Off
      *
     C                   if        Rrn1 > 0
     C                   eval      *In91 = *On
     C                   endif
      *
     C                   Write     LstFldFtr
     C                   Exfmt     LstFldCtl
      *
     C                   If        *In03 = *On
     C                   Leave
     C                   Endif
      *
     C                   Enddo
      *
     C                   Endif
     C                   Eval      *Inlr = *On
      *********************************************************************************
      * UsrSpcRtns - User Space Routines
      *********************************************************************************
     C     UsrSpcRtns    Begsr
      *
     C                   Exsr      DltUsrSpc
     C                   Exsr      CrtUsrSpc
     c                   if        dsECBytesA > 0
     C                   Exsr      ClrSfl
     C                   Else
     C                   Exsr      ExecAPI
     c                   if        dsECBytesA > 0
     C                   Exsr      ClrSfl
     C                   Else
     C                   Exsr      RtvUsrSpcHdr
     c                   if        dsECBytesA > 0
     C                   Exsr      ClrSfl
     C                   Else
     C                   Exsr      ClrSfl
     C                   Exsr      RtvUsrSpcDtl
     C                   Endif
     C                   Endif
     C                   Endif
      *
     C                   Endsr
      *********************************************************************************
      * DltusrSpc - Delete User Space
      *********************************************************************************
     C     DltUsrSpc     Begsr
      * Create the Qualified User Space Name
     C                   Eval      qUserNm = 'LSTFLDS   QTEMP     '
     C                   Eval      qText = 'List File Fields'
      *
      * Attempt to delete the user space first...
      * Just to clean it up
     C                   Call      'QUSDLTUS'                           50
     C                   Parm                    qUserNm
     C                   Parm                    dsEc
      *
     C                   Endsr
      *
      *********************************************************************************
      * CrtUsrSpc - Create User Space
      *********************************************************************************
     C     CrtUsrSpc     Begsr
     C                   Call      'QUSCRTUS'                           50
     C                   Parm                    qUserNm
     C                   Parm      *Blanks       eXtAtr
     C                   Parm      5000          iNzSize
     C                   Parm      *Blanks       iNVal
     C                   Parm      '*CHANGE'     pUbAut
     C                   Parm                    qText
     C                   Parm                    rEplace
     C                   Parm                    dsEc
      *
     C                   Endsr
      *********************************************************************************
      * ExecAPI  - Execute API
      *********************************************************************************
     C     ExecAPI       Begsr
     C                   Eval      IQFIleName = IFile + ILib
     C                   Eval      IQfileName = %Xlate(lo:hi:IQfileName)
     C                   Eval      IRecFmt    = %Xlate(lo:hi:IFmt)
     C                   Call      'QUSLFLD'
     C                   Parm                    qUserNM
     C                   Parm      'FLDL0100'    IFormatName
     C                   Parm                    IQFileName
     C                   Parm                    IRecFmt
     C                   Parm      '0'           IOverride
     C                   Parm                    dsEc
      *
     C                   Endsr
      *********************************************************************************
      * RtvUsrSpcHdr - Retrieve User Space Header Section
      *********************************************************************************
     C     RtvUsrSpcHdr  Begsr
      *
     C                   Call      'QUSRTVUS'
     C                   Parm                    qUserNM
     C                   Parm      1             qStart
     C                   Parm      140           qLen
     C                   Parm      *Blanks       HdrSection
     C                   Parm                    dsEc
      *
     C                   Endsr
      *********************************************************************************
      * RtvUsrSpcDtl - Retrieve User Space Details
      *********************************************************************************
     C     RtvUsrSpcDtl  Begsr
      *
     C                   Eval      qStart = ListOffset + 1
      *
      ** Loop through User Space for number of list entries returned
     C                   Do        ListNumber
      *
     C                   Call      'QUSRTVUS'
     C                   Parm                    qUserNM
     C                   Parm                    qStart
     C                   Parm      EntrySize     qLen
     C                   Parm      *Blanks       FLDL0100
     C                   Parm                    dsEc
      *
      * Write the Database Relastions Information to the Subfile
     C                   Exsr      BldSfl
      *
     C                   Eval      qStart = qStart + EntrySize
      *
     C                   Enddo
      *
     C                   Eval      *In99 = *On
     C                   Endsr
      *********************************************************************************
      * Clear Subfile - CLRSFL
      *********************************************************************************
     C     ClrSfl        Begsr
      *
     C                   eval      *In89 = *On
     C                   eval      *In90 = *Off
     C                   eval      *In91 = *Off
     C                   Write     LstFldCtl
     C                   eval      Rrn1 = 0
     C                   eval      *In89 = *Off
     C                   eval      *In90 = *On
      *
     C                   Endsr
      *********************************************************************************
      * Build Subfile - BldSfl
      *********************************************************************************
     C     BldSfl        Begsr
      *
     C                   eval      FName =  %Xlate(hi:lo:FieldName:2)
     C                   eval      Ftype = DataType
     C                   eval      FUsage = use
     C                   eval      Flen = FldLen
     C                   eval      FDec = Decimals
     C                   eval      FText   =  %Xlate(hi:lo:FldText:2)
     C                   Eval      *In99 = *On
     C                   eval      Rrn1 = Rrn1 + 1
     C                   Write     LstFldSfl
      *
     C                   Eval      RcdNbr = 1
     C                   Endsr
