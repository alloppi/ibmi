      *=============================================================== =
      * To compile:
      *
      *
      *     CRTBNDRPG PGM(xxx/LSTFMTR1) SRCFILE(xxx/QRPGLESRC)
      *
      *=============================================================== =
      *
      * List Record Formats
      *
      *=============================================================== =
     FLstFMTD1  CF   E             WORKSTN SFILE(LSTFMTSFL:RRN1)
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
     D R               S              5  0
     D S               S              5  0
     D SavRec#         S              2  0
      ****************************************
      * Input format for API QUSLRCD
      ****************************************
     D  IFormatName    S              8a
     D  IQFileName     S             20a
     D  IOverride      S              1a
      ****************************************
      * Output format for API QUSLRCD
      ****************************************
     D RCDL0200        DS
     D  RecFmtName                   10a
     D  RecFmtID                     13a
     D  Reserved                      1a
     D  RecLen                       10i 0
     D  NumFlds                      10i 0
     D  RecText                      50a
     D  Reserved2                     2a
     D  RecTextCCSID                 10i 0
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
      *
     C                   If        IFile <> *Blanks
     C                              and ILib <> *Blanks
     C                   Exsr      UsrSpcRtns
      *
     C                   Eval      ILibFil = %Trimr(ILib) + '/' + %Trimr(IFile)
      *
     C                   Dow       *In03 = *Off
      *
     C                   if        Rrn1 > 0
     C                   eval      *In91 = *On
     C                   endif
      *
      *
     C                   If        SavRec# > 0
     C                   Eval      RcdNbr = SavRec#
     C                   Eval      SavRec# = 0
     C                   Endif
      *
     C                   Write     LstFmtFtr
     C                   Exfmt     LstFmtCtl
      *
     C                   If        *In03 = *On
     C                   Leave
     C                   Endif
      *
     C                   If        *In91 = *On
     C                   Exsr      Rdsfl
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
     C                   Eval      qUserNm = 'LRCDFMT   QTEMP     '
     C                   Eval      qText = 'List Record Formats'
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
     C                   Call      'QUSLRCD'
     C                   Parm                    qUserNM
     C                   Parm      'RCDL0200'    IFormatName
     C                   Parm                    IQFileName
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
     C                   Parm      *Blanks       RcdL0200
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
     C                   Write     LstFmtCtl
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
     C                   eval      RFormat =  %Xlate(hi:lo:RecFmtName:2)
     C                   eval      Rlen = RecLen
     C                   eval      R#Fields = NumFlds
     C                   eval      RText   =  %Xlate(hi:lo:RecText:2)
     C                   Eval      *In99 = *On
     C                   eval      Rrn1 = Rrn1 + 1
     C                   Write     LstFmtSfl
      *
     C                   Eval      RcdNbr = 1
     C                   Endsr
      *********************************************************************************
      * Read  Subfile - RdSfl
      *********************************************************************************
     C     RdSfl         Begsr
      *
     C                   Readc     LstFmtSfl                              50
     C                   Dow       *In50 = *Off
     C                   If        Select > ' '
     C                   Eval      SavRec# = RRn1
     C                   Select
     C                   When      Select = '2'
     C                   Call      'LSTFLDR1'
     C                   Parm                    IFile
     C                   Parm                    ILib
     C                   Parm                    RFormat
     C                   Eval      Select = ' '
     C                   Update    LstFmtSfl
     C                   Endsl
     C                   Endif
     C                   Readc     LstFmtSfl                              50
     C                   Enddo
      *
     C                   Endsr
