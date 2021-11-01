      *===================================================================*
      * Program name: SNDMAILR                                            *
      * Purpose.....: Create Email by API QtmmSendMail                    *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- ----------------------------*
      * 2011/08/23 Alan       AC              New                         *
      *===================================================================*
      * Extract from News/400 Sept-1998                                   *
      * Date written: 2005/09/30                                          *
      *                                                                   *
      * Pre-request                                                       *
      * 1 Use the CFGTCP then option 12 to add the Host Name for this     *
      *   and Domain Name for this machine                                *
      *   Eg  Host Name   : PROMISE 4                                     *
      *       Domain Name : PROMISE_HK                                    *
      *                                                                   *
      * 2 Define the Host name for this machine in host tabel by          *
      *   CFGTCP then option 10                                           *
      *   Eg. Internet         Host                                       *
      *       Address          Name                                       *
      *       172.18.101.14    PROMISE4.PROMISE_HK                        *
      *                                                                   *
      * 3 Config the SMTP Server                                          *
      *   CHGSMTPA MAILROUTER('SMTP.PROMISE.COM.HK')                      *
      *                                                                   *
      * 4 Add Host Table Entry 202.64.33.147    SMTP.PROMISE.COM.HK       *
      *                                                                   *
      * 5 Start the SMTP Server, after that, you can find the 4 jobs      *
      *   as below in QsysWrk sub-system                                  *
      *  Subsystem/Job  User        Type  CPU %  Function     Status      *
      *   QSYSWRK                                                         *
      *   QTSMTPBRCL   QTCP        BCH      .0                 DEQW       *
      *   QTSMTPBRSR   QTCP        BCH      .0                 DEQW       *
      *   QTSMTPCLTD   QTCP        BCH      .0                 DEQW       *
      *   QTSMTPSRVD   QTCP        BCH      .0                 SELW       *
      *   And also in Job Log                                             *
      *   Job 860893/QTCP/QTSMTPSRVD started on .....                     *
      *   If get error in starting SMTP, you may find the spool file      *
      *   Spool File in                                                   *
      *               Device or                       Total               *
      *   File        Queue       User Data   Status  Pages               *
      *   QPJOBLOG    QEZJOBLOG   QTSMTPSRVD   RDY        2               *
      *                                                                   *
      * 6 Also start StrMSF, after that you can find the jobs as          *
      *   as below in QsysWrk sub-system                                  *
      *  Subsystem/Job  User        Type  CPU %  Function     Status      *
      *   QSYSWRK                                                         *
      *   QMSF         QMSF        BCH      .0                 DEQW       *
      *   And also in Job Log                                             *
      *   Job 443906/QMSF/QMSF ...                  .                     *
      *                                                                   *
      * Upload by iSeries Access                                          *
      * - THNCILIB\QHTMSRC(MTHSTM)                                        *
      *                                                                   *
      * Upload by FTP                                                     *
      * FTP command :                                                     *
      * Connect to Host - FTP Promise3                                    *
      *   then login                                                      *
      * Put file to Host - Put c:\abc.txt thncilib/QHTMSRC.MTHSTM         *
      * Exit FTP         - Quit                                           *
      * Sample in MIME :                                                  *
      * From: =?big5?B?xHi668ZG?= <alan.yl@cisd.com.hk>                   *
      * To: =?big5?B?tF6l/aXN?= <promise@promise.com.hk>                  *
      * 　　彭先生                                                      *
      * Subject: =?big5?B?tPq41Q==?=                                      *
      *          測試                                                   *
      * Content-Type: text/plain;                                         *
      * AS400 =B4=FA=B8=D5                                                *
      * AS400 測試                                                      *
      *                                                                   *
      * Content-Type: text/plain;                                         *
      *  charset="big5"                                                   *
      * Content-Transfer-Encoding: quoted-printable                       *
      *                                                                   *
      *                                                                   *
      *      Content-Type: text/plain; charset=ISO-8859-1                 *
      *      Content-transfer-encoding: base64                            *
      *                                                                   *
      * CRTRPGMOD lib/SNDMAILR srcfile(srclib/QRPGSRC)                    *
      * CrtPgm lib/SNDMAILR module(lib/SNDMAILR) bndsrvpgm(qtcp/qtmmsndm) *
      *                                                                   *
      *===================================================================*
      * Sample Output in /tmp/..                                          *
      *===================================================================*
      * Sender: alan.yl@cisd.com.hk
      * Date:
      * From: =?big5?q?=B3=AF=A5=FD=A5=CD?= <alan.yl@cisd.com.hk>
      * MIME-Version: 1.0
      * To: =?big5?B?tsCl/aXN?= <alan.yl@cisd.com.hk>
      * Subject: =?big5?B?pOu1srPm?=
      * Content-Type: multipart/alternative; boundary="--PART.BOUNDARY.1"
      *
      * This is a multi-part message in MIME format.
      *
      * ----PART.BOUNDARY.1
      * Content-Type: text/html; charset=big5
      * Content-Transfer-Encoding: quoted-printable
      *
      * <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0....
      *
      *
      *
      * ----PART.BOUNDARY.1--
      *
      *===================================================================*
99999HDEBUG(*YES)
      * IFS ProtoTypes
      *** open an IFS File
     Dopen             PR            10I 0 EXTPROC('open')
     D  filename                       *   VALUE
     D  openflags                    10I 0 VALUE
     D  mode                         10U 0 VALUE OPTIONS(*NOPASS)
     D  codepage                     10U 0 VALUE OPTIONS(*NOPASS)
     D*** read an IFS file
     Dread             PR            10I 0 EXTPROC('read')
     D  filehandle                   10I 0 VALUE
     D  datareceived                   *   VALUE
     D  nbytes                       10U 0 VALUE
     D*** write to an IFS file
     Dwrite            PR            10I 0 EXTPROC('write')
     D  filehandle                   10I 0 VALUE
     D  datatowrite                    *   VALUE
     D  nbytes                       10U 0 VALUE
     D*** close an IFS file
     Dclose            PR            10I 0 EXTPROC('close')
     D  filehandle                   10I 0 VALUE
     D
      *==============================================================*
     D* IFS CONSTANTS *
      *==============================================================*
     D*** File Access Modes for open()
     D O_RDONLY        S             10I 0 INZ(1)
     D O_WRONLY        S             10I 0 INZ(2)
     D O_RDWR          S             10I 0 INZ(4)
     D*** oflag values for open()
     D O_CREAT         S             10I 0 INZ(8)
     D O_EXCL          S             10I 0 INZ(16)
     D O_TRUNC         S             10I 0 INZ(64)
     D*** file status Flags for open() and fcntl()
     D O_NONBLOCK      S             10I 0 INZ(128)
     D O_APPEND        S             10I 0 INZ(256)
     D*** oflag share mode value for open()
     D O_SHARE_NONE    S             10I 0 INZ(2000000)
     D O_SHARE_RDONLY  S             10I 0 INZ(0200000)
     D O_SHARE_RDWR    S             10I 0 INZ(1000000)
     D O_SHARE_WRONLY  S             10I 0 INZ(0400000)
     D*** FILE PERMISSIONS
     D S_IRUSR         S             10I 0 INZ(256)
     D S_IWUSR         S             10I 0 INZ(128)
     D S_IXUSR         S             10I 0 INZ(64)
     D S_IRWXU         S             10I 0 INZ(448)
     D S_IRGRP         S             10I 0 INZ(32)
     D S_IWGRP         S             10I 0 INZ(16)
     D S_IXGRP         S             10I 0 INZ(8)
     D S_IRWXG         S             10I 0 INZ(56)
     D S_IROTH         S             10I 0 INZ(4)
     D S_IWOTH         S             10I 0 INZ(2)
     D S_IXOTH         S             10I 0 INZ(1)
     D S_IRWXO         S             10I 0 INZ(7)
     D*** MISC
     D O_TEXTDATA      S             10I 0 INZ(16777216)
     D O_CODEPAGE      S             10I 0 INZ(8388608)
      *==============================================================*
      * DATA DEFINITIONS
      *==============================================================*
      *** MISCELLANEOUS DATA DECLARATIONS
     D FileName        S            256A
     D FileLen         S              9B 0
     D Originator      S            255A
     D OriginName      S             80A
     D OriginLen       S              9B 0
     D CPFNumber       S                   LIKE(CPFID)
     D Subject         S            256A
     D Message         S           1024A
     D AttachName      S            256A
     D AsciiCodePage   S             10U 0 INZ(819)
     D***
     D Addressee       S                   Like(Address)
     D AddresseeName   S                   Like(Address)
     D TotalRecp       S              9B 0
     D***
     D FileDesc        S             10I 0
     D BytesWrt        S             10I 0
     D Data            S           9999A
     D AttachDesc      S             10I 0
     D BytesRead       S             10I 0
     D DataRead        S           9999A
     D EOR             S              2A   Inz(X'0D25')
     D Null            S              1A   Inz(X'00')
     D FullName        S            512A
     D ReturnInt       S             10I 0
     D Pos             S              5U 0
     D SavePos         S                   Like(Pos)
     D*** Data structure of recipient info.
     D Recipient       DS
     D  OffSet                 1      4B 0
     D  AddrLen                5      8B 0
     D  Format                 9     16
     D  DistrType             17     20B 0
     D  Reserved              21     24B 0
     D  Address               25    280
     D*** MIME Header fields
     D MSender         S            256A
     D MDateTime       S            256A
     D MFrom           S            256A
     D MMimeVer        S            256A
     D MTo             S            256A
     D MSubject        S            256A
     D MBoundary       S            256A   Inz('--PART.BOUNDARY.1')
     D*** Array of file attachment
     D Attachment      DS
     D  NbrFiles               1      2B 0
     D  AttachFile                  256A   Dim(30)
     D*** API error info
     D APIError        DS
     D  APIBytes               1      4B 0
     D  CPFID                  9     15
     D*** Constants
     D DTo             C                   Const(0)
     D DCC             C                   Const(1)
     D DBCC            C                   Const(2)
     D MsgSize         C                   Const(%Len(Message))
      *==============================================================*
      * MainLine Calc.
      *==============================================================*
      *** Entry Parms
     C     *ENTRY        PLIST
     C                   PARM                    FileName
     C     Address       PARM                    Addressee
     C                   PARM                    Originator
     C                   PARM                    AddresseeName
     C                   PARM                    OriginName
     C                   PARM                    Attachment
     C                   PARM                    Subject
     C                   PARM                    Message
      *** Initialize error structure
     C                   Eval      APIBytes = 11
     C*** Set APIBytes to 0, error appear in workstation
     C***                Eval      APIBytes = 0
      *** Initialize values
     C                   Eval      FileLen = %Len(%Trimr(FileName))
     C                   Eval      %Subst(FileName:FileLen+1:2) = X'0000'
     C                   Eval      OriginLen = %Len(%Trimr(Originator))
     C                   Eval      Format = 'ADDR0100'
     C                   Eval      DistrType = Dto
     C                   Eval      Reserved = 0
     C                   Eval      AddrLen = %Len(%Trimr(Address))
     C                   Eval      Offset = 0
     C                   Eval      TotalRecp = 1
      *** Write MIME File
     C                   Exsr      WriteHdr
      *** Call API to send email
     C                   CallB     'QtmmSendMail'
     C                   Parm                    FileName
     C                   Parm                    FileLen
     C                   Parm                    Originator
     C                   Parm                    OriginLen
     C                   Parm                    Recipient
     C                   Parm                    TotalRecp
     C                   Parm                    APIError
     C                   If        APIBytes <> 0
     C                   Dump
     C                   Endif
      *** Return to caller
     C     Exit          Tag
     C                   Return
      *==============================================================*
      * Write Header portion of file
      *==============================================================*
     CSR   WriteHdr      BegSr
     C*** Open file
     C                   Eval      FullName = %TRIMR(FileName) + Null
     C                   Eval      FileDesc = open(%AddR(FullName)
     C                               : O_CREAT + + O_WRONLY + O_TRUNC +
     C                                 O_CODEPAGE
     C                               : S_IRWXU + S_IROTH
     C                               : AsciiCodePage)
     C                   Eval      ReturnInt = close(FileDesc)
     C                   Eval      FileDesc = open(%Addr(FullName)
     C                               : O_TEXTDATA + O_RDWR)
     C*** Build MIME Header fields
     C                   Eval      MSender =
     C                             'Sender: ' + Originator
     C                   Eval      MDateTime =
     C                             'Date: '
     C                   Eval      MFrom =
     C                             'From: ' +
     C                             %Trimr(OriginName) + ' <' +
     C                             %Trimr(Originator) + '>'
     C                   Eval      MMimeVer =
     C                             'MIME-Version: 1.0'
     C                   If        AddresseeName > *Blanks
     C                   Eval      MTo =
     C                             'To: ' + %Trimr(AddresseeName) +
     C                             ' <' + %Trimr(Address) + '>'
     C                   Else
     C                   Eval      MTo =
     C                             'To: ' + %TrimR(Address)
     C                   Endif
     C                   If        Subject > *Blanks
     C                   Eval      MSubject =  'Subject: ' + Subject
     C                   Else
     C                   Eval      MSubject =  'Subject: '
     C                   Endif
     C                   Eval      Data = %Trimr(MSender) + EOR +
     C                                    %Trimr(MDateTime) + EOR +
     C                                    %Trimr(MFrom) + EOR +
     C                                    %Trimr(MMimeVer) + EOR +
     C                                    %Trimr(MTo) + EOR +
     C                                    %Trimr(MSubject) + EOR +
      * Content-Type: text/plain;
      *  charset="big5"
      * Content-Transfer-Encoding: quoted-printable
     C*                            'Content-Type: multipart/mixed; boundary='+
     C                             'Content-Type: multipart/alternative;'+
     C                             ' boundary='+
     C                             '"' + %Trimr(MBoundary) + '"' + EOR + EOR +
     C                             'This is a multi-part message in MIME ' +
     C                             'format.' + EOR + EOR + '--' +
     C                             %Trimr(MBoundary) + EOR +
     C*                            'Content-Type: text/plain; '+
     C                             'Content-Type: text/html; '+
     C*                            'charset=us-ascii' + EOR +
     C                             'charset=big5' + EOR +
     C*                            'Content-Transfer-Encoding: 7-bit' +
     C                             'Content-Transfer-Encoding: '+
     C                             'quoted-printable'
      *
     C                   If        Message = '*HTML'
     C                   Eval      Data = %TrimR(Data) + EOR + EOR
      * do nothing first
     C                   Else
     C                   Eval      Data = %TrimR(Data) +
     C                             EOR + EOR + %Trimr(Message) + EOR + EOR +
     C                             EOR + EOR + '--' + %Trimr(MBoundary)
     C                   Endif
      *
     C*** Add attachment file(s) if requested
     C                   If        NbrFiles > *Zero
     C                             and AttachFile(1) <> '*NONE'
     C                   Exsr      WriteFile
     C                   Do        NbrFiles      Z                 5 0
     C                   Clear                   SavePos
     C                   Eval      Pos = %Scan('/':AttachFile(Z):1)
     C                   Dow       Pos > *Zero
     C                   Eval      SavePos = Pos
     C                   Eval      Pos = %Scan('/':AttachFile(Z):Pos+1)
     C                   Enddo
     C                   If        SavePos <> *Zero
     C                   Eval      AttachName = %Subst(AttachFile(Z):SavePos+1)
     C                   Else
     C                   Eval      AttachName = AttachFile(Z)
     C                   Endif
      * Comment the attachment part
     C**                 Eval      Data = EOR +
     C**                           'Content-Type: application/octet-stream; '+
     C**                           ' name="' + %Trimr(AttachName) + '"' + EOR+
     C**                           'Content-Transfer-Encoding: 7bit' + EOR +
     C**                           'Content-Disposition: inline; filename="' +
     C**                           %Trimr(AttachName) + '"' + EOR + EOR
     C**                 Exsr      WriteFile
     C** Open File
     C                   Eval      FullName = %Trimr(AttachFile(Z)) + Null
     C                   Eval      AttachDesc = open(%Addr(FullName)
     C                             : O_RDONLY + O_TEXTDATA)
     C** Read from file and write to MIME file
     C                   Eval      BytesRead = read(AttachDesc
     C                             : %Addr(DataRead)
     C                             : %Size(DataRead))
     C                   Dow       BytesRead > 0
     C                   Eval      Data = %Subst(DataRead:1:BytesRead)
     C                   Eval      BytesWrt = write(FileDesc
     C                             : %Addr(Data)
     C                             : %Len(%Trimr(Data)))
     C                   Eval      BytesRead = read(AttachDesc
     C                             : %Addr(DataRead)
     C                             : %Size(DataRead))
     C                   Enddo
     C** Close attachment and write to MIME file
     C                   Eval      ReturnInt = close(AttachDesc)
     C                   If        Z >= NbrFiles
     C                   Eval      Data = EOR + '--' + %Trimr(MBoundary) +
     C                                    '--' + EOR + EOR
     C                   Else
     C                   Eval      Data = EOR + '--' + %Trimr(MBoundary)
     C                   Endif
     C                   Exsr      WriteFile
     C                   Enddo
     C                   Else
     C** Write end of MIME file for e-mail w/ no attachment
     C                   Eval      Data = %Trimr(Data) + '--' + EOR + EOR
     C**                 Eval      Data = %Trimr(Data) +
     C**                                  EOR + '--' + %Trimr(MBoundary) +
     C**                                  '--' + EOR + EOR
     C                   Exsr      WriteFile
     C                   Endif
     C** Close file
     C                   Eval      ReturnInt = close(FileDesc)
     C***
     C                   Endsr
     C*************************************************************************************
     C* Write file
     C*************************************************************************************
     CSR   WriteFile     Begsr
     C*** Write to file
     C                   Eval       BytesWrt = write(FileDesc
     C                              : %Addr(Data)
     C                              : %Len(%Trimr(Data)))
     C***
     C                   Endsr
