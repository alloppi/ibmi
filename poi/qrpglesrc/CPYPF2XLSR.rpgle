      //////////////////////////////////////////////////////////////////
      //  Convert PF into Excel file                                  //
      //  (c) Peter Colpaert 2005 - mailto:Peter.Colpaert@telenet.be  //
      //                                                              //
      //  Important: since POI 1.8.0,  createRow takes a 10i0 parm    //
      //             instead of 5i0 - change back if using POI 1.5.1  //
      //////////////////////////////////////////////////////////////////
     h dftactgrp(*no) actgrp('MadSlammer')
     h COPYRIGHT('2005 Peter Colpaert <Peter.Colpaert@telenet.be>')
     h debug(*yes) alwnull(*inputonly)
     h bnddir('QC2LE')
      //
     finputf    if   f32766        disk    ExtFile(libfile)
     f                                     ExtMbr(member)
     f                                     UsrOpn
      //
     d CpyPf2XlsR      pr                  ExtPgm('CPYPF2XLSR')
     d                               20a
     d                               10a
     d                             1024a
      //
     d CpyPf2XlsR      pi
     d  FileLib                      20a
     d  Member                       10a
     d  IfsFile                    1024a
      //
     d Atoi            PR            10i 0 ExtProc('atoi')                      Alpha to Integer
     d                                 *   value options(*string)
      //
     d Atof            PR             4f   ExtProc('atof')                      Alpha to Float
     d                                 *   value options(*string)
      //
     D CharToNum       PR            30P 9
     D                               50A   VARYING CONST
      //
     d System          pr            10i 0 ExtProc('system')
     d                                 *   value options(*string)
      //
     d NumField        s             30P 9
      //
     d MemCopy         pr              *   ExtProc('_MEMMOVE')
     d  pOutMem                        *   Value
     d  pInMem                         *   Value
     d  iMemSiz                      10i 0 Value
      //
      // OBJECT Variables *******************************************************
      // // String.
     D string          S               O   CLASS(*JAVA
     D                                     :'java.lang.String')
      // // String with fileName.
     D filename        S               O   CLASS(*JAVA
     D                                     :'java.lang.String')
      // // FileOutputStream.
     D outFile         S               O   CLASS(*JAVA
     D                                     :'java.io.FileOutputStream')
      // // Workbook.
     D wb              S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      // // Sheet.
     D s               S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      // // Row.
     D row             S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
      // // Cell.
     D cell            S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
      // // Font
     D boldfont        S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
     D normalfont      S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      // // CellStyle bold centered
     D boldstyle       S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      // // CellStyle normal
     D normalstyle     S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      // CONSTRUCTOR Methods. ***************************************************
      // // String CONSTRUCTOR
      // // new String(byte b[])
     D createString    PR              O   EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D                                     CLASS(*JAVA
     D                                     :'java.lang.String')
     D parm                        1024
      // // FileOutputStream CONSTRUCTOR
      // // new FileOutputStream(String file)
     D createFile      PR              O   EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :*CONSTRUCTOR)
     D                                     CLASS(*JAVA
     D                                     :'java.io.FileOutputStream')
     D parm                            O   CLASS(*JAVA
     D                                     :'java.lang.String')
      // // WorkBook CONSTRUCTOR
     D createWB        PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :*CONSTRUCTOR)
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      // // write(java.io.OutputStream)
     D writeWB         PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'write')
     D parm                            O   CLASS(*JAVA
     D                                     :'java.io.OutputStream')
      // METHODS ****************************************************************
      // // java.lang.trim()
     D trimString      PR              O   EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :'trim')
     D                                     CLASS(*JAVA
     D                                     :'java.lang.String')
      // // java.outputstream.close()
     D closeFile       PR                  EXTPROC(*JAVA
     D                                     :'java.io.OutputStream'
     D                                     :'close')
      // // WorkBook.createSheet()
     D createSheet     PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createSheet')
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      // // WorkBook.setSheetName(int,string)
     D setSheetName    PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'setSheetName')
     D parm                          10I 0 Value
     D parm2                           O   CLASS(*JAVA
     D                                     :'java.lang.String')
      // // Sheet.createRow()
     D createRow       PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'createRow')
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
     D parm                          10I 0 value
      // // Row.createCell()
     D createCell      PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'createCell')
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
     D parm1                          5I 0 value
      // // Cell.setCellType(int)
     D setCellType     PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellType')
     D parm1                         10I 0 Value
      // // Cell.setCellValue(String)
     D setCellValStr   PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D parm                            O   CLASS(*JAVA
     D                                     :'java.lang.String')
      // // Cell.setCellValue(double)
     D setCellValD     PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D parm                           8F   value
      //
     D createFont      PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createFont')
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      //
     D setFontName     PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setFontName')
     D parm                            O   CLASS(*JAVA
     D                                     :'java.lang.String')
      //
     D setEncoding     PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setEncoding')
     D parm1                          5I 0 value
      //
     D setColor        PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setColor')
     D parm1                          5I 0 value
      //
     D setBoldweight   PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setBoldweight')
     D parm1                          5I 0 value
      //
     D createStyle     PR              O   EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createCellStyle')
     D                                     CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      //
     D setFont         PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setFont')
     D parm                            O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      //
     D setAlignment    PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setAlignment')
     D parm1                          5I 0 value
      //
     D setCellStyle    PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellStyle')
     D parm                            O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      //
     D setColWidth     PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setColumnWidth')
     D parm1                          5I 0 value
     D parm2                          5I 0 value
      //
     d RtvMbrD         pr                  ExtPgm('QUSRMBRD')
     d                            32767    Options(*varsize)                    Receiver Variable
     d                               10i 0 Const                                Rec. Var Length
     d                                8    Const                                Format Name
     d                               20    Const                                Qualified File Name
     d                               10    Const                                Member Name
     d                                1    Const                                Override processing
     db                                    like(vApiErrDS)
      //
     D valueAlf        S           1024
     D valueNUM        S              8F
     d LibFile         s             20a
     d Count           S             10i 0 Inz(0)
     d C               S             10i 0 Inz(0)
     d name            S           1024    Inz('Sheet 1')
     d font_name       S           1024    Inz('Arial')
     d center          S              5i 0 Inz(2)
     d general         S              5i 0 Inz(0)
     d bold            S              5i 0 Inz(700)
     d normal          S              5i 0 Inz(400)
     d c_AddEnvVar     c                   'ADDENVVAR ENVVAR(CLASSPATH) -
     d                                     VALUE(''/javaapps/poi-3.13-
     d                                     /poi-3.13-20150929.jar'')'
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
     d Hival5i0        s              5i 0 inz(*hival)
     d Hival10i0       s             10i 0 inz(*hival)
      //
     d  Counter        s                   Like(NumOfEntries)
     d  Null           c                   ''
      //
     d                 ds                  Based(UsrSpcPtr)
     d  OffSetToHead         117    120i 0
     d  OffsetToList         125    128i 0
     d  NumOfEntries         133    136i 0
     d  SizeOfEntry          137    140i 0
      //
      //******************************************************************
      //Type Definition for the Header Section of the user space in the
      //QUSLFLD API.
      //******************************************************************
     DQUSQLH           DS                  Based(HeadPtr)
      //                                             Qdb Lfld Header
     D QUSFILNU                1     10
      //                                             File Name Used
     D QUSLIBN                11     20
      //                                             Library Name
     D QUSFILT                21     30
      //                                             File Type
     D QUSRFN00               31     40
      //                                             Record Format Name
     D QUSRL                  41     44B 0
      //                                             Record Length
     D QUSRFI                 45     57
      //                                             Record Format Id
     D QUSRTD                 58    107
      //                                             Record Text Description
     D QUSERVED01            108    108
      //                                             Reserved
     D QUSCCSID              109    112B 0
      //                                             Record Description CCSID
     D QUSVLF                113    113
      //                                             Variable Length Fields
     D QUSGFI                114    114
      //                                             Graphic Fields Indicator
     D QUSDTFI               115    115
      //                                             Date Time Fields Indicator
     D QUSNCFI               116    116
      //                                             Null Capable Fields Indicato
      //******************************************************************
      //Type Definition for the FLDL0100 format of the userspace in the
      //QUSLFLD API.
      //******************************************************************
     DQUSL0100         DS                  Based(ListPtr)
      //                                             Qdb Lfld FLDL0100
     D QUSFN02                 1     10
      //                                             Field Name
     D QUSDT                  11     11
      //                                             Data Type
     D QUSU                   12     12
      //                                             Use
     D QUSOBP                 13     16B 0
      //                                             Output Buffer Position
     D QUSIBP                 17     20B 0
      //                                             Input Buffer Position
     D QUSFLB                 21     24B 0
      //                                             Field Length Bytes
     D QUSIGITS               25     28B 0
      //                                             Digits
     D QUSDP                  29     32B 0
      //                                             Decimal Positions
     D QUSFTD                 33     82
      //                                             Field Text Description
     D QUSEC00                83     84
      //                                             Edit Code
     D QUSEWL                 85     88B 0
      //                                             Edit Word Length
     D QUSEW                  89    152
      //                                             Edit Word
     D QUSCH1                153    172
      //                                             Column Heading1
     D QUSCH2                173    192
      //                                             Column Heading2
     D QUSCH3                193    212
      //                                             Column Heading3
     D QUSIFN                213    222
      //                                             Internal Field Name
     D QUSAFN                223    252
      //                                             Alternate Field Name
     D QUSLAF                253    256B 0
      //                                             Length Alternate Field
     D QUSDBCSC              257    260B 0
      //                                             Number DBCS Characters
     D QUSNVA                261    261
      //                                             Null Values Allowed
     D QUSVFI                262    262
      //                                             Variable Field Indicator
     D QUSDTF                263    266
      //                                             Date Time Format
     D QUSDTS                267    267
      //                                             Date Time Separator
     D QUSVLFI               268    268
      //                                             Variable Length Field Ind
     D QUSCCSID00            269    272B 0
      //                                             Field Description CCSID
     D QUSCCSID01            273    276B 0
      //                                             Field Data CCSID
     D QUSCCSID02            277    280B 0
      //                                             Field Column Heading CCSID
     D QUSCCSID03            281    284B 0
      //                                             Field Edit Words CCSID
      //
      //
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
      //-- Apply decimal format:  ---------------------------------------------**
     D ApyDecFmt       Pr            32a   Varying
     D  PxInpStr                     32a   Value  Varying
     D  PxDecPos                      5u 0 Const
     **-- Convert edit code to mask:  ----------------------------------------**
     D CvtCdeMsk       Pr                  ExtPgm( 'QECCVTEC' )
     D  CcEdtMsk                    256a
     D  CcEdtMskLen                  10i 0
     D  CcRcvVarLen                  10i 0
     D  CcZroFilChr                   1a
     D  CcEdtCde                      1a   Const
     D  CcCcyInd                      1a   Const
     D  CcSrcVarPrc                  10i 0 Const
     D  CcSrcVarDec                  10i 0 Const
     D  CcError                   32767a          Options( *VarSize )
     **-- Retrieve job information:  -----------------------------------------**
     D RtvJobInf       Pr                  ExtPgm( 'QUSRJOBI' )
     D  RiRcvVar                  32767a          Options( *VarSize )
     D  RiRcvVarLen                  10i 0 Const
     D  RiFmtNam                      8a   Const
     D  RiJobNamQ                    26a   Const
     D  RiJobIntId                   16a   Const
     **-- Optional 1:
     D  RiError                   32767a          Options( *NoPass: *VarSize )
     **-- Optional 2:
     D  RiRstStc                      1a          Options( *NoPass )
     D EditC           Pr           256a   Varying
     D  PxDecVar                       *   Value
     D  PxDecTyp                      1a   Const
     D  PxDecDig                      5u 0 Const
     D  PxDecPos                      5u 0 Const
     D  PxEdtCde                      1a   Const
     **
     **-- Edit function:  ----------------------------------------------------**
     D Edit            Pr                  ExtProc( '_LBEDIT' )
     D  RcvVar                         *   Value
     D  RcvVarLen                    10u 0 Const
     D  SrcVar                         *   Value
     D  SrcVarAtr                          Const  Like( DPA_Template_T )
     D  EdtMsk                      256a   Const
     D  EdtMskLen                    10u 0 Const
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
      //-- Edit template & constants:  ----------------------------------------**
     D DPA_Template_T  Ds
     D  SclTyp                        1a
     D  SclLen                        5i 0
     D   DecPos                       3i 0 Overlay( SclLen: 1 )
     D   DecLen                       3i 0 Overlay( SclLen: 2 )
     D  Rsv                          10i 0 Inz
      //
     D T_SIGNED        c                   x'00'
     D T_FLOAT         c                   x'01'
     D T_ZONED         c                   x'02'
     D T_PACKED        c                   x'03'
     D T_UNSIGNED      c                   x'0A'
      //
     iinputf    ns
     i                                  132766  RcdBuf
      /free
        System(c_AddEnvVar);

        LibFile = %trim(%subst(filelib:11:10)) + '/' +
                  %trim(%subst(filelib:1:10));
        CrtSpc(SpaceName);
        Listfields(%subst(filelib:1:10):
                   %subst(filelib:11:10):
                   '*FIRST');
        UsrSpcPtr = RtvPtr(SpaceName);
        // Create String filename.

        IFSFile = %trim(IFSFile);
        filename = createString(IFSFile);
        // Trim filename (50A).
        filename = trimString(filename);
        // Create FileOutputStream.
        outFile = createFile(filename);
        Count = 0;
        // Create a Workbook.
        wb = createWB();
        // Create a Worksheet.
        s = createSheet(wb);
        // Set Worksheet Name
        string = createString(name);
        string = trimString(string);
        setSheetName(wb:0:string);
        // Create a bold Font.
        boldfont = createFont(wb);
        string = createString(font_name);
        string = trimString(string);
        setFontName(boldfont:string);
        setBoldweight(boldfont:bold);
        // Create a normal Font.
        normalfont = createFont(wb);
        string = createString(font_name);
        string = trimString(string);
        setFontName(normalfont:string);
        setBoldweight(normalfont:normal);
        // Create bold style
        boldstyle = createStyle(wb);
        setFont(boldstyle:boldfont);
        setAlignment(boldstyle:center);
        // Create normal style
        normalstyle = createStyle(wb);
        setFont(normalstyle:normalfont);
        setAlignment(normalstyle:general);
        // Set pointer to user space
        HeadPtr = UsrSpcPtr + OffsetToHead;

        // Create header row
        Exsr HeaderRow;
        // Run through file records.
        Open inputf;
        Read inputf;
        Dow not %eof;
          Exsr DBRec2Excel;
          Read Inputf;
        Enddo;
        Close Inputf;
        // Write Workbook to output file.
        writeWB(wb:outFile);
        closeFile(outFile);
        // End of program.
        DltSpc(SpaceName);
        *inlr = *on;

        //////////////////////////////////
        // Create Header Row Subroutine //
        //////////////////////////////////

        Begsr HeaderRow;
        // Create a row.
        row = createRow(s:Count);
        ListPtr = UsrSpcPtr + OffsetToList;
        For Counter = 1 to NumOfEntries;
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           Select;
           When (qusflb * 256 > hival5i0) or
                (%len(qusch1) * 256 > hival5i0);
              setColWidth(s:Counter -1:hival5i0);
           When qusflb > %len(qusch1);
              setColWidth(s:Counter -1:QUSFLB * 256);
           Other;
              setColWidth(s:Counter -1:%len(qusch1) * 256);
           Endsl;
           setCellType(cell:1);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueALF;
           valueALF = qusch1;
           string = createString(valueALF);
           string = trimString(String);
           // Set cell value.
           setCellValStr(cell:string);
           setCellStyle(cell:boldstyle);
           ListPtr = ListPtr + SizeOfEntry;
        EndFor;
        // Count row number.
        Count  = Count +1;

        // Create a row.
        row = createRow(s:Count);
        ListPtr = UsrSpcPtr + OffsetToList;
        For Counter = 1 to NumOfEntries;
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           setCellType(cell:1);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueALF;
           valueALF = qusch2;
           string = createString(valueALF);
           string = trimString(String);
           // Set cell value.
           setCellValStr(cell:string);
           setCellStyle(cell:boldstyle);
           ListPtr = ListPtr + SizeOfEntry;
        EndFor;
        // Count row number.
        Count  = Count +1;

        // Create a row.
        row = createRow(s:Count);
        ListPtr = UsrSpcPtr + OffsetToList;
        For Counter = 1 to NumOfEntries;
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           setCellType(cell:1);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueALF;
           valueALF = qusch3;
           string = createString(valueALF);
           string = trimString(String);
           // Set cell value.
           setCellValStr(cell:string);
           setCellStyle(cell:boldstyle);
           ListPtr = ListPtr + SizeOfEntry;
        EndFor;
        // Count row number.
        Count  = Count +1;

        // Create a row.
        row = createRow(s:Count);
        ListPtr = UsrSpcPtr + OffsetToList;
        For Counter = 1 to NumOfEntries;
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           setCellType(cell:1);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueALF;
           valueALF = QUSFN02;
           string = createString(valueALF);
           string = trimString(String);
           // Set cell value.
           setCellValStr(cell:string);
           setCellStyle(cell:boldstyle);
           ListPtr = ListPtr + SizeOfEntry;
        EndFor;
        // Count row number.
        Count  = Count +1;
        Endsr;

        //////////////////////////////////
        // Create Data Row Subroutine //
        //////////////////////////////////

        Begsr DBRec2Excel;
        // Create a row.
        row = createRow(s:Count);
        ListPtr = UsrSpcPtr + OffsetToList;
        For Counter = 1 to NumOfEntries;
        If qusdt = 'A' or
           qusdt = 'L' or
           qusdt = 'T' or
           qusdt = 'Z';
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           setCellType(cell:1);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueALF;
           MemCopy(%addr(valueALF):
                   %addr(RcdBuf) +
                   qusibp - 1:
                   qusflb);
           string = createString(valueALF);
           string = trimString(String);
           // Set cell value.
           setCellValStr(cell:string);
           setCellStyle(cell:normalstyle);
        Else;
           // Create a cell (row:number)
           // Set Type 0=Numeric/1=String)
           cell = createCell(row:Counter - 1);
           setCellType(cell:0);
           setEncoding(cell:1);
           // Create String Cell Value.
           reset valueNUM;
           valueNUM = CharToNum(%trim(EditC(%addr(RcdBuf) +
                                            qusibp - 1:
                                            qusdt:
                                            qusigits:
                                            qusdp:
                                            'P')));
           // Set cell value.
           setCellValD(cell:valueNUM);
           setCellStyle(cell:normalstyle);
        Endif;
        ListPtr = ListPtr + SizeOfEntry;
        EndFor;
        // Count row number.
        Count  = Count +1;
        Endsr;

      /End-Free
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
      //-- Edit code:  --------------------------------------------------------**
     P EditC           B
     D                 Pi           256a   Varying
     D  PxDecVar                       *   Value
     D  PxDecTyp                      1a   Const
     D  PxDecDig                      5u 0 Const
     D  PxDecPos                      5u 0 Const
     D  PxEdtCde                      1a   Const
      //-- Local variables & constants:
     D EdtMsk          s            256a
     D EdtMskLen       s             10i 0
     D RcvVar          s            256a
     D RcvVarLen       s             10i 0
     D ZroFilChr       s              1a
     D DecDig          s             10u 0
      //
      //-- Edit:  -------------------------------------------------------------**
      //
      /FREE
       Select;
       When PxDecTyp   = 'P'            Or
             PxDecTyp   = 'S';
         //
         If PxDecTyp   = 'P';
           SclTyp     = T_PACKED;
         Else;
           SclTyp     = T_ZONED;
         EndIf;
         //
         DecDig     = PxDecDig;
         DecPos     = PxDecPos;
         DecLen     = PxDecDig;
         //
       When PxDecTyp   = 'B';
         //
         SclTyp     = T_SIGNED;
         //
         DecDig     = PxDecDig;
         DecPos     = *Zero;
         //
         If DecDig     > 5;
           DecDig     = 10;
           DecLen     = 4;
         Else;
           DecDig     = 5;
           DecLen     = 2;
         EndIf;
       EndSl;
       //
       CvtCdeMsk( EdtMsk
           : EdtMskLen
           : RcvVarLen
           : ZroFilChr
           : PxEdtCde
           : ' '
           : DecDig
           : DecPos
           : vApiErrDs
           );
       //
       CallP(e) Edit( %Addr( RcvVar )
           : RcvVarLen
           : PxDecVar
           : DPA_Template_T
           : EdtMsk
           : EdtMskLen
           );
       //
       If %Error;
         Return Null;
         //
          ElseIf PxDecTyp   = 'B'            And
                 PxDecPos   > *Zero;
         //
         Return ApyDecFmt( %SubSt( RcvVar: 1: RcvVarLen )
             : PxDecPos
             );
         //
       Else;
         Return %SubSt( RcvVar: 1: RcvVarLen );
       EndIf;
       //
      /END-FREE
     P EditC           E
      //-- Apply decimal format:  ---------------------------------------------**
     P ApyDecFmt       B
     D                 Pi            32a   Varying
     D  PxInpStr                     32a   Value  Varying
     D  PxDecPos                      5u 0 Const
      //-- Local variables:
     D ZroOfs          s              5u 0
     D DecOfs          s              5u 0
      //-- Job info format JOBI0400:
     D J4RcvDta        Ds
     D  J4BytRtn                     10i 0
     D  J4BytAvl                     10i 0
     D  J4JobNam                     10a
     D  J4UsrNam                     10a
     D  J4JobNbr                      6a
     D  J4DecFmt                      1a   Overlay( J4RcvDta: 457 )
      //
      /FREE
       RtvJobInf( J4RcvDta
           : %Size( J4RcvDta )
           : 'JOBI0400'
           : '*'
           : *Blank
           : vApiErrDs
           );
       //
       If vbytav    > *Zero;
         Return PxInpStr;
       Else;
         //
         If J4DecFmt    = 'J';
           ZroOfs      = %Len( PxInpStr ) - PxDecPos;
           DecOfs      = ZroOfs + 1;
         Else;
           ZroOfs      = %Len( PxInpStr ) - PxDecPos + 1;
           DecOfs      = ZroOfs;
         EndIf;
         //
         PxInpStr    = %Xlate( ' '
             : '0'
             : PxInpStr
             : ZroOfs
             );

         //
         If J4DecFmt    = ' ';
           Return %Replace( '.'
               : PxInpStr
               : DecOfs
               : 0
               );
           //
         Else;
           Return %Replace( ','
               : PxInpStr
               : DecOfs
               : 0
               );
         EndIf;
       EndIf;
       //
      /END-FREE
     P ApyDecFmt       E
      //----------------------------------------------------------------------//
     P CharToNum       B
     D CharToNum       PI            30P 9
     D    Str                        50A   varying const

     D negative        S               N   inz(*OFF)

     D string          DS            30
     D    decnum                     30S 9 inz(0)

     D i               S             10I 0 inz(1)
     D digits          S             10I 0 inz(0)
     D decpos          S             10I 0 inz(0)
     D dec             S             10I 0 inz(0)
     D ch              S              1a
     D chtemp          S             30a   varying

      /free

       // Skip leading blanks (if any)
       dow i <= %len(Str) and %subst(Str:i:1) = ' ';
          i = i + 1;
       enddo;

       // Is string all blanks?
       if i > %len(Str);
          return 0;
       endif;

       // Is first non-blank char a minus sign?
       if %subst(Str:i:1) = '-';
          negative = *ON;
          i = i + 1;
       endif;

       // Skip leading zeros (if any)
       dow i <= %len(Str) and %subst(Str:i:1) = '0';
          i = i + 1;
       enddo;

       // Is string all zeros and blanks?
       if i > %len(Str);
          return 0;
       endif;

       // Loop through digits of string to be converted
       dow i <= %len(Str);
          ch = %subst(Str:i:1);
          if ch = ',';
             // We've reached the decimal point - only
             // one allowed
             if decpos <> 0;
                // We've already read a decimal point
                leave;
             endif;
             // Indicate decimal position just after last
             // digit read.
             decpos = digits + 1;

          elseif ch >= '0' and ch <= '9';
             // We've read a digit - save it
             digits = digits + 1;
             chtemp = chtemp + ch;

             // Have we read enough digits?
             if digits = 30;
                leave;
             endif;

          else;
             // Anything other than a digit or decimal point
             // ends the number
             leave;
          endif;

          // Advance to the next character
          i = i + 1;
       enddo;

       // Adjust decimal positions
       if decpos = 0;
          // If no decimal point coded, assume one after all digits
          decpos = %len(chtemp) + 1;
       else;
          // drop excess decimal digits
          dec = %len(chtemp) - decpos + 1;
          if dec > 9;
             %len(chtemp) = %len(chtemp) - (dec - 9);
          endif;
       endif;

       // Scale number appropriately
       %subst(string: 23-decpos: %len(chtemp)) = chtemp;

       // Set sign of result
       if negative;
          decnum = - decnum;
       endif;

       // Return answer
       return decnum;

      /end-free
     P CharToNum       E
