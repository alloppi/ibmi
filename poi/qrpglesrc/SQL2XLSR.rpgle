
     H dftactgrp(*no) thread(*serialize) bnddir('QC2LE') debug
     H copyright('gcostagliola@tin.it - 2003')

      *********************************************************************
      * SQL2XLSR - Create Excel from SQL
      *********************************************************************

      *********************************************************************
      * "This product includes software developed by the
      *  Apache Software Foundation (http://www.apache.org/)."
      * -------------------------------------------------------------------
      * THIS UTILITY IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED
      * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
      * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      * DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OF THIS UTILITY OR
      * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
      * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
      * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
      * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
      * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
      * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
      * OF THE USE OF THIS UTILITY, EVEN IF ADVISED OF THE POSSIBILITY OF
      * SUCH DAMAGE.
      *********************************************************************

      **------------------------------------------------------------------
*s1*  * SQL2XLS CMD PARAMETERS
      **------------------------------------------------------------------
     D EntryParms      PR                  extpgm('SQL2XLSR')
     D  pSQLSTMT                   5000
     D  pTOXLS                       63
     D  pFROMXLS                     63
     D  pCOLHDRS                     10
     D  pTITLE                      120
     D  pTITLECOLS                    5i 0
     D  pTITLEALIGN                   7
     D  pNAMING                       4
     D  pACTION                       9
     D  pLOGSQL                       4
     D  pSQLLOCVAL                    4
     D EntryParms      PI
     D  pSQLSTMT                   5000
     D  pTOXLS                       63
     D  pFROMXLS                     63
     D  pCOLHDRS                     10
     D  pTITLE                      120
     D  pTITLECOLS                    5i 0
     D  pTITLEALIGN                   7
     D  pNAMING                       4
     D  pACTION                       9
     D  pLOGSQL                       4
     D  pSQLLOCVAL                    4

      *----------------------------------------------------------------
*s2*  * sql communication area
      *----------------------------------------------------------------
     D SQLCA           DS
     D  SQLCAID                       8
     D  SQLCABC                       9B 0
     D  SQLCODE                       9B 0
     D  SQLERRML                      4B 0
     D  SQLERRMC                     70
     D  SQLERRP                       8
     D  SQLERRD                      24
     D   SQLER1                       9B 0 Overlay(SQLERRD:1)
     D   SQLER2                       9B 0 Overlay(SQLERRD:5)
     D   SQLER3                       9B 0 Overlay(SQLERRD:9)
     D   SQLER4                       9B 0 Overlay(SQLERRD:13)
     D   SQLER5                       9B 0 Overlay(SQLERRD:17)
     D   SQLER6                       4a   Overlay(SQLERRD:21)
     D  SQLWARN                      11
     D  SQLSTATE                      5

      *----------------------------------------------------------------
      * sql descriptor area
      *----------------------------------------------------------------
     D SQLDA           DS                  based(pSQLDA)
     D  SQLDAID                1      8A
     D  SQLDABC                9     12B 0
     D  SQLN                  13     14B 0
     D  SQLD                  15     16B 0
     D  SQL_VAR                      80A   DIM(1)

     D SQLVAR          DS                  based(pSQLVAR)
     D  SQLTYPE                1      2B 0
     D  SQLLEN                 3      4B 0
     D   Precis                3      3
     D   Scale                 4      4
     D  SQLRES                 5     16A
     D  SQLDATA               17     32*
     D  SQLIND                33     48*
     D  SQLNAMELEN            49     50B 0
     D  SQLNAME               51     80A

     D* SQLDA pointers
     D pSQLDA          s               *
     D pSQLVAR         s               *

     D* SQLDA sizes
     D nSQLDA          s              5i 0
     D szSQLDA         s             10i 0

     D* Column sizes
     D cSQLLEN         s              5i 0
     D pSQLLEN         ds                  inz
     D  pPrecis                1      4b 0
     D   aPrecis               4      4
     D  pScale                 5      8b 0
     D   aScale                8      8

     D* Record buffer
     D Record          s          32000

     D* Miscellaneous
     D psqlL           s              5i 0
     D NullFields      s              5i 0 dim(1000)
     D i               s              5i 0
     D j               s              5i 0
     D jo              s              5i 0
     D od              s              5i 0
     D on              s              5i 0

      *----------------------------------------------------------------
*s3*  * QSQPRCED - process extended dynamic sql
      *----------------------------------------------------------------
     D QSQPRCED        PR                  extpgm('QSQPRCED')
     D  SQLCA                       136
     D  SQLDA                     32000    options(*varsize)
     D  sqformat                      8    const
     D  sqlp0100                   5096    options(*varsize)
     D  apierror                    120    options(*varsize)
     D** Function Template
     D sqlp0100        ds
     D  function                      1    inz('0')
     D  pkgname                      10    inz('SQLPACK')
     D  pkglib                       10    inz('QTEMP')
     D  mainpgm                      10    inz('SQL2XLSR')
     D  mainlib                      10    inz('*LIBL')
     D  stmname                      18    inz('EXCEL')
     D  curname                      18    inz('CURSOR')
     D  openopt                       1    inz(x'00')
     D  claudesc                      1    inz('A')
     D  commit                        1    inz('N')
     D  datefmt                       3    inz('DMY')
     D  datesep                       1    inz('/')
     D  timefmt                       3    inz('HMS')
     D  timesep                       1    inz(':')
     D  namingopt                     3    inz('SYS')
     D  decpos                        1    inz('.')
     D  block                         4b 0 inz(0)
     D  SqlStmtl                      4b 0 inz(0)
     D  SqlStmt                    5000

     D sqformat        ds
     D  format                       10    inz('SQLP0100')

      *----------------------------------------------------------------
      * QUSRJOBI - job informations
      *----------------------------------------------------------------
     D QUSRJOBI        PR                  extpgm('QUSRJOBI')
     D  jobi0100                     70
     D  jobi_bytes                    9b 0 const
     D  jobi_form                    10    const
     D  jobi_jobn                    26    const
     D  jobi_jobi                    16    const
     D  apierror                    120    options(*varsize)
     D** Job information
     D jobi0100        ds            70
     D  jobi_bytes                    9b 0 inz(61)
     D  jobi_avail                    9b 0
     D  jobi_jobn                    26    inz('*')
     D  jobi_jobi                    16    inz
     D  jobi_form                    10    inz('JOBI0100')
     D  jobi_type                     1

      *----------------------------------------------------------------
      * QUSROBJD - object description information
      *----------------------------------------------------------------
     D QUSROBJD        PR                  extpgm('QUSROBJD')
     D  objd0100                     48
     D  objd_bytes                    9b 0 const
     D  objd_form                     8    const
     D  obj_name                     20    const
     D  objd_type                    10    const
     D  apierror                    120    options(*varsize)
     D** Object description
     D objd0100        ds
     D  objd_bytes                    9b 0 inz(48)
     D  objd_avail                    9b 0
     D  objd_form                    10    inz('OBJD0100')
     D  objd_type                    10
     D                               10
     D  objd_rlib                    10
     D  objd_name      s             20

      *----------------------------------------------------------------
      * QWCRSVAL - retrieve system values
      *----------------------------------------------------------------
     D QWCRSVAL        PR                  extpgm('QWCRSVAL')
     D  qsva_rcv                    180
     D  qsva_rcvL                     9b 0 const
     D  qsva_sysL                     9b 0 const
     D  qsva_sysv                    40    const
     D  apierror                    120    options(*varsize)
     D** system values
     D qsva_rcvL       s              9b 0 inz(120)
     D qsva_sysL       s              9b 0 inz(4)
     D qsva_sysv       ds
     D  datfmt                       10    inz('QDATFMT')
     D  datsep                       10    inz('QDATSEP')
     D  timsep                       10    inz('QTIMSEP')
     D  decfmt                       10    inz('QDECFMT')

     D qsva_rcv        ds
     D  rtnval                        9b 0
     D  sysoff                        9b 0 dim(4)
     D  systable                    160
     D qsystable       ds
     D  sysvaltab                    24    dim(4)
     D  sysvalname                   10    Overlay(sysvaltab:1)
     D  sysvalue                      7    Overlay(sysvaltab:17)

      *----------------------------------------------------------------
      * QMHSNDPM/QMHRCVPM - send/receive program messages
      *----------------------------------------------------------------
     D QMHSNDPM        PR                  extpgm('QMHSNDPM')
     D  MessageId                     7    const
     D  MessageFile                  20    const
     D  MessageData                 512    const options(*varsize)
     D  MessageDataL                  9b 0 const
     D  MessageType                  10    const
     D  CallStkEntry                128    const options(*varsize)
     D  CallStkCount                  9b 0 const
     D  MessageKey                    4    const
     D  ApiError                    120    options(*varsize)
     D* send program message
     D sndpgmmsg       ds
     D  msgid                         7    inz('CPF9898')
     D  msgfile                      20    inz('QCPFMSG   QSYS      ')
     D  msgdataL                      9b 0 inz(512)
     D  msgtype                      10    inz('*COMP     ')
     D  msgmsgq                      11    inz('*       ')
     D  msgstack                      9b 0 inz(1)
     D  msgkey                        4
     D* receive program message
     D QMHRCVPM        PR                  extpgm('QMHRCVPM')
     D  rcv0100                    1024
     D  msgbytes                      9b 0 const
     D  msgformat                     8    const
     D  msgmsgq                      11    const
     D  msgstack                      9b 0 const
     D  msgtyper                     10    const
     D  msgkey                        4    const
     D  msgwait                       9b 0 const
     D  msgaction                    10    const
     D  ApiError                    120    options(*varsize)
     D rcvpgmmsg       ds
     D  msgbytes                      9b 0 inz(8)
     D  msgformat                     8    inz('RCVM0100')
     D  msgwait                       9b 0 inz(0)
     D  msgaction                    10    inz('*OLD      ')
     D  msgtyper                     10    inz('*ANY      ')
     D msgdata         s            512
     D rcv0100         s           1024

      *----------------------------------------------------------------
      * api error structure
      *----------------------------------------------------------------
     D ApiError        ds
     D  ApiErrLP                      9b 0 inz(%len(Apierror))
     D  ApiErrLA                      9b 0 inz(0)
     D  ApiErrMsg                     7
     D                                1
     D  ApiErrDta                   104

      *----------------------------------------------------------------
*s4*  * MI/C functions
      *----------------------------------------------------------------
     D* Copy Bytes left adjusted (MemCpy)
     D Cpybla          pr                  ExtProc('cpybla')
     D  Receiver                       *   value
     D  Source                         *   value
     D  Size                         10i 0 value
     D* Put environment variable
     D PutEnv          pr            10i 0 ExtProc('putenv')
     D  EnvVar                         *   value options(*string)
     D rc              s             10i 0
     D* Sleep
     D Sleep           pr            10i 0 ExtProc('sleep')
     D  Seconds                      10u 0 value

      *----------------------------------------------------------------
      * program status area
      *----------------------------------------------------------------
     D parms          sds
     D  parmsL           *parms
     D  pgmnam           *proc

      *********************************************************************
*s5*  * JAVA std Objects and Methods
      *********************************************************************
      * generic String object
     D string          S               O   Class(*JAVA:'java.lang.String')
      * generic trimmed String object
     D tstring         S               O   Class(*JAVA:'java.lang.String')
      * Fine Name object
     D fileName        S               O   Class(*JAVA:'java.lang.String')
      * trimmed Fine Name object
     D tfileName       S               O   Class(*JAVA:'java.lang.String')
      * User Format object
     D usrformat       S               O   Class(*JAVA:'java.lang.String')
      * Cell Format object
     D cellformat      S               O   Class(*JAVA:'java.lang.String')
      * FileOutputStream.
     D outFile         S               O   Class(*JAVA
     D                                     :'java.io.FileOutputStream')
      * InputStream.
     D is              S               O   Class(*JAVA
     D                                     :'java.io.InputStream')
      * new String(byte[]) - String CONSTRUCTOR --------------------------
     D createString    PR              O   ExtProc(*JAVA:'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA:'java.lang.String')
     D string                     32000    const varying
      * new FileOutputStream(String file) - FileOutputStream CONSTRUCTOR --
     D createFile      PR              O   ExtProc(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'java.io.FileOutputStream')
     D file                            O   Class(*JAVA:'java.lang.String')
      * new FileInputStream(String file) - FileInputStream CONSTRUCTOR ----
     D FileInputStream...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'java.io.FileInputStream')
     D file                            O   Class(*JAVA:'java.lang.String')
      * java.lang.trim() --------------------------------------------------
     D trimString      PR              O   ExtProc(*JAVA:'java.lang.String'
     D                                     :'trim')
     D                                     Class(*JAVA:'java.lang.String')

      *********************************************************************
      * HSSF Objects
      *********************************************************************
      * FileStream --------------------------------------------------------
     D fs              S               O   Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
      * Workbook ----------------------------------------------------------
     D wb              S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      * Sheet -------------------------------------------------------------
     D sheet           S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      * Row ---------------------------------------------------------------
     D row             S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
      * Cell --------------------------------------------------------------
     D cell            S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
      * DataFormat --------------------------------------------------------
     D df              S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat')
      * Font --------------------------------------------------------------
     D font            S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Region ------------------------------------------------------------
     D region          S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
      * Style (2 dec + comma separators ) ---------------------------------
     D style2d         S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Bold) ------------------------------------------------------
     D styleBold       S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Align Center) ----------------------------------------------
     D styleAlignC     S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Hdr Bold) --------------------------------------------------
     D styleHdr        S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Hdr Align Center) ------------------------------------------
     D styleHdrC       S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * new POIFSFileSystem (InputStream) - FileSystem CONSTRUCTOR --------
     D createfs        PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
     D inpFile                         O   Class(*JAVA
     D                                     :'java.io.InputStream')
      * new HSSFWorkbook() - WorkBook CONSTRUCTOR -------------------------
     D createwb        PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      * new HSSFWorkbook(POIFSFileSystem fs) - WorkBook CONSTRUCTOR -------
     D openwb          PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
     D parm                            O   Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
      * new Region( int rowFrom, short colFrom, int rowTo, short colTo ) --
     D createRegion    PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
     D rowFrom                       10i 0 value
     D colFrom                        5i 0 value
     D rowTo                         10i 0 value
     D colTo                          5i 0 value

      *********************************************************************
      * HSSF Methods
      *********************************************************************
      * write(java.io.OutputStream) ---------------------------------------
     D writewb         PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'write')
     D workBook                        O   Class(*JAVA
     D                                     :'java.io.OutputStream')
      * WorkBook.createSheet() --------------------------------------------
     D createSheet     PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createSheet')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      * WorkBook.getSheetAt(index)-----------------------------------------
     D getSheetAt      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'getSheetAt')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
     D index                         10i 0 value
      * WorkBook.createCellStyle() ----------------------------------------
     D createCellStyle...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createCellStyle')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * WorkBook.createFont() ---------------------------------------------
     D createFont      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createFont')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Sheet.createRow(rownum) -------------------------------------------
     D createRow       PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'createRow')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
     D rownum                        10i 0 value
      * Sheet.getLastRowNum() ---------------------------------------------
     D getLastRowNum   PR            10i 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'getLastRowNum')
      * Sheet.setColumnWidth(column,width) --------------------------------
     D setColWidth     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setColumnWidth')
     D colnum                         5i 0 value
     D colwidth                       5i 0 value
      * Row.createCell() --------------------------------------------------
     D createCell      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'createCell')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
     D cellnum                        5i 0 value
      * Cell.setCellType(int) ---------------------------------------------
     D setCellType     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellType')
     D celltype                      10i 0 value
      * Cell.setCellValue(Number) -----------------------------------------
     D setCellValNum   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D cellvalue                      8f   value
      * Cell.setCellValue(String) -----------------------------------------
     D setCellValStr   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D cellvalue                       O   Class(*JAVA
     D                                     :'java.lang.String')
      * sheet.addMergedRegion( region ) -----------------------------------
     D addMergedRegion...
     D                 PR            10i 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'addMergedRegion')
     D region                          O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
      * Style.SetDataFormat(Format) ---------------------------------------
     D setDataFormat   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setDataFormat')
     D dataformat                     5i 0 value
      * Create DataFormat -------------------------------------------------
     D createDataFormat...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createDataFormat')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat')
      * GetFormat ---------------------------------------------------------
     D getFormat       PR             5i 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat'
     D                                     :'getFormat')
     D format                          O   Class(*JAVA
     D                                     :'java.lang.String')
      * Cell.setCellStyle(style) ------------------------------------------
     D setCellStyle    PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellStyle')
     D style                           O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Font.setBoldweight(short boldweight) ------------------------------
     D setBoldweight   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setBoldweight')
     D boldweight                     5i 0 value
      * Style.setFont(Font) -----------------------------------------------
     D setFont         PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setFont')
     D font                            O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Style.setAlignment(short align) -----------------------------------
     D setAlignment    PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setAlignment')
     D align                          5i 0 value
      * Style.setWrapText(boolean) ----------------------------------------
     D setWrapText     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setWrapText')
     D wrap                            n   value

      *********************************************************************
*s6*  * JVM/JNI section
      *********************************************************************
     D/Define OS400_JVM_12
     D/copy qsysinc/qrpglesrc,JNI
      * JNI environment ptr
     D env             s               *
      * get JNI environment ptr
     D getJniEnv       PR              *
      * free single object
     D freeJavaObject  PR
     D  env                            *   const
     D  javaObject                     O   CLASS(*JAVA:'java.lang.Object')
     D                                     value
      * begin a group of object
     D beginObjGroup   PR
     D  env                            *   const
     D  capacity                     10i 0 value
      * end a group of object
     D endObjGroup     PR
     D  env                            *   const

      *********************************************************************
      * Miscellaneous variables x Excel
      *********************************************************************
     D* Excel File name
     D XLSfile         S             63
     D* Row/Col counter
     D r               S             10i 0 Inz(0)
     D c               S             10i 0 Inz(0)
     D* Column width
     D ColWidth        s             10i 0 dim(1000)
     D* Custom Styles
     D usrFmt2d        S             24    Inz('#,##0.00')
     D styleFmt2d      S              5i 0
     D boldWeight      S              5i 0 Inz(700)
     D alignCenter     S              5i 0 Inz(2)
     D idxREgion       S             10i 0
     D* Cells
     D Cell_Alfa       s           1024
     D Cell_Pack       s             30p 0
     D Cell_Zone       s             30s 0
     D Cell_Float      s              8f
     D Cell_Short      s              5i 0
     D Cell_Int        s             10i 0
     D Cell_BigInt     s             20i 0
     D pCell_Pack      s               *
     D pCell_Zone      s               *

      *****************************************************************
      ** MAIN
      *****************************************************************

      /free

*sA*   // reformat the SQL statement
       SqlStmt = pSQLSTMT;
       psqlL = %checkr(' ':SqlStmt);
       for j = 1 to psqlL;
         select;
           when %subst(SqlStmt:j:1) = '"';
             %subst(SqlStmt:j:1) = '''';
           when %subst(SqlStmt:j:1) = '[';
             %subst(SqlStmt:j:1) = '"';
           when %subst(SqlStmt:j:1) = ']';
             %subst(SqlStmt:j:1) = '"';
         endsl;
       endfor;

       // display/log SQL statement
       If pLOGSQL = '*YES';
         msgdata = 'sql=>' + SqlStmt;
         // If interactive display as status msg
         QUSRJOBI (jobi0100:jobi_bytes:jobi_form:
                   jobi_jobn:jobi_jobi:Apierror);
         If jobi_type = 'I';
           msgtype = '*STATUS';
           msgmsgq = '*EXT';
           QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                     msgstack:msgkey:apierror);
           reset sndpgmmsg;
         EndIf;

         // send to joblog
         msgstack = 0;
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         // flag the message as received
         QMHRCVPM (rcv0100:msgbytes:msgformat:msgmsgq:msgstack:msgtyper:
                   msgkey:msgwait:msgaction:apierror);
       EndIf;

*sB*   // create the *sqlpkg If it does not exist
       ApiErrMsg = *blanks;
       objd_name = pgmnam + '*LIBL';
       objd_type = '*PGM';
       QUSROBJD (objd0100:objd_bytes:objd_form:objd_name:objd_type:apierror);
       mainlib = objd_rlib;
       ApiErrMsg = *blanks;
       pkgname = pgmnam;
       objd_name = pkgname + pkglib;
       objd_form = 'OBJD0100';
       objd_type = '*SQLPKG';
       QUSROBJD (objd0100:objd_bytes:objd_form:objd_name:objd_type:apierror);
       If ApiErrMsg = 'CPF9801';
         // prepara la sql template
         If pSQLLOCVAL = '*YES';
           exsr sq100setup;
         EndIf;
         namingopt = %subst(pNAMING:2:3);
         // crea il package
         ApiErrMsg = ' ';
         function = '1';
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
         If ApiErrMsg <> ' ';
           If pACTION = '*ESCAPE';
             %subst(msgfile:1:10) = 'QSQLMSG';
             QMHSNDPM (ApiErrMsg:msgfile:ApiErrDta:ApiErrLA-15:
                       '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
           else;
             *inlr = *on;
             return;
           EndIf;
         EndIf;
       EndIf;

       // allocate 20 elements
       nSQLDA = 20;
       szSQLDA = (nSQLDA * 80) + 16;
       pSQLDA = %alloc(szSQLDA);
       clear SQLDA;
       SQLN = nSQLDA;

*sC*   // prepare the SQL statement
       function = '2';
       openopt = x'80';
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       // If errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

       // describe the SQL into SQLDA
       function = '7';
       select;
         when pCOLHDRS = '*FLDNAM';
           claudesc = 'N';
         when pCOLHDRS = '*SQLLABEL';
           claudesc = 'L';
         when pCOLHDRS = '*ANY';
           claudesc = 'A';
         other;
           claudesc = 'N';
       endsl;
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       If SQLN <= SQLD;                  // reallocate If not enough
         nSQLDA = SQLD;
         szSQLDA = (nSQLDA * 80) + 16;
         pSQLDA = %alloc(szSQLDA);
         SQLN = nSQLDA;
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       EndIf;
       // only select statements are allowed
       If sqld = 0;
         SQLCODE = 0084;
       EndIf;
       // If there are errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

*sD*   // set CLASSPATH environment
       // rc = putenv('CLASSPATH=/excel/POI-2.0.jar');
       rc = putenv('CLASSPATH=/javaapps/poi-3.13/poi-3.13-20150929.jar');

       // Create a new workbook
       Monitor;
       // If there is a .xls template
       If pFROMXLS <> '*NONE';
         // put backslash in IFS style
         XLSFile = %trim(pFROMXLS);
         If %scan('\':XLSFile) > 0;
           For i=1 to %len(%trimr(XLSFile));
             if %subst(XLSFile:i:1) = '\';
               %subst(XLSFile:i:1) = '/';
             endif;
           EndFor;
         EndIf;
         // open the template
         fileName = createString(XLSFile);
         tfileName = trimString(fileName);
         is = FileInputStream(tfileName);
         fs = createfs(is);
         // open Workbook
         wb = openwb(fs);
         // open Worksheet
         sheet = getSheetAt(wb:0);
         r = getLastRowNum(sheet) + 2;
         env = getJniEnv();
         freeJavaObject(env:fileName);
         freeJavaObject(env:tfileName);
       else;
       // If build .xls from scratch
         // create an empty Workbook
         wb = createwb();
         // create an empty Worksheet
         sheet = createSheet(wb);
         env = getJniEnv();
         r = 0;
       EndIf;
       // monitor Java errors
       On-error *PROGRAM;
         QMHRCVPM (rcv0100:%len(rcv0100):'RCVM0200':'*':0:'*ESCAPE':
                   ' ':0:'*SAME':ApiError);
         If pACTION = '*ESCAPE';
           msgfile   = %subst(rcv0100:26:20);
           ApiErrMsg = %subst(rcv0100:13:7);
           %subst(RcvPgmMsg:1:4) = %subst(rcv0100:153:4);
           rcv0100 = %subst(rcv0100:177:msgbytes);
           QMHSNDPM (ApiErrMsg:msgfile:rcv0100:msgbytes:
                  '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
         else;
           *inlr = *on;
           return;
         EndIf;
       Endmon;

       // Start a group of objects
       beginObjGroup (env:1000000);

*sE*   // create 2d Style
       style2d     = createCellStyle(wb);

       // create Font object e set it Bold
       font = createFont(wb);
       setBoldweight(font:boldweight);

       // create a DataFormatter, a User Format and set the Style
       df = createDataFormat(wb);
       usrformat = createString(usrFmt2d);
       usrformat = trimString(usrformat);
       stylefmt2d = getFormat(df:usrformat);
       setDataFormat(style2d:stylefmt2d);

       // If requested, write a new row for sheet header
       If pTITLE <> '*NONE';
         // create a style for sheet header
         styleHdr  = createCellStyle(wb);
         setFont(styleHdr:font);
         setWrapText(styleHdr:*off);
         styleHdrC = createCellStyle(wb);
         setFont(styleHdrC:font);
         setAlignment(styleHdrC:alignCenter);
         setWrapText(styleHdrC:*off);
         // create a header row
         row = createRow(sheet:r);
         // add first column
         cell = createCell(row:0);
         setCellType(cell:0);                 // type 1=Character
         string = createString(pTITLE);       // create java string
         tstring = trimString(String);        // trim string
         setCellValStr(cell:tstring);         // set cell value
         freeJavaObject(env:string);
         freeJavaObject(env:tstring);
         If pTITLEALIGN = '*NONE';
           setCellStyle(cell:styleHdr);      // align left
         else;
           setCellStyle(cell:styleHdrC);    // align center
         endif;
         If pTITLECOLS = -1;
          pTITLECOLS = SQLD;
         endif;
         If pTITLECOLS > 1;
           // add more columns
           for c = 2 to pTITLECOLS;
             cell = createCell(row:c-1);
           endfor;
           // create a region
           region = createRegion(r:0:r:pTITLECOLS-1);
           // merge columns
           idxRegion = addMergedRegion(sheet:region);
         endif;
         // increase row counter
         r = r + 1;
       EndIf;

       // If requested, write a new row for column headers
       If pCOLHDRS <> '*NONE';
         // create a style for column header
         styleBold   = createCellStyle(wb);
         setFont(styleBold:font);
         styleAlignC = createCellStyle(wb);
         setAlignment(styleAlignC:alignCenter);
         setFont(styleAlignC:font);
         row = createRow(sheet:r);
         r = r + 1;
       EndIf;

*sF*   // write column hdrs and set the record buffer addresses into SQLDA
       pSQLVAR = %addr(SQL_VAR);
       od = 0;
       on = 0;

       for c = 1 to SQLD;

         // write column header
         If pCOLHDRS <> '*NONE';
           cell = createCell(row:c-1);
           Cell_Alfa = %subst(SQLNAME:1:SQLNAMELEN);
           j = %scan('\':Cell_Alfa);
           If j > 0;
             %subst(Cell_Alfa:j:1) = x'25';
             setWrapText(styleBold:*on);
             setWrapText(styleAlignC:*on);
           endif;
           setCellType(cell:1);                       // type 1=String
           string = createString(Cell_Alfa);          // create Java string
           tstring = trimString(string);              // trim string
           setCellValStr(cell:tstring);               // put string in cell
           freeJavaObject(env:string);
           freeJavaObject(env:tstring);
           If SQLTYPE >= 484 and SQLTYPE <= 489;      // If col is numeric
             setCellStyle(cell:styleAlignC);          // .. align center
           else;                                      // If col is string
             setCellStyle(cell:styleBold);            // .. just bold
           EndIf;

           // save column width (headers)
           If j > 0;
             If j > SQLNAMELEN - j;
               ColWidth(c) = j/(1/256) + 500;
             else;
               ColWidth(c) = (SQLNAMELEN - j)/(1/256) + 500;
             endif;
           else;
           ColWidth(c) = SQLNAMELEN/(1/256) + 500;
           endif;
         EndIf;

         // set record buffer address into SQLDA
         select;                                     // field Type
           when  SQLTYPE = 484 or SQLTYPE = 485 or   // .. Packed
                 SQLTYPE = 488 or SQLTYPE = 489;     // .. Signed
             aPrecis = Precis;
             cSQLLEN = pPrecis;
           when  SQLTYPE = 384 or SQLTYPE = 385;     // .. Date
             cSQLLEN = 10;
           when  SQLTYPE = 388 or SQLTYPE = 389;     // .. Time
             cSQLLEN = 10;
           when  SQLTYPE = 392 or SQLTYPE = 393;     // .. Timestamp
             cSQLLEN = 18;
           other;                                    // .. Char
             cSQLLEN = SQLLEN;
           endsl;

         SQLDATA = %addr(Record) + od;               // address for data
         SQLIND  = %addr(NullFields) + on;           // address for nullind

         // save column width (data)
         If cSQLLEN/(1/256) + 500 > ColWidth(c);
           ColWidth(c) = cSQLLEN/(1/256) + 500;
           If ColWidth(c) > 30000;
             ColWidth(c) = 30000;
           EndIf;
         EndIf;

         // point to next element
         od = od + cSQLLEN + 1;
         on = on + 2;
         pSQLVAR = pSQLVAR + 80;
       endfor;

*sG*   // open cursor
       function = '4';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // fetch records
       function = '5';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       dow SQLCODE = 0;
         // create a new Row
         row = createRow(sheet:r);
         //.. point to first element
         pSQLVAR = %addr(SQL_VAR);
         for c = 1 to SQLD;
           // create a new Cell
           cell = createCell(row:c-1);
           select;
             // null field
             when NullFields(c) = -1;
               setCellType(cell:1);                 // type 1=Character
               Cell_Alfa = *blank;
               string = createString(Cell_Alfa);    // create java string
               tstring = trimString(string);        // trim string
               setCellValStr(cell:tstring);         // set cell value
               freeJavaObject(env:string);
               freeJavaObject(env:tstring);
             // ... Packed
             when SQLTYPE = 484 or SQLTYPE = 485;
               Cell_Pack = 0;
               aPrecis = Precis;
               cSQLLEN = (pPrecis / 2) + 1;
               pCell_Pack = %addr(Cell_Pack) + 16 - cSQLLEN;
               Cpybla(pCell_Pack: SQLDATA: cSQLLEN);
               setCellType(cell:0);                 // type 0=Numeric
               If Scale <> x'00';
                 aScale = Scale;
                 setCellValNum(cell:Cell_Pack/10**pScale);
                 If pScale = 2;
                   setCellStyle(cell:style2d);      // edit figure
                 EndIf;
               else;
                 setCellValNum(cell:Cell_Pack);
               EndIf;
               cSQLLEN = pPrecis;
             // ... Signed
             when SQLTYPE = 488 or SQLTYPE = 489;
               Cell_Zone = 0;
               aPrecis = Precis;
               cSQLLEN = pPrecis;
               pCell_Zone = %addr(Cell_Zone) + 30 - cSQLLEN;
               Cpybla(pCell_Zone: SQLDATA: cSQLLEN);
               setCellType(cell:0);                 // type 0=Numeric
               If Scale <> x'00';
                 aScale = Scale;
                 setCellValNum(cell:Cell_Zone/10**pScale);
               else;
                 setCellValNum(cell:Cell_Zone);
               EndIf;
             // ... Short integer
             when SQLTYPE = 500 or SQLTYPE = 501;
               Cell_Short = 0;
               Cpybla(%addr(Cell_Short): SQLDATA: 2);
               setCellType(cell:0);                 // type 0=Numeric
               setCellValNum(cell:Cell_Short);
             // ... Large integer
             when SQLTYPE = 496 or SQLTYPE = 497;
               Cell_Int = 0;
               Cpybla(%addr(Cell_Int): SQLDATA: 4);
               setCellType(cell:0);                 // type 0=Numeric
               setCellValNum(cell:Cell_Int);
             // ... Big integer
             when SQLTYPE = 492 or SQLTYPE = 493;
               Cell_BigInt = 0;
               Cpybla(%addr(Cell_BigInt): SQLDATA: 8);
               setCellType(cell:0);                 // type 0=Numeric
               setCellValNum(cell:Cell_BigInt);
             // ... Date/Time
             when  SQLTYPE = 384 or SQLTYPE = 385 or
                   SQLTYPE = 388 or SQLTYPE = 389;
               Cell_Alfa = *blanks;
               Cpybla(%addr(Cell_Alfa): SQLDATA: 10);
               setCellType(cell:1);                 // type 1=Character
               string = createString(Cell_Alfa);    // create java string
               tstring = trimString(String);        // trim string
               setCellValStr(cell:tstring);         // set cell value
               freeJavaObject(env:string);
               freeJavaObject(env:tstring);
             // ... Timestamp
             when  SQLTYPE = 392 or SQLTYPE = 393;
               Cell_Alfa = *blanks;
               Cpybla(%addr(Cell_Alfa): SQLDATA: 18);
               setCellType(cell:1);                 // Type 1=character
               string = createString(Cell_Alfa);    // create java string
               tstring = trimString(String);        // trim string
               setCellValStr(cell:tstring);         // set cell value
               freeJavaObject(env:string);
               freeJavaObject(env:tstring);
             // ... Characters and other
             other;
               Cell_Alfa = *blanks;
               cSQLLEN = SQLLEN;
               Cpybla(%addr(Cell_Alfa): SQLDATA: cSQLLEN);
               setCellType(cell:1);                 // Type 1=character
               string = createString(Cell_Alfa);    // create java string
               tstring = trimString(String);        // trim string
               setCellValStr(cell:tstring);         // set cell value
               freeJavaObject(env:string);
               freeJavaObject(env:tstring);
           endsl;

           //.. point to next element
           pSQLVAR = pSQLVAR + 80;
         endfor;
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
         r = r + 1;
       enddo;

*sH*   // set the Column Width
       If r >= 1;
         for c = 1 to SQLD;
           setColWidth(sheet:c-1:ColWidth(c));
         endfor;
       EndIf;

       // close cursor
       function = '8';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // create the .Xls
       Monitor;
       XLSFile = %trim(pTOXLS);
       // put backslash in IFS style
       If %scan('\':XLSFile) > 0;
         For i=1 to %len(%trimr(XLSFile));
           if %subst(XLSFile:i:1) = '\';
              %subst(XLSFile:i:1) = '/';
           endif;
         EndFor;
       EndIf;
       fileName = createString(XLSFile);
       tfileName = trimString(fileName);
       outFile = createFile(tfileName);

       // write Workbook into .xls
       writewb(wb:outFile);

       // monitor Java errors
       On-error *PROGRAM;
         QMHRCVPM (rcv0100:%len(rcv0100):'RCVM0200':'*':0:'*ESCAPE':
                   ' ':0:'*SAME':ApiError);
         If pACTION = '*ESCAPE';
           msgfile   = %subst(rcv0100:26:20);
           ApiErrMsg = %subst(rcv0100:13:7);
           %subst(RcvPgmMsg:1:4) = %subst(rcv0100:153:4);
           rcv0100 = %subst(rcv0100:177:msgbytes);
           QMHSNDPM (ApiErrMsg:msgfile:rcv0100:msgbytes:
                  '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
         else;
           *inlr = *on;
           return;
         EndIf;
       Endmon;

       // end the group of Objects
       endObjGroup (env);

       // free Excel Java objects
       freeJavaObject(env:is);
       freeJavaObject(env:fs);
       freeJavaObject(env:wb);
       freeJavaObject(env:sheet);

       // send a completion message and return
       exsr ckretcode;
       msgtype  = '*COMP';
       msgstack = 1;
       QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                 msgstack:msgkey:apierror);
       *inlr = *on;
       return;

       // ------------------------------------------------------------------
       // Check sql return codes
       // ------------------------------------------------------------------
       begsr ckretcode;

       select;
          // error condition
          when SQLCODE < 0;
            msgtype = '*DIAG';
            //... cpf message
            If SQLER1 > 0;
              msgid = %editw(%dec(SQLER1:7:0):'0      ');
              %subst(msgid:1:3) = 'CPF';
            else;
            //... cpd message
              If SQLER2 > 0;
                msgid = %editw(%dec(SQLER2:7:0):'0      ');
                %subst(msgid:1:3) = 'CPD';
              else;
                msgid = %editw(%dec(SQLCODE*-1:7:0):'0      ');
                %subst(msgid:1:3) = 'SQL';
                %subst(msgfile:1:10) = 'QSQLMSG';
              EndIf;
            EndIf;
          // successful with warnings
          when SQLCODE > 0;
            msgid = %editw(%dec(SQLCODE:7:0):'0      ');
            %subst(msgid:1:3) = 'SQL';
            %subst(msgfile:1:10) = 'QSQLMSG';
          // successful execution
          other;
            msgid = 'SQL' + SQLER6;
            %subst(msgfile:1:10) = 'QSQLMSG';
       endsl;

       // message text
       If SQLERrml > 0;
         msgdata = SQLERrmc;
         msgdataL = SQLERrml;
       EndIf;

       // If interactive send a status message
       If jobi_type = 'I';
         msgtype  = '*STATUS';
         msgmsgq  = '*EXT';
         msgstack = 0;
         If msgid = 'SQL7959';
           msgid = 'SQL7977';
           %subst(msgdata:1:20) = 'SQL2XLS';
           %subst(msgdata:21:80) = %subst(pSQLSTMT:1:80);
           msgdataL = 100;
         EndIf;
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         rc = sleep(1);
         msgtype  = '*DIAG';
         msgmsgq  = '*';
       Endif;
       If SQLCODE <> 0 and pACTION = '*ESCAPE';
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:
                   '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
       EndIf;

       EndSr;

       // ------------------------------------------------------------------
       // Set date/time/sep from system values into SQLP0100
       // ------------------------------------------------------------------
       begsr sq100setup;

       QWCRSVAL (qsva_rcv:qsva_rcvL:qsva_sysL:qsva_sysv:apierror);
       for j = 1 to 4;
         jo = sysoff(j) + 1;
         %subst(qsva_rcv:jo) = sysvaltab(j);
       endfor;

       datefmt = sysvalue(1);
       datesep = sysvalue(2);
       timesep = sysvalue(3);
       If %subst(sysvalue(4):1:1) <> ' ';
         decpos = ',';
       EndIf;

       EndSr;

      /end-free

      *****************************************************************
      * Retrieve the JNIPtr
      *****************************************************************
     P getJniEnv       B
     D getJniEnv       PI              *
     D rc              S                   LIKE(jint)
     D jvm             S               *   DIM(1)
     D env             S               *
     D bufLen          S                   LIKE(jsize) INZ(%elem(jvm))
     D nVMs            S                   LIKE(jsize)
     D attachArgs      DS                  LIKEDS(JavaVMAttachArgs)
      /free
       rc = JNI_GetCreatedJavaVMs (jvm : bufLen : nVMs);
       // Assume JVM is running. Retrieve environment ptr
       If (rc = 0 and nVMs > 0);
         JavaVM_P = jvm(1);
         attachArgs = *allx'00';
         attachArgs.version = JNI_VERSION_1_2;
         rc = AttachCurrentThread (jvm(1) : env : %addr(attachArgs));
       endif;
       If (rc = 0);
       return env;
       else;
       return *NULL;
       endif;
      /end-free
     p getJniEnv       E

      *****************************************************************
      * free Java Object
      *****************************************************************
     p freeJavaObject  B
     D freeJavaObject  PI
     D  env                            *   const
     D  javaObject                     O   CLASS(*JAVA:'java.lang.Object')
     D                                     value
      /free
       JNIENV_P = env;
       If javaObject = *null or JNIEnv_P = *null;
         return;
       endif;
       DeleteLocalRef (JNIEnv_P:javaObject);
      /end-free
     p freeJavaObject  E

      *****************************************************************
      * begin object group
      *****************************************************************
     P beginObjGroup   B
     D beginObjGroup   PI
     D  env                            *   const
     D  capacity                     10i 0 value
     D rc              s             10i 0
      /free
       JNIENV_P = env;
       rc = pushLocalFrame (JNIENV_P : capacity);
      /end-free
     p beginObjGroup   E

      *****************************************************************
      * end a group of object
      *****************************************************************
     p endObjGroup     B
     D endObjGroup     PI
     D  env                            *   const
     D rc              s             10i 0
     D refobject       s               O   CLASS(*JAVA:'java.lang.Object')
     D newobject       s               O   CLASS(*JAVA:'java.lang.Object')
      /free
       JNIENV_P = env;
       refObject = *null;
       newObject = popLocalFrame (JNIENV_P : refObject);
      /end-free
     p endObjGroup     E
