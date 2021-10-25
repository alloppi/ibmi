      *****************************************************************
      * Program description
      *
      * This program will send a MIME e-mail, with optional attachments.
      *
      * To create this program, issue the following:
      *  CRTRPGMOD lib/SNDEMAILR SRCFILE(srclib/srcfile)
      *  CRTPGM lib/SNDEMAILR MODULE(lib/SNDEMAILR) BNDSRVPGM(QTCP/QTMMSNDM)
      *
      *  November 2003
      *  Author: Vengoal Chang
      *****************************************************************
     H Debug(*Yes) BndDir('QC2LE')
     H Option(*SrcStmt:*NoDebugIO)

      * IFS Prototype
      *-- GetErrNo ---- Get error number ----------------------------------
      *   extern int * __errno(void);
     D @__errno        pr              *   extproc('__errno')

      *-- StrError ---- Get error text ------------------------------------
      *   char *strerror(int errnum);
     D strerror        pr              *   extproc('strerror')
     D    errnum                     10I 0 value

     D perror          pr                  extproc('perror')
     D    comment                      *   value options(*string)

     D errno           pr            10I 0

     D die             pr
     D   peMsg                      256A   const

     D err             S             10I 0

     D*** open an IFS file
     D open            pr            10I 0 extproc('open')
     D   filename                      *   value options(*string)
     D   openflags                   10I 0 value
     D   mode                        10U 0 value options(*nopass)
     D   codepage                    10U 0 value options(*nopass)

     D*** read an IFS file
     D read            pr            10I 0 extproc('read')
     D   filehandle                  10I 0 value
     D   datareceived                  *   value
     D   nbytes                      10U 0 value

     D*** write to an IFS file
     D write           pr            10I 0 extproc('write')
     D   filehandle                  10I 0 value
     D   datatowrite                   *   value
     D   nbytes                      10U 0 value

     D*** close an IFS file
     D close           pr            10I 0 extproc('close')
     D   filehandle                  10I 0 value

      * stat()--Get File Information ...........................................
     D stat            pr            10I 0 extproc('stat')
     D   path                          *   value
     D   buf                           *   value
      *
     D encodeMailAddr  pr            10I 0
     D   mail_addr                  256    value
     D   mail_desc                   50    value
     D   outstr                    9999

     D to950           pr            10I 0
     D   ebcdic                    9999    value
     D   c950                      9999

     D smtphead        pr            10I 0
     D   instr                     9999    value
     D   outstr                    9999

     D Bencode         pr             3P 0
     D   ascii                      256    value
     D   buflen                       3P 0 value
     D   newbuf                     256

     D base64e         pr             4
     D   inchr                        3    value

     D translate       pr                  extpgm('QDCXLATE')
     D   length                       5P 0 const
     D   data                     32766A   options(*varsize)
     D   table                       10A   const

      * Program status structure
     D PsDs           SDS
     D  PsProc           *PROC
     D  PsSts            *STATUS
     D  PsSrcLineNo           21     28
     D  PsExcpType            40     42
     D  PsExcpNum             43     46
     D  PsMsgId               40     46
     D  PsPgmLib              81     90
     D  PsLstFileErr         175    184
     D  PsJobName            244    253
     D  PsUsrId              254    263
     D  PsJobNum             270    275
     D  PsPgmName            334    343
     D  PsModName            344    353

     D*****************************************************************
     D* IFS CONSTANTS
     D*****************************************************************
     D*** File Access Modes for open()
     D O_RDONLY        S             10I 0 inz(1)
     D O_WRONLY        S             10I 0 inz(2)
     D O_RDWR          S             10I 0 inz(4)

     D*** oflag values for open()
     D O_CREAT         S             10I 0 inz(8)
     D O_EXCL          S             10I 0 inz(16)
     D O_TRUNC         S             10I 0 inz(64)

     D*** File Status Flags for open() and fcntl()
     D O_NONBLOCK      S             10I 0 inz(128)
     D O_APPEND        S             10I 0 inz(256)

     D*** oflag Share Mode values for open()
     D O_SHARE_NONE    S             10I 0 inz(2000000)
     D O_SHARE_RDONLY  S             10I 0 inz(0200000)
     D O_SHARE_RDWR    S             10I 0 inz(1000000)
     D O_SHARE_WRONLY  S             10I 0 inz(0400000)

     D*** file permissions
     D S_IRUSR         S             10I 0 inz(256)
     D S_IWUSR         S             10I 0 inz(128)
     D S_IXUSR         S             10I 0 inz(64)
     D S_IRWXU         S             10I 0 inz(448)
     D S_IRGRP         S             10I 0 inz(32)
     D S_IWGRP         S             10I 0 inz(16)
     D S_IXGRP         S             10I 0 inz(8)
     D S_IRWXG         S             10I 0 inz(56)
     D S_IROTH         S             10I 0 inz(4)
     D S_IWOTH         S             10I 0 inz(2)
     D S_IXOTH         S             10I 0 inz(1)
     D S_IRWXO         S             10I 0 inz(7)

     D*** misc
     D O_TEXTDATA      S             10I 0 inz(16777216)
     D O_CODEPAGE      S             10I 0 inz(8388608)
     D O_CCSID         C                        32

     D NULL            C                   Const(X'00')

     D*****************************************************************
     D* DATA DEFINITIONS
     D*****************************************************************
     D*** Miscellaneous data declarations
     D FileName        S            255A
     D FileLen         S              9B 0
     D Originator      S            255A
     D OriginName      S             80A
     D OriginLen       S              9B 0
     D CPFNumber       S                   like(MSGID)
     D Subject         S            256A
     D Message         S            512A
     D AttachName      S            256A
     D*AsciiCodePage   S             10U 0 inz(819)
     D AsciiCodePage   S             10U 0 inz(950)
     D EbcdicCodePage  S             10U 0 inz(937)
     D OutAddrArr      s            256a   dim(ADDRSIZE)
     D OutDistArr      s             10i 0 dim(ADDRSIZE)
     D ToAddrArr       s            256a   dim(ADDRSIZE)
     D ToNameArr       s             50a   dim(ADDRSIZE)
     D CcAddrArr       s            256a   dim(ADDRSIZE)
     D CcNameArr       s             50a   dim(ADDRSIZE)
     D bCcAddrArr      s            256a   dim(ADDRSIZE)
     D bCcNameArr      s             50a   dim(ADDRSIZE)
     D Importnc        s              4a
     D Priority        s              4a
     D Sensitiv        s              4a
     D Receipt         s              4a
     D TmpDir          s             64a

     D***
     D Addressee       S                   like(Address)
     D AddresseeName   S                   like(Address)
     D Recipients      s            280    dim(ADDRSIZE)
     D TotalRecp       S              9B 0

     D***
     D FileDesc        S             10I 0
     D Flags           S             10I 0
     D BytesWrt        S             10I 0
     D Data            S           9999A
     D Data1           S           9999A
     D Data2           S           9999A
     D InData          S           9999A
     D AttachDesc      S             10I 0
     D bodyDesc        S             10I 0
     D atcfd           S             10I 0
     D BytesRead       S             10I 0
     D DataRead        S           9899A
     D EOR             S              2A   inz(X'0D25')
     D CRLF            S              2    inz(X'0D0A')
     D fullName        S            512A
     D returnInt       S             10I 0
     D Pos             S              5U 0
     D SavePos         S                   like(Pos)

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
     D MReceipt        S            256A
     D MImportnc       S            256A
     D MPriority       S            256A
     D MDateTime       S            256A
     D MFrom           S            256A
     D MMimeVer        S            256A
     D MTo             S           9999A
     D MCc             S           9999A
     D MBcc            S           9999A
     D MSubject        S            256A
     D MBoundary       S            256A   inz('--PART.BOUNDARY.1')

     D*** Array of Receiption address
     D ToReceiptions   DS
     D to                      1   9302
     D  NbrofTo                       5U 0 overlay(to : 1)
     D  to_replacem                   5U 0 overlay(to : 3) dim(30)

     D CcReceiptions   DS
     D cc                      1   9302
     D  Nbrofcc                       5U 0 overlay(cc : 1)
     D  cc_replacem                   5U 0 overlay(cc : 3) dim(30)

     D BccReceiptions  DS
     D bcc                     1   9302
     D  Nbrofbcc                      5U 0 overlay(bcc : 1)
     D  bcc_replacem                  5U 0 overlay(bcc : 3) dim(30)

     D RcptNA          DS           306
     D  RcptName                     50    overlay(RcptNA : 1)
     D  RcptAddr                    256    overlay(RcptNA : 51)

     D TxtF            DS
     D  TxtFile                      10a
     D  TxtFLib                      10a
     D  TxtFMbr        s             10a

     D*** Array of file attachments
     D Attachment      DS
     D  NbrFiles               1      2B 0
     D  AttachFile                  256A   dim(30)

     D*** API error info
     D APIError        DS
     D  BytesProvided                10I 0 inz( %Size( APIError ) )
     D  BytesAvail                   10I 0 inz( *Zero )
     D  MsgID                         7    inz( *Blanks )
     D                                1    inz( X'00' )
     D  msgDta                      256    inz( *Blanks )

     D*** Constants
     D AtS             C                   Const(X'7C')
     D DTo             C                   Const(0)
     D DCC             C                   Const(1)
     D DBCC            C                   Const(2)
     D MsgSize         C                   Const(%Len(Message))
     D ADDRSIZE        C                   Const(100)

      *=============================================
      * MISCELLANEOUS
     D eMailAddr       s            255a
     D r               s             10i 0
     D outstr          s           9999a
      * string character set
     D charset         S             16    inz('Big5')
      * current time for temp file name (store mail message)
     D curtime         S               Z
      * last folding position in encoded string
     D fold            S              3P 0
      *
      * SBCS character tables *****************************************
      *
      * US-ASCII (ANSI X3.4-1986) characters (95)
     D a_c             S             95
     D a_x             C                   X'202122232425262728292A2B2C2D2E2F-
      *                                      sp ! " # $ % & ' ( ) * + , - . /
     D                                     303132333435363738393A3B3C3D3E3F-
      *                                     0 1 2 3 4 5 6 7 8 9 : ; < = > ?
     D                                     404142434445464748494A4B4C4D4E4F-
      *                                     @ A B C D E F G H I J K L M N O
     D                                     505152535455565758595A5B5C5D5E5F-
      *                                     P Q R S T U V W X Y Z [ \ ] ^ _
     D                                     606162636465666768696A6B6C6D6E6F-
      *                                     ` a b c d e f g h i j k l m n o
     D                                     707172737475767778797A7B7C7D7E'
      *                                     p q r s t u v w x y z { | } ?
      *
      * 'safe' ASCII chars other than especials[RFC2047 p3] and
      *       quoted chars for EBCDIC gateway [RFC2045 p20])  (69)
      * (These characters are also invariant EBCDIC characters)
     D a_s_c           C                   ' %&''*+-0123456789-
     D                                     ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     abcdefghijklmnopqrstuvwxyz'
      *
     D a_s_x           C                   X'202526272A2B2D30313233343536373839-
      *                                      sp % & ' * + - 0 1 2 3 4 5 6 7 8 9
     D                                     4142434445464748494A4B4C4D-
      *                                     A B C D E F G H I J K L M
     D                                     4E4F505152535455565758595A-
      *                                     N O P Q R S T U V W X Y Z
     D                                     6162636465666768696A6B6C6D-
      *                                     a b c d e f g h i j k l m
     D                                     6E6F707172737475767778797A'
      *                                     n o p q r s t u v w x y z
     D a_c_c           S             98
     D a_c_x           S             98
      * ISO-2022-JP escape sequences
     D G0ascii         C                   X'1B2842'
     D G0roman         C                   X'1B284A'
     D G0kana          C                   X'1B2849'
     D G0k78           C                   X'1B2440'
     D G0k83           C                   X'1B2442'
      * especial characters (RFC2047 section 2)
     D especials       C                   X'28293C3E402C3B3A222F5B5D3F2E3D'
      *                                       ( ) < > @ , ; : " / [ ] ? . =
      *****************************************************************
      * base64 encode (attachment file) ........................................
     D b64chrDS        DS
     D  b64i                   1      3
     D  b64i1                  1      1
     D  b64i2                  2      2
     D  b64i3                  3      3
     D b64apDS         DS
     D  b64ap                  1      8
     D  b64ap1                 1      2U 0
     D  b64ap1L                2      2
     D  b64ap2                 3      4U 0
     D  b64ap2L                4      4
     D  b64ap3                 5      6U 0
     D  b64ap3L                6      6
     D  b64ap4                 7      8U 0
     D  b64ap4L                8      8
      *
     D b64a            C                   X'4142434445464748494A4B4C4D4E4F-
      *                                      A B C D E F G H I J K L M N O
     D                                     505152535455565758595A-
      *                                    P Q R S T U V W X Y Z
     D                                     6162636465666768696A6B6C6D6E6F-
      *                                    a b c d e f g h i j k l m n o
     D                                     707172737475767778797A-
      *                                    p q r s t u v w x y z
     D                                     303132333435363738392B2F'
      *                                    0 1 2 3 4 5 6 7 8 9 + /
      *****************************************************************
      * Loop control
     D i               S              9P 0
     D j               S              9P 0
     D k               S              9P 0
      * write buffer for tmpf
     D tmpfwb          S            512
     D tmpfwbb64       S           3900
     D tmpfwblen       S             10I 0
      * total size of tmpf
     D tmpf_size       S             10I 0
      * read buffer for attachment file
     D atcfrb          S           2850
     D atcfrblen       S             10I 0
      *****************************************************************
      * attachment size array
     D atc_st_size     S                   like(st_size) dim(30)
      * structure stat ........................................ QSYSINC/SYS.STAT
     D statinfo        DS
      * Data types in () are defined at QSYSINC/SYS.TYPES
      * File mode (typedef unsigned int   mode_t;)
     D st_mode                       10U 0
      * File serial number (typedef unsigned int   ino_t;)
     D st_ino                        10U 0
      * Number of links (typedef unsigned short nlink_t;)
     D*st_nlink                       5U 0
     D st_nlink                      10U 0
      * User ID of the owner of file (typedef unsigned int   uid_t;)
     D st_uid                        10U 0
      * Group ID of the group of file (typedef unsigned int   gid_t;)
     D st_gid                        10U 0
      * For regular files, the file size in bytes (typedef int  off_t;)
     D st_size                       10I 0
      * Time of last access (typedef long int time_t;)
     D st_atime                      10I 0
      * Time of last data modification typedef (long int time_t;)
     D st_mtime                      10I 0
      * Time of last file status change (typedef long int time_t;)
     D st_ctime                      10I 0
      * ID of device containing file (typedef unsigned int   dev_t;)
     D st_dev                        10U 0
      * Size of a block of the file (typedef unsigned int   size_t;)
     D st_blksize                    10U 0
      * Allocation size of the file    unsigned long
     D st_allocsize                  10U 0
      * AS/400 object type (typedef char qp0l_objtype_t[11];)
     D st_objtype                    11
      * Object data codepage           unsigned short
     D st_codepage                    5U 0
      * reserved - must be 0x00's      char[62]
     D st_reserved1                  62    inz(*ALLX'00')
      * File serial number generation id  unsigned int
     D st_ino_gen_id                 10U 0
      *
     C*****************************************************************
     C* MAIN LINE CALCULATIONS
     C*****************************************************************
     C*** Entry Parms
     C     *Entry        PList
     C                   Parm                    Originator
     C                   Parm                    ToReceiptions
     C                   Parm                    OriginName
     C                   Parm                    CcReceiptions
     C                   Parm                    BCcReceiptions
     C                   Parm                    Attachment
     C                   Parm                    Subject
     C                   Parm                    Message
     C                   Parm                    TxtF
     C                   Parm                    TxtFMbr
     C                   Parm                    Importnc
     C                   Parm                    Priority
     C                   Parm                    Receipt
     C                   Parm                    TmpDir

     C                   ExSr      #Init
      *  check sender
     C                   Eval      eMailAddr = Originator
     C                   ExSr      ChkEmail
      *  check receiption
     C                   ExSr      ChkRcpt
     C*** Initialize error structure
     C                   Eval      BytesProvided  = 0
     C*** Initialize values
     C                   Eval      OriginLen = %Len(%trimr(Originator))
     C                   Eval      Format     = 'ADDR0100'
     C                   Eval      Reserved   = 0
      * Fill in the "Recipients" array
     C     1             Do        ADDRSIZE      z
     C                   If        OutAddrArr(z) = *Blank
     C                   Leave
     C                   EndIf
     C                   Eval      Address = OutAddrArr(z)
      * Check recipient's e-mail
     C                   Eval      eMailAddr = Address
     C                   ExSr      ChkEMail
     C                   Eval      AddrLen = %len(%trimr(Address))
     C                   Eval      DistrType = OutDistArr(z)
     C                   If        OutAddrArr(z+1) <> *Blank
     C                   Eval      OffSet = 280
     C                   Else
     C                   Eval      OffSet = 0
     C                   EndIf
     C                   Eval      Recipients(z) = recipient
     C                   EndDo
      * Total number of recipients
     C                   Eval      TotalRecp  = z -1
     C*** Write MIME file
     C                   ExSr      WriteHdr
     C*** Call API to send e-mail
     C                   CallB     'QtmmSendMail'
     C                   Parm                    FileName
     C                   Parm                    FileLen
     C                   Parm                    Originator
     C                   Parm                    OriginLen
     C                   Parm                    Recipients
     C                   Parm                    TotalRecp
     C                   Parm                    APIError
     C                   If        MsgID <> *Blank
     C     MSGID         dsply
     C                   dump
     C                   EndIf
     C*** Return to caller
     C     Exit          Tag
     C                   Eval      *InLr = *On
     C                   Return
      *****************************************************************
      * Initialize routine
     C     #Init         BegSr
      *
      *     US ASCII character set
      *       X'A2' = Cent sign, X'A3' = Pound sign, X'A5' = Yen sign
     C                   Move      *BLANKS       a_c_256         256
     C*                  Eval      rc = iconvw(a_x + X'A2A3A5' + NULL : a_c_256)
     C                   Eval      a_c_256 = a_x + X'A2A3A5' + NULL
     c                   CallP     Translate(%len(%trim(a_c_256)):
     c                                       a_c_256 : 'QTCPEBC')
      *     print EBCDIC internal table
     C                   MoveL     a_c_256       a_c_c
     C                   MoveL     a_c_c         a_c
     C                   Eval      a_c_x = a_x + X'0D0A' + X'1B'
      * check body text file
     C                   If        %trim(txtFile) <> '*NONE'
     C                   Eval      fullName = '/QSYS.LIB/' +
     C                             %trim(TxtFLib) + '.LIB/' +
     C                             %trim(TxtFile) + '.FILE/' +
     C                             %trim(TxtFmbr) + '.MBR' + NULL
     C                   Eval      bodyDesc = open(%trimr(fullName) : O_RDONLY)
     C
     C                   If        bodyDesc < 0
     c                   Eval      err = errno
     c                   CallP     die(%str(strerror(err)) + ' ' + fullName)
     C                   Return
     C                   Else
     C                   Eval      returnInt = close(bodyDesc)
     C                   EndIf
     C                   EndIf
      *  check attachement
     C                   If        Nbrfiles > *ZERO and AttachFile(1) <> '*NONE'
     C                   Do        NbrFiles      i
     C                   Eval      fullName = %trim(AttachFile(i)) + NULL
     C                   If        -1 = stat(%addr(fullName) : %addr(statinfo))
     c                   Eval      err = errno
     c                   CallP     die(%str(strerror(err)) + ' ' + fullName)
     C                   Return
     C                   EndIf
      *   store st_size to array
     C                   Eval      atc_st_size(i) = st_size
      *   path must be stream file or doc
     C                   If        (%subst(st_objtype : 1 : 10)  <> '*STMF') AND
     C                             (%subst(st_objtype : 1 : 10)  <> '*DOC')  AND
     C                             (%subst(st_objtype : 1 : 10)  <> '*DSTMF')
     C                   CallP     die(%trim(AttachFile(i)) + ' ' +
     C                                'not a STMF or DOC type.')
     C                   Return
     C                   EndIf
      *   file size is 0
     C                   If        st_size = 0
     C                   CallP     die(%trim(AttachFile(i)) + ' ' +
     C                                'has no content.')
     C                   Return
     C                   EndIf
     C                   EndDo
     C                   EndIf
      *
     C                   EndSr
     C*****************************************************************
     C* Write header portion of file
     C*****************************************************************
     CSR   WriteHdr      BegSr
     C*** Open file
      * open work file to write mail message
     C                   TIME                    curtime
     C                   Move      curtime       curtimec         26
     C                   Eval      FileName = %trim(TmpDir) + '/SNDEMAIL_' +
     C                                    %trim(PsJobNum) + '-' +
     C                                    %trim(PsUsrid) + '-' +
     C                                    %trim(PsJobName) + '_' +
     C                                    %subst(curtimec : 1 : 23) + '.TXT'
     C                   Eval      FileLen = %Len(%trimr(FileName))
     C                   Eval      fullName = %trimR(FileName)
     C                   Eval      Flags = O_CREAT + O_WRONLY + O_TRUNC +
     C                                     O_CCSID
     C                   Eval      FileDesc = open(%trimr(fullName)
     C                               : Flags
     C                               : S_IRWXU + S_IROTH
     C                               : AsciiCodePage)
     C                   Move      *BLANKS       tmpstr           45
     C                   Eval      returnInt = close(FileDesc)
     C                   Eval      FileDesc = open(%trimr(fullName)
     C                               :  O_RDWR + O_CCSID
     C                               : S_IRWXU + S_IROTH
     C                               : AsciiCodePage)
     C*                  Eval      err = errno
     C*                  Eval      tmpstr = %str(strerror(err))
     C*                  dsply                   tmpstr
     C*    'open0'       dsply                   FileDesc
     C*** Build MIME header fields
     C                   If        OriginName <> *Blank
     C****               Eval      rtnlen = smtphead(OriginName : outstr)
     C****               Eval      MSender =
     C****                         'Sender: "' +
     C****                         %subst(outstr : 1 : rtnlen) +
     C****                         '"' + Originator
     C                   Eval      rtnlen = encodeMailAddr(
     C                               Originator : OriginName : outstr)
     C                   Eval      MSender =
     C                               'Sender:' + %subst(outstr : 1 : rtnlen)
     C                   Else
     C                   Eval      MSender =
     C                               'Sender: ' + Originator
     C                   EndIf
     C                   Eval      MDateTime =
     C                               'Date: '
     C                   Eval      rtnlen = encodeMailAddr
     C                               (Originator : OriginName : outstr)
     C                   Eval      MFrom =
     C                               'From: ' + %subst(outstr : 1 : rtnlen)
     C                   Eval      MMimeVer =
     C                               'MIME-Version: 1.0'
      * Create Mto, Mcc, Mbcc mail string
     C                   ExSr      Crtdistr

     C                   If        Subject <> *Blanks
     C                   Eval      InData = Subject
     C                   CallP     smtphead(InData : outstr)
     C                   Eval      MSubject =
     C                             'Subject: ' + %trim(outstr)
     C                   Else
     C                   Eval      MSubject =
     C                             'Subject: '
     C                   EndIf
     C
     C                   If        Message <> *Blanks
     C                   Eval      InData = Message
     C                   Eval      outstr = *blanks
     C                   CallP     to950(InData : outstr)
     C                   Eval      Message = outstr
     C                   EndIf
      * Add receipt notification, if requested so
     C                   If        Receipt = '*YES'
     C                   Eval      MReceipt =
     C                               'Disposition-Notification-To: ' +
     C                               %trim(Msender) + EOR
     C                   EndIf
      *  Add the Importance header
     C                   ExSr      SetImpo
      *  Add the Priority header
     C                   ExSr      SetPrio

     C                   Eval      Data1 = %trimr(MSender) + EOR +
     C                             %trimr(MDateTime) + EOR +
     C                             %trimr(MFrom) + EOR +
     C                             %trimr(MMimeVer) + EOR +
     C                             %trimr(MTo) + EOR +
     C                             %trim(MCc) + EOR +
     C                             %trim(MBCc) + EOR +
     C                             %trimr(MReceipt) + EOR +
     C                             %trimr(MSubject) + EOR +
     C                             %trimr(MImportnc) + EOR +
     C                             %trimr(MPriority) + EOR +
     C                             'Content-Type: multipart/mixed; boundary=' +
     C                             '"' + %trimr(MBoundary) + '"' + EOR + EOR +
     C                             'This is a multi-part message in MIME ' +
     C                             'format.' + EOR + EOR +
     C                             '--' + %trimr(MBoundary) + EOR +
     C*                            'Content-Type: text/plain; charset=us-ascii'+
     C                             'Content-Type: text/plain; charset='+
     C                             %trim(charset) + EOR +
     C                             'Content-Transfer-Encoding: 7bit' + EOR + EOR
     C                   Eval      Data2 =
     C*                            %trimr(Message) +
     C                             EOR + EOR + EOR + EOR +
     C                             '--' + %trimr(MBoundary)
     C*** Add attachment file(s) if requested
     C                   If        NbrFiles > *Zero
     C                             and AttachFile(1) <> '*NONE'
     C                   ExSr      WriteHead
     C                   Do        NbrFiles      Z                 4 0
     C                   Clear                   SavePos
     C                   Eval      Pos = %Scan('/':AttachFile(Z):1)
     C                   Dow       Pos > *Zero
     C                   Eval      SavePos = Pos
     C                   Eval      Pos = %Scan('/':AttachFile(Z):Pos+1)
     C                   EndDo
     C                   If        SavePos <> *Zero
     C                   Eval      AttachName = %subst(AttachFile(Z):SavePos+1)
     C                   Else
     C                   Eval      AttachName = AttachFile(Z)
     C                   EndIf
     C                   Eval      Data = EOR +
     C                             'Content-Type: application/octet' +
     C                             '-stream; name="' +
     C                             %trimr(AttachName) + '"' +
     C                             EOR +
     C*                            'Content-Disposition: inline; filename="' +
     C                             'Content-Disposition: attachment;' +
     C                             ' filename="' +
     C                             %trimr(AttachName) + '"' +
     C                             EOR +
     C*                            'Content-Transfer-Encoding: 7bit' +
     C                             'Content-Transfer-Encoding: base64' +
     C                             EOR + EOR
     C* Write attached file heading
     C                   ExSr      WriteAttachHd
     C*** Open file and write to MIME file
     C                   Eval      fullName = %trimR(AttachFile(Z)) + NULL
     C                   ExSr      #WATC
     C                   If        Z >= NbrFiles
     C                   Eval      Data = EOR +
     C                             '--' + %trimr(MBoundary) + '--' +
     C                             EOR + EOR
     C                   Else
     C                   Eval      Data = EOR +
     C                             '--' + %trimr(MBoundary)
     C                   EndIf
     C                   ExSr      WriteAttachHd
     C                   EndDo
     C                   Else
     C*** Write end of MIME file for e-mail w/ no attachment
     C                   ExSr      WriteHead
     C                   EndIf
     C*** Close file
     C                   Eval      returnInt = close(FileDesc)
     C***
     C                   EndSr
     C*****************************************************************
     C* Check Receiption Addr
     C*****************************************************************
     CSR   ChkRcpt       BegSr
     C*** Add receiption to arrary
     C                   z-add     1             x
     C                   If        Nbrofto  > *Zero
     C                   Z-add     1             Z
     C                   Do        Nbrofto       Z
     C                   Eval      RcptNA    =
     C                             %subst(to : to_replacem(Z) +  3 : 306)
     c                   Eval      eMailAddr = RcptAddr
     C                   ExSr      ChkEmail
     c                   Eval      ToAddrArr(z) = RcptAddr
     C                   Eval      ToNameArr(z) = RcptName
     c                   Eval      OutAddrArr(x) = RcptAddr
     c                   Eval      OutDistArr(x) = DTO
     C                   Eval      x = x + 1
     C                   EndDo
     C                   EndIf
     C                   If        Nbrofcc  > *Zero
     C                   Z-add     1             Z
     C                   Do        Nbrofcc       Z
     C                   Eval      RcptNA    =
     C                             %subst(cc : cc_replacem(Z) +  3 : 306)
     c                   Eval      eMailAddr = RcptAddr
     C                   ExSr      ChkEmail
     c                   Eval      CcAddrArr(z) = RcptAddr
     C                   Eval      CcNameArr(z) = RcptName
     c                   Eval      OutAddrArr(x) = RcptAddr
     c                   Eval      OutDistArr(x) = DCC
     C                   Eval      x = x + 1
     C                   EndDo
     C                   EndIf
     C                   If        Nbrofbcc > *Zero
     C                   Z-add     1             Z
     C                   Do        Nbrofbcc      Z
     C                   Eval      RcptNA    =
     C                             %subst(bcc : bcc_replacem(Z) +  3 : 306)
     c                   Eval      eMailAddr = RcptAddr
     C                   ExSr      ChkEmail
     c                   Eval      BCcAddrArr(z) = RcptAddr
     C                   Eval      BCcNameArr(z) = RcptName
     c                   Eval      OutAddrArr(x) = RcptAddr
     c                   Eval      OutDistArr(x) = DBCC
     C                   Eval      x = x + 1
     C                   EndDo
     C                   EndIf
     CSR                 EndSr
     C*****************************************************************
     C* Create Distribution
     C*****************************************************************
     CSR   CrtDistr      BegSr
      * Process the "To"-s
     C                   z-add     0             NumberOf          4 0
     C                   z-add     0             x                 4 0
     C     1             Do        ADDRSIZE      x
     C                   If        ToNameArr(x) = *Blank
     C                   Leave
     C                   EndIf
     C                   Eval      NumberOf = NumberOf +1
     C                   Z-add     0             rtnlen           10 0
     C                   Eval      rtnlen =
     C                             encodeMailAddr(ToAddrArr(x):
     C                                            ToNameArr(x): outstr)
     C                   If        NumberOf = 1
     C                   Eval      MTo = 'To:  ' + %subst(outstr:1 : rtnlen)
     C                   Else
     C                   Eval      MTo = %trimr(Mto) +
     C                                   ' ,' + %subst(outstr:1 : rtnlen)
     C                   EndIf
     C                   EndDo
      * Process the "Cc"-s
     C                   z-add     0             NumberOf          4 0
     C                   z-add     0             x                 4 0
     C     1             Do        ADDRSIZE      x
     C                   If        CcNameArr(x) = *Blank
     C                   Leave
     C                   EndIf
     C                   Eval      NumberOf = NumberOf +1
     C                   Z-add     0             rtnlen           10 0
     C                   Eval      rtnlen =
     C                             encodeMailAddr(CcAddrArr(x):
     C                                            CcNameArr(x): outstr)
     C                   If        NumberOf = 1
     C                   Eval      MCc = 'cc:  ' + %subst(outstr:1 : rtnlen)
     C                   Else
     C                   Eval      MCc = %trimr(MCc) +
     C                                   ' ,' + %subst(outstr:1 : rtnlen)
     C                   EndIf
     C                   EndDo
      * Process the "BCc"-s
     C                   z-add     0             NumberOf          4 0
     C                   z-add     0             x                 4 0
     C     1             Do        ADDRSIZE      x
     C                   If        BCcNameArr(x) = *Blank
     C                   Leave
     C                   EndIf
     C                   Eval      NumberOf = NumberOf +1
     C                   Z-add     0             rtnlen           10 0
     C                   Eval      rtnlen =
     C                             encodeMailAddr(BCcAddrArr(x):
     C                                            BCcNameArr(x): outstr)
     C                   If        NumberOf = 1
     C                   Eval      MBCc= 'bcc: '+ %subst(outstr:1 : rtnlen)
     C                   Else
     C                   Eval      MBCc = %trimr(MBCc) +
     C                                   ' ,' + %subst(outstr:1 : rtnlen)
     C                   EndIf
     C                   EndDo

     C                   If        %len(%trim(MCc)) > 0
     C                   Eval      MTo  = %trim(MTo) + EOR
     C                   EndIf
     C                   If        %len(%trim(MBCc)) > 0
     C                   Eval      MCc  = %trim(MCc) + EOR
     C                   EndIf
     CSR                 EndSr
      *=====================================================================
      * Set importance
      *=====================================================================
     C     SetImpo       BegSr
     C                   Eval      MImportnc = *Blanks
     C                   select
     C                   when      Importnc = '*LOW'
     C                   Eval      MImportnc = 'Importance: low'
     C                   when      Importnc = '*MED'
     C                   Eval      MImportnc = 'Importance: medium'
     C                   when      Importnc = '*HIG'
     C                   Eval      MImportnc = 'Importance: high'
     C                   endsl
     C                   EndSr
      *=====================================================================
      * Set priority
      *=====================================================================
     C     SetPrio       BegSr
     C                   Eval      MPriority = *blanks
     C                   select
     C                   when      Priority = '*NUR'
     C                   Eval      MPriority = 'Priority: non-urgent'
     C                   when      Priority = '*NRM'
     C                   Eval      MPriority = 'Priority: normal'
     C                   when      Priority = '*URG'
     C                   Eval      MPriority = 'Priority: urgent'
     C                   endsl
     C                   EndSr
      *****************************************************************
      * write message text to temp file
     C     #WBODY        BegSr
      *
     C                   Eval      fullName = '/QSYS.LIB/' +
     C                             %trim(TxtFLib) + '.LIB/' +
     C                             %trim(TxtFile) + '.FILE/' +
     C                             %trim(TxtFmbr) + '.MBR' + NULL
     C
     C                   Eval      bodyDesc   = open(%trimr(fullName)
     C                               : O_RDONLY)
     C                   If        bodyDesc < 0
     c                   Eval      err = errno
     c                   CallP     die(%str(strerror(err)) + ' ' + fullName)
     C                   Return
     C                   EndIf
     C* append CRLF to Message after
     C                   If        %len(%trim(Message)) > 0
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(CRLF)
     C                               : 2)
     C                   EndIf
     C*** Read from file and write to MIME file
     C                   Eval      BytesRead = read(bodyDesc
     C                               : %addr(DataRead)
     C                               : 100)
     C                   Dow       BytesRead > 0
     C                   Eval      InData = %subst(DataRead:1:BytesRead) +
     C                                      EOR
     C                   Eval      outstr = *blanks
     C                   Eval      rtnlen = to950(InData : outstr)
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(outstr)
     C                               : rtnlen)
     C                   Eval      BytesRead = read(bodyDesc
     C                               : %addr(DataRead)
     C                               : 100)
     C                   EndDo
     C                   Eval      returnInt = close(bodyDesc)
      *
     C                   EndSr
     C*****************************************************************
     C* Write head
     C*****************************************************************
     CSR   WriteHead     BegSr
     C* conver ebcdic to ascii
     C                   Move      *Blanks       DataEnd           6
     C                   Eval      DataEnd = '--' + EOR + EOR
     C                   Z-add     0             Data1Len          5 0
     C                   Z-add     0             Data2Len          5 0
     C                   Eval      Data1len = %len(%trimr(Data1))
     C                   Eval      Data2len = %len(%trimr(Data2))
     C*                  Eval      %subst(Data2 : Data2Len+1 : 6) =
     C*                            DataEnd
     C*                  Eval      Data2len = Data2len + 6
     C     a_c:a_x       XLATE     Data1         Data1
     C     EOR:CRLF      XLATE     Data1         Data1
     C     a_c:a_x       XLATE     Data2         Data2
     C     EOR:CRLF      XLATE     Data2         Data2
     C     a_c:a_x       XLATE     DataEnd       DataEnd
     C     EOR:CRLF      XLATE     DataEnd       DataEnd
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(Data1)
     C                               : Data1len)
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(Message)
     C                               : %len(%trim(Message)))
     C                   If        %trim(TxtFile) <> '*NONE'
     C                   ExSr      #WBODY
     C                   EndIf
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(Data2)
     C                               : Data2len)
     C                   If        NbrFiles > *Zero
     C                             and AttachFile(1) = '*NONE'
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(DataEnd)
     C                               : %len(%trim(DataEnd)))
     C                   EndIf
     C*                  ExSr      WriteFile
     CSR                 EndSr
     C*****************************************************************
     C* Write Attach head
     C*****************************************************************
     CSR   WriteattachHd BegSr
     C                   Z-add     0             Data1Len
     C                   Eval      Data1len = %len(%trimr(Data))
     C     a_c:a_x       XLATE     Data          Data
     C     EOR:CRLF      XLATE     Data          Data
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(Data)
     C                               : Data1Len)
     CSR                 EndSr
     C*****************************************************************
     CSR   WriteFile     BegSr
     C*** Write to file
     C                   Eval      BytesWrt = write(FileDesc
     C                               : %addr(Data)
     C                               : %LEN(%trimR(Data)))
     C***
     C                   EndSr
      *===========================
      * If at sign not found in e-mail address, generate an escape message
     C*****************************************************************
     C     ChkEMail      BegSr
     C                   Eval      r = %scan(AtS:eMailAddr)
     C                   If        r = 0
     C                   Eval      msgDta = '"' + AtS + '" not found in"' +
     C                             %trim(eMailAddr) + '".'
     c                   CallP     die(msgDta)
     C                   Return
     C                   EndIf
     C                   EndSr
      *****************************************************************
      * encode attachment file and write to temp file
      *****************************************************************
     C     #WATC         BegSr
      * open attachment file
     C                   Eval      atcfd = open(%addr(fullName) : 1)
      *
     C                   Z-ADD     0             rtotal            9 0
  |  C                   Z-ADD     0             inscrlf           3 0
      * read 2850 byte -> base64 -> write 3900 byte
      *   2850 byte (before encode) = 57(chars/line) * 50(line)
      *   57 -base64encode-> * 4/3 + CRLF = 78byte
      *   78 * 50 = 3900 byte (after encode)
      *
      * read stream file
     C                   Do        atc_st_size(Z)J
     C                   Eval      atcfrblen = read(atcfd : %addr(atcfrb) :
     C                                                                   2850)
     C                   If        atcfrblen = -1
     C                   EndIf
      * end of file
     C                   If        atcfrblen = 0
     C                   Leave
     C                   EndIf
     C                   Z-ADD     atcfrblen     b64instrlen       9 0
      * accumulate read bytes
     C                   ADD       atcfrblen     rtotal
      * adjust to miltiply of 3 if less than 2850 bytes read
     C                   If        atcfrblen < 2850
      *   don't use %DIV/%REM for V4R2 or earlier version
     C     atcfrblen     DIV       3             b64count          9 0
     C                   MVR                     b64mod            1 0
     C     3             SUB       b64mod        b64pad            1 0
     C                   If        b64mod > 0
     C                   Eval      %subst(atcfrb : atcfrblen + 1 : b64pad)
     C                                                                = X'0000'
     C                   ADD       b64pad        b64instrlen
     C                   EndIf
     C                   EndIf
      * Base64 encode. should be faster than procedure call...
     C                   Z-ADD     1             tmpfwblen
     C                   Do        b64instrlen   K
     C                   Eval      b64i = %subst(atcfrb : K : 3)
     C                   Move      *ALLX'00'     b64ap
      * 1st byte of outchr
     C                   Move      b64i1         b64ap1L
     C                   DIV       4             b64ap1
      * 2nd
     C                   TESTB     '6'           b64i1                    20
     C   20              BITON     '2'           b64ap2L
     C                   TESTB     '7'           b64i1                    20
     C   20              BITON     '3'           b64ap2L
     C                   TESTB     '0'           b64i2                    20
     C   20              BITON     '4'           b64ap2L
     C                   TESTB     '1'           b64i2                    20
     C   20              BITON     '5'           b64ap2L
     C                   TESTB     '2'           b64i2                    20
     C   20              BITON     '6'           b64ap2L
     C                   TESTB     '3'           b64i2                    20
     C   20              BITON     '7'           b64ap2L
      * 3rd
     C                   TESTB     '4'           b64i2                    20
     C   20              BITON     '2'           b64ap3L
     C                   TESTB     '5'           b64i2                    20
     C   20              BITON     '3'           b64ap3L
     C                   TESTB     '6'           b64i2                    20
     C   20              BITON     '4'           b64ap3L
     C                   TESTB     '7'           b64i2                    20
     C   20              BITON     '5'           b64ap3L
     C                   TESTB     '0'           b64i3                    20
     C   20              BITON     '6'           b64ap3L
     C                   TESTB     '1'           b64i3                    20
     C   20              BITON     '7'           b64ap3L
      * 4th
     C                   BITOFF    '01'          b64i3
     C                   Move      b64i3         b64ap4L
      *
     C                   Eval      %subst(tmpfwbb64 : tmpfwblen : 4) =
     C                                  %subst(b64a : b64ap1 + 1 : 1) +
     C                                  %subst(b64a : b64ap2 + 1 : 1) +
     C                                  %subst(b64a : b64ap3 + 1 : 1) +
     C                                  %subst(b64a : b64ap4 + 1 : 1)
     C                   ADD       4             tmpfwblen
      *   append CRLF in every 19 encodes (57->76byte)
     C                   ADD       1             inscrlf
     C                   If        inscrlf = 19
     C                   Eval      %subst(tmpfwbb64 : tmpfwblen : 2) = CRLF
     C                   ADD       2             tmpfwblen
     C                   Z-ADD     0             inscrlf
     C                   EndIf
     C                   EndDo     3
      *
     C                   Eval      tmpfwblen = tmpfwblen - 1
      * adjust last line
     C                   If        atcfrblen < 2850
      *   reMove appended CRLF
     C                   If        inscrlf = 0
     C                   SUB       2             tmpfwblen
     C                   EndIf
      *   adjust '='
     C                   If        b64mod > 0
     C                   Eval      %subst(tmpfwbb64 : tmpfwblen - b64pad + 1 :
     C                                                b64pad) = X'3D3D'
     C                   EndIf
      *   add CRLF
     C                   Eval      %subst(tmpfwbb64 : tmpfwblen + 1 : 2) = CRLF
     C                   ADD       2             tmpfwblen
     C                   EndIf
      * accumulate total bytes written
     C                   ADD       tmpfwblen     wtotal            9 0
      * write to temp file
     C                   Eval      BytesWrt = write(FileDesc : %addr(tmpfwbb64)
     C                                                            : tmpfwblen)
     C                   If        BytesWrt = -1
     C                   EndIf
      * write operation not complete
     C                   If        BytesWrt <> tmpfwblen
     C                   EndIf
      * accumulate total bytes written to temp file
     C                   Eval      tmpf_size = tmpf_size + BytesWrt
      * no more data to read
     C                   If        atcfrblen < 2850
     C                   Leave
     C                   EndIf
      *
     C                   EndDo     2850
      * close attachment file
     C                   If        -1 = close(atcfd)
     C                   EndIf
      * compare read total with file size
     C                   If        rtotal <> atc_st_size(I)
     C                   EndIf
      *
     C                   EndSr
      *****************************************************************
      * encode mail address and description
      *     return : length of outstr
      *              < 0 return code form procedure 'smtphead'
      *     mtype : 'From:', 'To:', 'cc:', 'bcc:', 'Reply-To:'                I
      *     mail_addr : mail address                                          I
      *     mail_desc : mail address description                              I
      *     outstr : encoded string                                           O
      *
     PencodeMailAddr   B
     DencodeMailAddr   PI            10I 0
     D mail_addr                    256    value
     D mail_desc                     50    value
     D outstr                      9999
      *
     Doutstrlen        S              3P 0
      *
      * mail adderss description is blank
     C                   Eval      outstrlen = smtphead(%trim(mail_desc) :
     C                                                              outstr)
     C                   If        outstrlen < 0
     C                   Return    outstrlen
     C                   EndIf
     C                   Eval      outstr = ' "' +
     C                                  %subst(outstr : 1 : outstrlen) + '"'
     C                   Eval      outstrlen = outstrlen + 3
      *       folding
     C                   If        outstrlen - fold + 8 > 65
     C                   Eval      %subst(outstr : outstrlen + 1 : 2) = CRLF
     C                   Eval      outstrlen = outstrlen + 2
     C                   EndIf
      *     append mail address
     C                   Eval      outstr = %subst(outstr : 1 : outstrlen) +
     C                                      ' <' + %trim(mail_addr) + '>'
     C                   Eval      outstrlen = outstrlen +
     C                                   %LEN(%trim(mail_addr)) + 3
      *
     C                   Return    outstrlen
     PencodeMailAddr   E
      *****************************************************************
      * Generate SMTP mail header
      *     return :  length of outstr
      *               0 nothing to process
      *              -1, -2, -3, -4 return code from other procedures
      *              -5 invalid character set (should not happen though)
      *     instr : input string (EBCDIC)                                    I
      *     outstr : encoded string (EBCDIC)                                 O
      *    (dftjobccsid : CCSID of instr                                    )R
      *    (charset : 'US-ASCII' or 'US-ASCII-NONSAFE' or 'ISO-8859-1'      )M
      *    (     or 'ISO-2022-JP' (Japanese)                                )
      *    (fold : last folding position of encoded string                  )M
      *
     Psmtphead         B
     Dsmtphead         PI            10I 0
     D instr                       9999    value
     D outstr                      9999
      *
     Dinstrlen         S              3P 0
     Dascii            S           9999
     Drc               S              3P 0
      *
     C                   Eval      instrlen = %LEN(%trimR(instr))
     C                   If        instrlen = 0
     C                   Return    0
     C                   EndIf
      * encode string
     C                   SELECT
      *   Plain ASCII
     C                   WHEN      charset = 'US-ASCII'
     C                   Eval      outstr = instr
     C                   Return    %LEN(%trim(instr))
     C                   WHEN      charset = 'Big5'
      *     convert jobccsid -> 950
     C                   Eval      rc = to950(instr : ascii)
     C                   If        rc < 0
     C                   Return    rc
     C                   EndIf
     C                   Return    Bencode(ascii : rc : outstr)
      *
     C                   ENDSL
      *
     C                   Return    -5
      *
     Psmtphead         E
      *****************************************************************
      * Convert EBCDIC string to Big5
      *
      *     return : length of Big5 string
      *               0 no graphic character found
      *              -1 iconv error (->950)
      *     ebcdic : ebcdic representation of original string                 I
      *     c950   : Big5 string                                              O
      *
     Pto950            B
     Dto950            PI            10I 0
     D ebcdic                      9999    value
     D c950                        9999
      *
     D***
     D QDCXLATE        pr                  ExtPgm('QDCXLATE')
     D  CvtDtaLen                     5  0
     D  CvtDta                       10
     D  SBCSTabNam                   10
     D  SBCSTabLib                   10
     D  OutputDta                    10
     D  Outbuflen                     5  0
     D  Outcvtlen                     5  0
     D  DBCSID                       10
     D  ShiftInOut                    1
     D  CvtType                      10
     D
     D  CvtDtaLen      S              5  0
     D  CvtDta         S           9999
     D  SBCSTabNam     S             10
     D  SBCSTabLib     S             10
     D  OutputDta      S           9999
     D  Outbuflen      S              5  0
     D  Outcvtlen      S              5  0
     D  DBCSID         S             10    inz('*BG5')
     D  ShiftInOut     S              1
     D  CvtType        S             10    inz('*EA')
     D  c950_len       S             10I 0
      * no character other than space (X'40') found
     C                   Eval      CvtType = '*EA'
     C                   Eval      DBCSID = '*BG5'
     C                   Eval      Outbuflen = 9999
     C                   Eval      CvtDtaLen  = %LEN(%trimR(ebcdic))
     C                   If        CvtDtaLen = 0
     C                   Return    0
     C                   EndIf
     C                   Eval      CvtDta = ebcdic
      * convert to 950(Big5)
     C                   CallP     QDCXLATE ( CvtDtaLen  :
     C                                        CvtDta     :
     C                                        SbcsTabnam :
     C                                        SbcsTabLib :
     C                                        OutputDta  :
     C                                        OutBufLen  :
     C                                        Outcvtlen  :
     C                                        DBCSID     :
     C                                        ShiftInOut :
     C                                        CvtType      )
     C                   Eval      c950_len = Outcvtlen
     C                   If        c950_len < 0
     C                   Return    -1
     C                   EndIf
     C                   Eval      c950 = %subst(OutputDta :1 : Outcvtlen)
      *
     C                   Return    c950_len
     Pto950            E
     C*****************************************************************
      * 'B' encode for DBCS mail header
      *     return :  length of newbuf
      *              -4 especials found     <- 2002-05-06 out of use
      *     ascii : input string                                              I
      *     buflen : length of input string                                   I
      *     newbuf : output (converted) string                                O
      *    (structured : string is in structured field of mail header        )R
      *    (charset : 'US-ASCII' or 'US-ASCII-NONSAFE' or 'ISO-8859-1'       )R
      *    (fold : > 0 if folding occured                                    )M
      *
      *****************************************************************
     PBencode          B
     DBencode          PI             3P 0
     D ascii                        256    value
     D buflen                         3P 0 value
     D newbuf                       256
      *
     Dbufpos           S              3P 0
     Dcslen            S              3P 0
     Dchr              S              1
     Desc              S              3    inz(G0ascii)
     Dline             S             44
     Dlinel            S              2P 0
      *
     C                   Eval      cslen = %LEN(%trim(charset))
     C                   Eval      newbuf = '=?' + %trim(charset) + '?B?'
     C                   Eval      bufpos = cslen + 6
     C                   Eval      fold = 0
      *
1    C                   Do        buflen        I                 3 0
|    C                   Eval      chr = %subst(ascii : I : 1)
      *   escape char
 2   C                   If        chr = X'1B'
 |   C                   Eval      esc = %subst(ascii : I : 3)
     C                   Eval      I = I + 2
     C                   Eval      linel = linel + 3
      *     normal char
 E   C                   Else
      *       DBCS
  3  C                   If        esc = G0k78 or esc = G0k83
  |  C                   Eval      I = I + 1
  |  C                   Eval      linel = linel + 2
      *       SBCS
  E  C                   Else
  |  C                   Eval      linel = linel + 1
  3  C                   EndIf
 2   C                   EndIf
      *   Base64 encode when line legnth exceeds 35 bytes or end of string
 2   C                   If        (linel > 35) or (I >= buflen)
 |   C                   Eval      line = %subst(ascii : I - linel + 1 : linel)
      *   add ascii escape sequence if not end as SBCS
  3  C                   If        esc <> G0ascii and esc <> G0roman
  |  C                   Eval      %subst(line : linel + 1 : 3) = G0ascii
  |  C                   Eval      linel = linel + 3
  3  C                   EndIf
      *   adjust to multiple of 3 for base64 encode
     C     linel         DIV       3             b64count          3 0
     C                   MVR                     b64mod            3 0
     C     3             SUB       b64mod        b64pad            3 0
  3  C                   If        b64mod > 0
  |  C                   Eval      %subst(line : linel + 1 : b64pad) = X'0000'
  |  C                   Eval      linel = linel + b64pad
  3  C                   EndIf
      *   Base64 encode (3 to 4)
  3  C                   Do        linel         J                 3 0
  |  C                   Eval      %subst(newbuf : bufpos : 4) =
     C                               base64e(%subst(line : J : 3))
  |  C                   Eval      bufpos = bufpos + 4
  3  C                   EndDo     3
     C                   Z-ADD     0             linel
      *   Pad '='
  3  C                   If        b64mod > 0
     C                   Eval      %subst(newbuf : bufpos - b64pad : b64pad) =
     C                                                                    '=='
     C                   EndIf
      *   end of input string or maximum line length
  3  C                   If        (I >= buflen) or (bufpos > 180)
  |  C                   Eval      %subst(newbuf : bufpos : 2) = '?='
  |  C                   Eval      bufpos = bufpos + 2
 <-  C                   Leave
  |   *   folding
  E  C                   Else
  |  C                   Eval      %subst(newbuf : bufpos : cslen + 10) =
     C                             '?=' + X'0D0A' + ' =?' +
     C                                          %trim(charset) + '?B?'
     C                   Eval      fold = bufpos + 6
     C                   Eval      bufpos = bufpos + cslen + 10
      *     add ascii escape sequence if not end as SBCS
   4 C                   If        esc <> G0ascii and esc <> G0roman
   | C                   Eval      %subst(newbuf : bufpos : 4) = base64e(esc)
   | C                   Eval      bufpos = bufpos + 4
  |4 C                   EndIf
  3  C                   EndIf
 |    *
|2   C                   EndIf
1    C                   EndDo
      *
     C                   Return    bufpos - 1
      *****************************************************************
     PBencode          E
      * Base64 encode (3 to 4)
      *     inchr : 3 bytes string to convert                                 I
      *     return : Converted character (ASCII)
      *
      *****************************************************************
     Pbase64e          B
     Dbase64e          PI             4
     D inchr                          3    value
      *
     Dchrs             DS
     D i1                      1      1
     D i2                      2      2
     D i3                      3      3
     Dap1DS            DS
     D ap1                     1      2U 0 inz(0)
     D ap1L                    2      2
     Dap2DS            DS
     D ap2                     1      2U 0 inz(0)
     D ap2L                    2      2
     Dap3DS            DS
     D ap3                     1      2U 0 inz(0)
     D ap3L                    2      2
     Dap4DS            DS
     D ap4                     1      2U 0 inz(0)
     D ap4L                    2      2
      *
     Db64e             C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     abcdefghijklmnopqrstuvwxyz-
     D                                     0123456789+/'
     C                   Move      inchr         chrs
      * 1st byte of outchr
     C                   Move      i1            ap1L
     C                   DIV       4             ap1
      * 2nd
     C                   TESTB     '6'           i1                       20
     C   20              BITON     '2'           ap2L
     C                   TESTB     '7'           i1                       20
     C   20              BITON     '3'           ap2L
     C                   TESTB     '0'           i2                       20
     C   20              BITON     '4'           ap2L
     C                   TESTB     '1'           i2                       20
     C   20              BITON     '5'           ap2L
     C                   TESTB     '2'           i2                       20
     C   20              BITON     '6'           ap2L
     C                   TESTB     '3'           i2                       20
     C   20              BITON     '7'           ap2L
      * 3rd
     C                   TESTB     '4'           i2                       20
     C   20              BITON     '2'           ap3L
     C                   TESTB     '5'           i2                       20
     C   20              BITON     '3'           ap3L
     C                   TESTB     '6'           i2                       20
     C   20              BITON     '4'           ap3L
     C                   TESTB     '7'           i2                       20
     C   20              BITON     '5'           ap3L
     C                   TESTB     '0'           i3                       20
     C   20              BITON     '6'           ap3L
     C                   TESTB     '1'           i3                       20
     C   20              BITON     '7'           ap3L
      * 4th
     C                   BITOFF    '01'          i3
     C                   Move      i3            ap4L
      *
     C                   Return    %subst(b64e : ap1 + 1 : 1) +
     C                             %subst(b64e : ap2 + 1 : 1) +
     C                             %subst(b64e : ap3 + 1 : 1) +
     C                             %subst(b64e : ap4 + 1 : 1)
      *
     Pbase64e          E
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This ends this program abnormally, and sends back an escape.
      *   message explaining the failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P die             B
     D die             PI
     D   peMsg                      256A   const

     D SndPgmMsg       pr                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   msgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32766A   options(*varsize)

     D dsEC            DS
     D  dsECBytesP             1      4I 0 inz(256)
     D  dsECBytesA             5      8I 0 inz(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECmsgDta            17    256

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c                   Eval      wwMsgLen = %len(%trimr(peMsg))
     c                   If        wwMsgLen<1
     c                   Return
     c                   EndIf

     c                   CallP     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsg: wwMsgLen: '*ESCAPE':
     c                               '*PGMBDY': 1: wwTheKey: dsEC)

     c                   Return
     P                 E
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This procedure return call socket C API errno
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P errno           B
     D errno           PI            10I 0
     D p_errno         S               *
     D wwreturn        S             10I 0 based(p_errno)
     C                   Eval      p_errno = @__errno
     c                   Return    wwreturn
     P                 E

*
