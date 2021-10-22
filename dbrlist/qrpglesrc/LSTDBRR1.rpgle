      *=============================================================== =
      * To compile:
      *
      *
      *     CRTBNDRPG PGM(xxx/LSTDBRR1) SRCFILE(xxx/QRPGLESRC)
      *
      *=============================================================== =
      *
      * List Database Relations
      *
      *=============================================================== =
     FLstDBRD1  CF   E             WORKSTN SFILE(LSTDBRSFL:RRN1)
      **----------------------------------------------------------------
     D DatTime         S             26
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
     D R               S              5  0
     D S               S              5  0
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'
     D hi              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D IFile           S             10a
     D ILib            S             10a
     D OFile           S             10a
     D OLib            S             10a
     D SavRec#         S              2  0
      ****************************************
      * Input format for API QDBLDBR
      ****************************************
     D  IUserSpcName   S             10a
     D  IUserSpcLib    S             10a
     D  IFormatName    S              8a
     D  IQFileName     S             20a
     D  IMemberName    S             10a
     D  IRecordFmt     S             10a
      ****************************************
      * Output format for API QDBLDBR
      ****************************************
     D DBRL0200        DS
     D  FileNameUsed                 10a
     D  FileLibUsed                  10a
     D  MemberUsed                   10a
     D  DepFileName                  10a
     D  DepLibName                   10a
     D  DepMbrName                   10a
     D  DepType                       1a
     D  Rsrvd                         3a
     D  JoinRef#                     10i 0
     D  JoinFile#                    10i 0
     D  ConstLibName                 10a
     D  ConstNameLen                 10i 0
     D  ConstName                   258a
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
     C     *Entry        PList
     C                   Parm                    IFILE
     C                   Parm                    ILIB
      *
     C                   Exsr      UsrSpcRtns
      *
     C                   Dow       *In03 = *Off
      *
     C                   if        Rrn1 > 0
     C                   eval      *In91 = *On
     C                   endif
      *
     C                   If        SavRec# > 0
     C                   Eval      RcdNbr = SavRec#
     C                   Eval      SavRec# = 0
     C                   Endif
      *
     C                   Write     LstDBRFtr
     C                   Exfmt     LstDBRCtl
      *
     C                   If        *In03 = *On
     C                   Eval      *Inlr = *On
     C                   Return
     C                   Endif                                                                     i
      *
     C                   If        *In91 = *On
     C                   Exsr      Rdsfl
     C                   Endif
      *
     C                   If        IFile <> *Blanks
     C                              and ILib <> *Blanks
     C                   Exsr      UsrSpcRtns
     C                   Endif
      *
     C                   Enddo
      *
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
     C                   Eval      qUserNm = 'LSTDBR    QGPL      '
     C                   Eval      qText = 'List Database Rltns'
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
     C                   Call      'QDBLDBR'
     C                   Parm                    qUserNM
     C                   Parm      'DBRL0200'    IFormatName
     C                   Parm                    IQFileName
     C                   Parm      '*ALL'        IMemberName
     C                   Parm      '*ALL'        IRecordFmt
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
     C                   Parm      *Blanks       DBRL0200
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
     C                   Write     LstDBRCtl
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
     C                   eval      DepLibName = %Xlate(hi:lo:DepLibName:2)
     C                   eval      DepFileName = %Xlate(hi:lo:DepFileName:2)
     C                   eval      DepMbrName = %Xlate(hi:lo:DepMbrName:2)
     C                   eval      DFL =  %Trimr(DepLibName) + '/' +
     C                                    %Trimr(DepFileName) + '/' +
     C                                    %Trimr(DepMbrName)
     C                   Select
     C                   When      DepType = 'C'
     C                   Eval      DepTyp = 'Constraint'
     C                   When      DepType = 'D'
     C                   Eval      DepTyp = 'Data'
     C                   When      DepType = 'I'
     C                   Eval      DepTyp = 'Shr Access Path'
     C                   When      DepType = 'O'
     C                   Eval      DepType = 'Accs Pth Owner'
     C                   When      DepType = 'V'
     C                   Eval      DepTyp = 'SQL View'
     C                   Endsl
     C                   If        ConstName > ' '
     C                   eval      Constrt =  %Trimr(ConstLibName) + '/' +
     C                                        %Trimr(ConstName)
     C                   Endif
     C                   Eval      *In99 = *On
     C                   eval      Rrn1 = Rrn1 + 1
     C                   Write     LstDBRSfl
      *
     C                   eval      RcdNbr = 1
     C                   Endsr
      *********************************************************************************
      * Read  Subfile - RdSfl
      *********************************************************************************
     C     RdSfl         Begsr
      *
     C                   Readc     LstDbrSfl                              50
     C                   Dow       *In50 = *Off
     C                   Eval      SavRec# = RRn1
     C                   Select
     C                   When      Select = '2'
     C                   Eval      R = %Scan('/':DFL:1)
     C                   If        R > 0
     C                   Eval      OLib = %Subst(DFL:1:R - 1)
     C                   Eval      S = R + 1
     C                   Eval      R = %Scan('/':DFL:S)
     C                   If        R > 0
     C                   Eval      OFile = %Subst(DFL:S:R - S)
     C                   Call      'LSTFMTR1'
     C                   Parm                    OFile
     C                   Parm                    OLib
     C                   Endif
     C                   Endif
     C                   Eval      Select = ' '
     C                   Update    LstDbrSfl
     C                   Endsl
     C                   Readc     LstDbrSfl                              50
     C                   Enddo
      *
     C                   Endsr
