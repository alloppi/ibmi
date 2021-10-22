      *=============================================================== =
      * To compile:
      *
      *
      *     CRTBNDRPG PGM(xxx/LSTFILR1) SRCFILE(xxx/QRPGLESRC)
      *
      *=============================================================== =
      *
      * List Files by Library
      *
      *=============================================================== =
     FLstFilD1  CF   E             WORKSTN SFILE(LSTFILSFL:RRN1)
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
     D OFile           S             10a
     D OLib            S             10a
     D SavRec#         S              2  0
     D FileType        S              1a
     D RcvrVar         S           2176a
     D RcvrLen         S             10i 0
      ****************************************
      * Input format for API QUSLOBJ
      ****************************************
     D  IUserSpcName   S             10a
     D  IUserSpcLib    S             10a
     D  IFormatName    S              8a
     D  IQFileName     S             20a
     D  IObjType       S             10a
     D  IQMbrName      S             10a
     D  IQOverRide     S              1a
      ****************************************
      * Output format for API QUSLOBJ
      ****************************************
     D OBJL0700        DS
     D  ObjNameUsed                  10a
     D  ObjLibUsed                   10a
     D  ObjTypeUsed                  10a
     D  InfStatus                     1a
     D  ExtObjAtr                    10a
     D  Text                         50a
     D  UserDfnAtr                   10a
     D  Rsrvd                         7a
     D  ASP#                         10i 0
     D  ObjOwner                     10a
     D  ObjDomain                     2a
     D  CrtDatTime                    8a
     D  ChgDatTime                    8a
     D  Storage                      10a
     D  ObjCmpSts                     1a
     D  AlwChgPgm                     1a
     D  ChgByPgm                      1a
     D  ObjAudVal                    10a
     D  DgtlSgnd                      1a
     D  DgtlSgndSTS                   1a
     D  DgtlSgndMO                    1a
     D  Rsrvd2                        2a
     D  LibASP                       10i 0
     D  SrcFName                     10a
     D  SrcFLib                      10a
     D  SrcFMbr                      10a
     D  SrcFUpDtTm                   13a
     D  CrtUsrPrf                    10a
     D  SysWObjCrt                    8a
     D  SysLevel                      9a
     D  Compiler                     16a
     D  ObjLevel                      8a
     D  UsrChanged                    1a
     D  LicPgm                       16a
     D  PTF                          10a
     D  APAR                         10a
     D  PrimaryGp                    10a
     D  Rsrvd3                        2a
     D  OptSpcAlgn                    1a
     D  AscSpcSiz                    10i 0
     D  Rsrvd4                        4a
     D  ObjSavDtTm                    8a
     D  ObjRstDtTm                    8a
     D  SaveSize                     10i 0
     D  SaveSizeMltp                 10i 0
     D  SaveSeq#                     10i 0
     D  SaveCmd                      10a
     D  SaveVolID                    71a
     D  SaveDev                      10a
     D  SaveFile                     10a
     D  SaveLib                      10a
     D  SaveLbl                      17a
     D  SaveActDtTm                   8a
     D  JrnlStatus                    1a
     D  JrnlName                     10a
     D  JrnlLib                      10a
     D  JrnlImg                       1a
     D  JrnlEntOmt                    1a
     D  JrnlStdatTm                   8a
     D  Rsrvd5                       13a
     D  LastUsedDtTm                  8a
     D  ResetDtTm                     8a
     D  DaysUsedCnt                  10i 0
     D  UseageInfUpd                  1a
     D  ObjASPDevNam                 10a
     D  LibASPDevNam                 10a
     D  Rsrvd6                        3a
     D  ObjSize                      10i 0
     D  ObjSizeMlt                   10i 0
     D  ObjOvrFlwASPi                 1a
     D  Rsrvd7                        3a
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
     C                   Exsr      ClrSfl
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
     C                   Write     LstFilFtr
     C                   Exfmt     LstFilCtl
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
     C                   If        ILib  <> *Blanks
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
     C                   Eval      qUserNm = 'LSTFILE   QGPL      '
     C                   Eval      qText = 'List Files'
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
     C                   Eval      IQFIleName = '*ALL      ' + ILIB
     C                   Call      'QUSLOBJ'
     C                   Parm                    qUserNM
     C                   Parm      'OBJL0700'    IFormatName
     C                   Parm                    IQFileName
     C                   Parm      '*FILE'       IObjType
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
     C                   Parm      *Blanks       OBJL0700
     C                   Parm                    dsEc
      *
      * Write the Database Relastions Information to the Subfile
     C                   Exsr      BldSfl
      *
     C                   Eval      qStart = qStart + EntrySize
      *
     C                   Enddo
      *
     C                   Eval      RcdNbr = 1
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
     C                   Write     LstFilCtl
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
     C                   If        ExtObjAtr   = 'PF'
      *
     C                   Exsr      RtvMbrInfo
      *
      * Only Select Data Files
     C                   If        FileType = '0'
      *
     C                   eval      Select = *Blanks
     C                   eval      Fname      = %Xlate(hi:lo:ObjNameUsed:2)
     C                   eval      FSize = ObjSize
     C                   eval      ObjOwn = ObjOwner
     C                   Movel     Text          FText
     C                   Eval      *In99 = *On
     C                   eval      Rrn1 = Rrn1 + 1
     C                   Write     LstFilSfl
     C                   Endif
      *
     C                   Endif
     C                   Eval      RcdNbr = 1
      *
     C                   Endsr
      *********************************************************************************
      * RtvMbrInfo - Retrieve Member Information
      *********************************************************************************
     C     RtvMbrInfo    Begsr
     C                   Eval      IQFileName = ObjNameUsed + ILIB
     C                   eval      IQFileName = %Xlate(lo:hi:IQFileName)
     C                   Call      'QUSRMBRD'
     C                   Parm                    RcvrVar
     C                   Parm      2176          RcvrLen
     C                   Parm      'MBRD0100'    IFormatName
     C                   Parm                    IQFileName
     C                   Parm      '*FIRST'      IQMbrName
     C                   Parm      '0'           IQOverRide
     C                   Parm                    dsEc
      *
     C                   If        dsECBytesA = 0
     C                   Eval      FileType = %Subst(RcvrVar:135:1)
     C                   Endif
      *
     C                   Endsr
      *********************************************************************************
      * Read  Subfile - RdSfl
      *********************************************************************************
     C     RdSfl         Begsr
      *
     C                   Eval      OFile = *Blanks
      *
     C                   Readc     LstFilSfl                              50
     C                   Dow       *In50 = *Off
     C                   If        Select > ' '
     C                   eval      OFile      = %Xlate(lo:hi:FName)
     C                   Eval      SavRec# = RRn1
     C                   Select
     C                   When      Select = '2'
     C                   Call      'LSTFMTR1'
     C                   Parm                    OFile
     C                   Parm                    ILib
     C                   When      Select = '3'
     C                   Call      'LSTDBRR1'
     C                   Parm                    OFile
     C                   Parm                    ILib
     C                   Eval      Select = ' '
     C                   Update    LstFilSfl
     C                   Endsl
     C                   Endif
     C                   Readc     LstFilSfl                              50
     C                   Enddo
      *
     C                   Endsr
