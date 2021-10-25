      *=============================================================================*
      * Program name: SPL2TIFFR                                                     *
      * Purpose.....: Convert Spool File to Tag Image Format File                   *
      * Limitation..: Cannot handle spool file larger than 16M.                     *
      * Web Refer...:                                                               *
      *   http://search400.techtarget.com/tip/Convert-spool-file-to-image-file      *
      * Compilation.:                                                               *
      *   CRTRPGMOD MODULE(ACTEMP/SPL2TIFFR) SRCFILE(ALAN/QRPGTIF)                  *
      *   CRTPGM PGM(ACTEMP/SPL2TIFFR) BNDSRVPGM(QWPZHPT1) BNDDIR(QC2LE)           *
      *                                                                             *
      * Modification:                                                               *
      * Date       Name       Pre  Ver  Mod#  Remarks                               *
      * ---------- ---------- --- ----- ----- ---------------------------           *
      *=============================================================================*
      * User Space Error Code
     DQUSEC            DS
     D* Qus EC
     D QUSBPRV                 1      4B 0
     D* Bytes Provided
     D QUSBAVL                 5      8B 0
     D* Bytes Available
     D QUSEI                   9     15
     D* Exception Id
     D QUSERVED               16     16
     D* Reserved
     D*QUSED01 17 17
     D* Varying length
     D*
      * Retreive error information
     Dgeterrinfo       PR           128
      * SEND program message with Color ....
      * Host Print Transform  API
     Dhpt              PR                  EXTPROC('QwpzHostPrintTransform')
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
      * Option Specific input/output information
     DQWPPTOSI         DS
     D* Qwpz HPT Opt SpecIn
     D QWPRSV1                 1     16
     D* Reserved 1
     D QWPRSV2                17     26
     D* Reserved 2
     D QWPPDN                 27     36
     D* Printer Device Name
     D QWPRSV3                37     56
     D* Reserved 3
     D QWPRSV4                57     76
     D* Reserved 4
     D QWPRSV5                77     86
     D* Reserved 5
     D QWPRSV6                87     96
     D* Reserved 6
     D QWPIJID                97    112
     D* Int Job ID
     D QWPISID               113    128
     D* Int Splf ID
     D QWPJN                 129    138
     D* Job Name
     D QWPUN                 139    148
     D* Usr Name
     D QWPJNBR               149    154
     D* Job Number
     D QWPSN                 155    164
     D* Splf Name
     D QWPSNBR               165    168B 0
     D* Splf Number
     D QWPRSV7               169    180
     D* Reserved 7
     D QWPRSV8               181    184B 0
     D* Reserved 8
     D QWPRSV9               185    188B 0
     D* Reserved 9
     D QWPRSV10              189    198
     D* Reserved 10
     D QWPRAD                199    199
     D* Return Align Data
     D QWPRSV11              200    204
     D* Reserved 11
     D QWPNBRCP              205    208B 0
     D* Number Complete Pages
     D QWPWCOBJ              209    218
     D* Workstation Cust Object
     D QWPWCOL               219    228
     D* Workstation Cust Object Lib
     D QWPMTM                229    243
     D* Manufacturer Type Model
     D QWPPS1                244    253
     D* Paper Source 1
     D QWPPS2                254    263
     D* Paper Source 2
     D QWPES                 264    273
     D* Envelope Source
     D**************************************************
     D*Structure for Option specific output information
     D**************************************************
     DQWPPTOSO         DS
     D* Qwpz HPT Opt SpecOut
     D QWPRSV100               1      4B 0
     D* Reserved 1
     D QWPTFIL                 5      5
     D* Transform File
     D QWPPID                  6      6
     D* Pass Input Data
     D QWPRSV200               7      8
     D* Reserved 2
     D QWPDTFIL                9      9
     D* Done Transforming File
     D QWPRSV300              10     12
     D* Reserved 3
     D QWPVPCO                13     16B 0
     D* Vertical Pos Command Offset
     D QWPVPCL                17     20B 0
     D* Vertical Pos Command Length
     D QWPPDO                 21     24B 0
     D* Print Data Offset
     D QWPPDL                 25     28B 0
     D* Print Data Length
     D QWPCRCO                29     32B 0
     D* Carriage Return Command Offs
     D QWPCRCL                33     36B 0
     D* Carriage Return Command Leng
     D QWPFFCO                37     40B 0
     D* Form Feed Command Offset
     D QWPFFCL                41     44B 0
     D* Form Feed Command Length
      * variables for Host Print Transform API
     Dhptopt           S              9B 0
     Dhptosilen        S              9B 0 INZ(%LEN(QWPPTOSI))
     Dhptsplbuflen     S              9B 0
     Dhptosolen        S              9B 0 INZ(%LEN(QWPPTOSO))
     Dhptosolena       S              9B 0
     Dxbufspc_p        S               *
     D*hptxbuflen       S              9B 0 INZ(200000)
     Dhptxbuflen       S              9B 0 INZ(300000)
     Dhptxbuflena      S              9B 0
      * Size of user space
     Dspc_size         S              9B 0
      * Stream file APIs
     Dunlink           PR             9B 0 EXTPROC('unlink')
     D                                 *   VALUE
     Dopen             PR            10I 0 EXTPROC('open')
     D                                 *   VALUE
     D                               10I 0 VALUE
     D                               10U 0 VALUE OPTIONS(*NOPASS)
     D                               10U 0 VALUE OPTIONS(*NOPASS)
     D O_CREAT         S             10I 0 INZ(8)
     D O_WRONLY        S             10I 0 INZ(2)
     D O_TRUNC         S             10I 0 INZ(64)
     D O_CODEPAGE      S             10I 0 INZ(8388608)
     D S_IRWXU         S             10I 0 INZ(448)
     D S_IROTH         S             10I 0 INZ(4)
     **************************************
     Dwrite            PR            10I 0 EXTPROC('write')
     **************************************
     D                               10I 0 VALUE
     D                                 *   VALUE
     D                               10I 0 VALUE
     Dclose            PR            10I 0 EXTPROC('close')
     D                               10I 0 VALUE
      *
     Dfd               S             10I 0
     Dbytesw           S             10I 0
     DTiff             S            257
     **************************************
      * 'QSPOPNSP/QSPGETSP/QSPCLOSP' spool file APIs variables
     **************************************
     Dspl_hdl          S              9B 0
     Dspl_nbr_b        S              9B 0
     Dspl_bufnbr       S              9B 0
     **************************************
      * Get Spooled File Data
     **************************************
     D QSPGETSP        C                   'QSPGETSP'
     DQSPSPFRH         DS
     D* Qsp SPFRH
     D QSPUD                   1     64
     D* User Data
     D QSPHS                  65     68B 0
     D* Header Size
     D QSPSL                  69     72
      * Struc Level
     D QSPSFILL               73     78
     D* Spooled File Level
     D QSPFN                  79     86
     D* Format Name
     D QSPICI                 87     87
     D* Info Complete Ind
     D QSPRSV1                88     88
     D* Reserved1
     D QSPUSU                 89     92B 0
     D* User Space Used
     D QSPOFB                 93     96B 0
     D* Offset First Buffer
     D QSPBR00                97    100B 0
     D* Buffers Requested
     D QSPBRTN01             101    104B 0
     D* Buffers Returned
     D QSPPD300              105    108B 0
     D* Size Print Data300
     D QSPNCP                109    112B 0
     D* Nbr Comp Pages
     D QSPFPN                113    116B 0
     D* First Page Nbr
     D QSPOFP                117    120B 0
     D* Offset First Page
     D QSPRSV200             121    128
     D* Reserved2
     D****************************************************************
     D*Structure for Generic Header Section
     D****************************************************************
     DQSPSPFRB         DS
     D* Qsp SPFRB
     D QSPLBI                  1      4B 0
     D* Length Buffer Info
     D QSPBNBR                 5      8B 0
     D* Buffer Number
     D QSPOGI                  9     12B 0
     D* Offset General Info
     D QSPSGI                 13     16B 0
     D* Size General Info
     D QSPOPD                 17     20B 0
     D* Offset Page Data
     D QSPSPD                 21     24B 0
     D* Size Page Data
     D QSPNBRPE               25     28B 0
     D* Number Page Entries
     D QSPSPE                 29     32B 0
     D* Size Page Entry
     D QSPOPD00               33     36B 0
     D* Offset Print Data
     D QSPSPD00               37     40B 0
     D* Size Print Data
     D****************************************************************
     D*Structure for General Data Section
     D****************************************************************
     DQSPSPFRG         DS
     D* Qsp SPFRG
     D QSPNNL                  1      4B 0
     D* Nbr Nonblank Lines
     D QSPNLP1                 5      8B 0
     D* Nonblank Lines Page1
     D QSPEBNBR                9     12B 0
     D* Error Buffer Number
     D QSPOER                 13     16B 0
     D* Offset Error Recovery
     D QSPPDS                 17     20B 0
     D* Print Data Size
     D QSPSTATE               21     30
     D* State
     D QSPLPC                 31     31
     D* Last Page Continues
     D QSPAPF                 32     32
     D* Advanced Print Func
     D QSPACAIB               33     33
     D* LAC Array in Buffer
     D QSPACIAB               34     34
     D* LAC in Any Buffer
     D QSPACIEI               35     35
     D* LAC in Error Info
     D QSPERI                 36     36
     D* Error Recovery Info
     D QSPZP                  37     37
     D* Zero Pages
     D QSPLF                  38     38
     D* Load Font
     D QSPIPDSD               39     39
     D* IPDS Data
     D QSPERVED01             40     44
     D* Reserved
     D****************************************************************
     D*Structure for Page Data Section
     D****************************************************************
     DQSPSPFRP         DS
     D* Qsp SPFRP
     D QSPTDS                  1      4B 0
     D* Text Data Start
     D QSPADS                  5      8B 0
     D* Any Data Start
     D QSPPO                   9     12B 0
     D* Page Offset
     Dgen_hdr          S            128    BASED(splspc_p)
     Dbuf_inf          S             40    BASED(bufp)
     Dbuf_inf2         S             44    BASED(bufp2)
     Dsplbuf           S           5000    BASED(splbuf_p)
     D****************************************************************
     D*Misc
     D****************************************************************
     Dmsg_data         S            256
     DEnd_time         S               Z
     DWrk_Splf         S                   Like(P00_Splf)
     DP01_Message      S             78
     DP01_Color        S              1
     D****************************************************************
     D* Main - Main Processing Engine
     D****************************************************************
     C     *Entry        Plist
     C                   Parm                    P00_Splf         10
     C                   Parm                    P00_Job          26
     C                   Parm                    P00_Nbr           4 0
     C                   Parm                    P00_TiffP       128
     C                   Parm                    P00_FReplace      4
      *
      * Initialize
     C                   ExSr      Init
      * Prepare user space
     C                   ExSr      UserSpacePrep
      * Retrieve spool file
     C                   ExSr      GetSpoolFile
      * Create stream file
     C                   ExSr      OpenStreamF
      *
      * Run HTP Engine for converting the spool data to TIFF Data.
      * Start HPT Engine.
      *
     C                   Eval      hptopt = 10
     C                   ExSr      HPTEngine
      * Run HPT Engine to Process file.
     C                   Eval      hptopt = 20
     C                   ExSr      HPTEngine
      * set pointer to first buffer
     C                   Eval      bufp = splspc_p + QSPOFB
      * loop thru buffer
     C                   Do        QSPBRTN01
      * retrieve 'Buffer information'
     C                   Eval      QSPSPFRB = buf_inf
      * set pointer to 'offset to general information buffer'
     C                   Eval      bufp2 = splspc_p + QSPOGI
      * retrieve 'General data (information buffer)'
     C                   Eval      QSPSPFRG = buf_inf2
      * Run HPT Engine to Transform Data.
     C                   Eval      hptopt = 30
     C                   ExSr      HPTEngine
      * increment pointer by 'length of all buffer information'
     C                   Eval      bufp = bufp + QSPLBI
     C                   EndDo
      * Run HPT Engine to End Processing the file.
     C                   Eval      hptopt = 40
     C                   ExSr      HPTEngine
      * Stop HPT Engine.
     C                   Eval      hptopt = 50
     C                   ExSr      HPTEngine
      * Close Stream File
     C                   ExSr      CloseStreamF
      * End program
     C                   Eval      *InLR = *On
     C                   Return
      ****************************************************************
      * Init - Perform initialisation operations
      ****************************************************************
     C     Init          BegSr
      *
      * Remember start time
     C                   Z-Add     16            QUSBPRV
     C                   Eval      Wrk_Splf = P00_Splf
      *
     C                   EndSr
      *****************************************************************
      * Create User Space to Retrieve Spool Data
      *****************************************************************
     C     UserSpacePrep BegSr
      *
     C                   Eval      splspc_name = 'QSPGETSP  QTEMP'
      * Create User Space.
     C                   Call      'QUSCRTUS'
     C                   Parm                    splspc_name      20
     C                   Parm      *Blanks       spc_attr         10
     C                   Parm      1024          spc_size
     C                   Parm      X'00'         spc_init          1
     C                   Parm      '*CHANGE'     spc_aut          10
     C                   Parm      'SPL2TIFFR'   spc_text         50
     C                   Parm      '*NO'         spc_replace      10
     C                   Parm                    QUSEC
     C                   Parm      '*USER'       spc_Domain       10
      *
     C                   If        QUSBAVL > 0
     C                   If        QUSEI <> 'CPF9870'
     C                   Eval      msg_data = 'API QUSCRTUS failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
     C                   EndIf
      * Retrieve pointer to user space
      *
     C                   Call      'QUSPTRUS'
     C                   Parm                    splspc_name
     C                   Parm                    splspc_p
     C                   Parm                    QUSEC
      *
     C                   If        QUSBAVL > 0
     C                   Eval      msg_data = 'API QUSPTRUS failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
      *
      * Create user space for translation
      *
     C                   Eval      xbufspc_name = 'QWPZHPT1  QTEMP'
      *
     C                   Call      'QUSCRTUS'
     C                   Parm                    xbufspc_name     20
     C                   Parm      *Blanks       spc_attr
     C                   Parm      200000        spc_size
     C                   Parm      X'00'         spc_init
     C                   Parm      '*CHANGE'     spc_aut
     C                   Parm      'SPL2TIFFR'   spc_text
     C                   Parm      '*NO'         spc_replace
     C                   Parm                    QUSEC
     C                   Parm      '*USER'       spc_Domain
      *
     C                   If        QUSBAVL > 0
     C                   If        QUSEI = 'CPF9870'
     C                   Else
     C                   Eval      msg_data = 'API QUSCRTUS failed (Traslate): '
     C                                + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
     C                   EndIf
      * Retrieve pointer to user space
     C                   Call      'QUSPTRUS'
     C                   Parm                    xbufspc_name
     C                   Parm                    xbufspc_p
     C                   Parm                    QUSEC
      *
     C                   If        QUSBAVL > 0
     C                   Eval      msg_data = 'API QUSPTRUS failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
      *
     C                   EndSr
      *****************************************************************
      * Get Spool File Information.
      *****************************************************************
     C     GetSpoolFile  BegSr
      *
      * Open spool file
     C                   Call      'QSPOPNSP'
     C                   Parm                    spl_hdl
     C                   Parm                    P00_Job          26
     C                   Parm      *Blanks       spl_ijobi        16
     C                   Parm      *Blanks       spl_ispli        16
     C                   Parm                    Wrk_Splf
     C                   Parm      P00_Nbr       spl_nbr_b
     C                   Parm      -1            spl_bufnbr
     C                   Parm                    QUSEC
      *
     C                   If        QUSBAVL > 0
     C                   Eval      msg_data = 'API QSPOPNSP failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
      * Get spool data
     C                   Call      'QSPGETSP'
     C                   Parm                    spl_hdl
     C                   Parm                    splspc_name
     C                   Parm      'SPFR0200'    fmt_name          8
     C                   Parm      -1            spl_bufnbr
     C                   Parm      '*WAIT '      spl_End          10
     C                   Parm                    QUSEC
      *
     C                   If        QUSBAVL > 0
     C                   Eval      msg_data = 'API QSPGETSP failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
      * retrieve 'General header'
     C                   Eval      QSPSPFRH = gen_hdr
      * Close spool file
     C                   Call      'QSPCLOSP'
     C                   Parm                    spl_hdl
     C                   Parm                    QUSEC
      *
     C                   If        QUSBAVL > 0
     C                   Eval      msg_data = 'API QSPCLOSP failed : ' + QUSEI
     C                   ExSr      PSSR
     C                   EndIf
      *
     C                   If        QSPICI <> 'C'
     C                   Eval      msg_data = 'Cannot process sppoled file ' +
     C                               'larger than 16M.'
     C                   ExSr      PSSR
     C                   EndIf
      *
     C                   EndSr
      *****************************************************************
      * Run the Host Print Transform(HPT) Engine
      *****************************************************************
     C     HPTEngine     BegSr
      * Clear option specIfic I/O information
     C                   Clear                   QWPPTOSI
     C                   Clear                   QWPPTOSO
      * API parameters
     C                   Eval      splbuf_p = splspc_p
     C                   Eval      hptsplbuflen = 0
     C                   Eval      hptosolena = 0
     C                   Eval      hptxbuflena = 0
      * Set parameters for QWPZHPTR
     C                   Select
      * 10 = initialize HPT
      * (no further parameters required)
      * 20 = process file
     C                   When      hptopt = 20
      * Option specIfic input information
     C                   Eval      QWPPDN = '*NONE'
     C                   Eval      QWPJN = %SubSt(P00_Job : 1 : 10)
     C                   Eval      QWPUN = %SubSt(P00_Job : 11 : 10)
     C                   Eval      QWPJNBR = %SubSt(P00_Job : 21 : 6)
     C                   Eval      QWPSNBR = P00_Nbr
     C                   Eval      QWPSN = Wrk_Splf
     C                   Eval      QWPRAD = '0'
     C                   Eval      QWPWCOBJ = 'TIFF'
     C                   Eval      QWPWCOL = '*LIBL'
     C                   Eval      QWPMTM = '*WSCST'
      * 30 = transform data
     C                   When      hptopt = 30
      * Option specIfic input information
     C                   Eval      QWPRAD = '0'
      * Adjust page number
     C                   Eval      QWPNBRCP = QSPNBRPE
     C                   Add       QSPNBRPE      total_pages       9 0
     C                   If        QSPBNBR = 1
     C                   If        (QSPNBRPE > 0) AND (QSPLPC = 'Y')
     C                   Sub       1             QWPNBRCP
     C                   EndIf
     C                   Else
     C                   If        QSPLPC = 'N'
     C                   Add       1             QWPNBRCP
     C                   EndIf
     C                   EndIf
      * API parameters
     C                   Eval      splbuf_p = splspc_p + QSPOPD00
     C                   Eval      hptsplbuflen = QSPSPD00
      * 40 = End file
      * (no further parameters required)
      * 50 = terminate HPT
      * (no further parameters required)
     C                   EndSL
      * perform HPT
     C                   ExSr      CallHPT
     C                   If        hptopt = 30
      * Increment counter
     C                   Add       1             counter           7 0
     C                   If        counter >= 5
     C                   Eval      P01_Message = %TRIMR(%Char(total_pages)) +
     C                               ' pages processed. (' + %TRIMR(
     C                             %Char((QSPBNBR / QSPBRTN01) * 100))
     C                   Eval      P01_Color = 'B'
     C                   Call      'CLRPGMMSG'
     C                   Parm                    P01_Message
     C                   Parm                    P01_Color
     C                   Z-Add     0             counter
     C                   EndIf
     C                   EndIf
     C                   If        QUSBAVL > 0
      * retry hpt If CPF6DF5 (process option parameter not valid)
     C  N99              If        (QUSEI = 'CPF6DF5') AND (hptopt = 10)
      * avoid loop
     C                   SETON                                        99
      * terminate HTP then try again
     C                   Eval      hptopt = 50
     C                   ExSr      CallHPT
     C                   Eval      hptopt = 10
     C                   Clear                   QWPPTOSI
     C                   Clear                   QWPPTOSO
     C                   ExSr      CallHPT
     C                   Else
      * reset hpt and exit
     C                   Eval      msg_data = 'API QwpzHostPrintTransform ' +
     C                               'failed : ' + QUSEI + ' hptopt = ' +
     C                               %TRIM(%EDITC(hptopt:'J'))
     C                   Eval      hptopt = 50
     C                   ExSr      CallHPT
     C                   ExSr      PSSR
     C                   EndIf
     C                   EndIf
      * write data to stream file
     C                   If        hptxbuflena > 0
     C                   Eval      bytesw = write(fd : xbufspc_p : hptxbuflena)
     C                   If        bytesw <> hptxbuflena
     C                   Eval      msg_data = 'write() failed. ' + geterrinfo
     C                   ExSr      PSSR
     C                   EndIf
     C                   EndIf
      *
     C                   EndSr
      *****************************************************************
      * Call Host Print Transform(HPT) API.
      *****************************************************************
     C     CallHPT       BegSr
      * Perform HPT
     C                   CallP     hpt(%Addr(hptopt) :
     C                                 %Addr(QWPPTOSI) :
     C                                 %Addr(hptosilen) :
     C                                 splbuf_p :
     C                                 %Addr(hptsplbuflen) :
     C                                 %Addr(QWPPTOSO) :
     C                                 %Addr(hptosolen) :
     C                                 %Addr(hptosolena) :
     C                                 xbufspc_p :
     C                                 %Addr(hptxbuflen) :
     C                                 %Addr(hptxbuflena) :
     C                                 %Addr(QUSEC))
      *
     C                   EndSr
      *****************************************************************
      * Create/Open Stream File.
      *****************************************************************
     C     OpenStreamF   BegSr
      *
     C                   Eval      Tiff = %TRIM(P00_TiffP) + X'00'
      * Check whether stream file exists or not.
     C                   Eval      fd = open(%Addr(Tiff) : 1)
      *
      * If Stream file exists, close the stream file and check if replace
      * option was specified. If replace, then unlink the stream file.
      *
     C                   If        fd <> -1
     C                   If        -1 = close(fd)
     C                   Eval      msg_data = 'close() failed. ' + geterrinfo
     C                   ExSr      PSSR
     C                   EndIf
      * replace(*yes) specIfied?
     C                   If        P00_FReplace = '*YES'
     C                   If        -1 = unlink(%Addr(Tiff))
     C                   Eval      msg_data = 'unlink() failed. ' + geterrinfo
     C                   ExSr      PSSR
     C                   Else
     C                   Eval      P01_Message = 'Stream file ' +
     C                               %TRIMR(P00_TiffP) +
     C                               ' removed.'
     C                   Eval      P01_Color = 'R'
     C                   Call      'CLRPGMMSG'
     C                   Parm                    P01_Message
     C                   Parm                    P01_Color
     C                   EndIf
     C                   Else
     C                   Eval      msg_data = 'file already exists.'
     C                   ExSr      PSSR
     C                   EndIf
     C                   Else
     C                   EndIf
      * Open(Create) stream file
     C                   Eval      fd = open(%Addr(Tiff)
     C                               : O_CREAT + O_WRONLY + O_TRUNC + O_CODEPAGE
     C                               : S_IRWXU + S_IROTH
     C                               : 819)
     C                   If        fd = -1
     C                   Eval      msg_data = 'open() failed. ' + geterrinfo
     C                   ExSr      PSSR
     C                   EndIf
      *
     C                   EndSr
      *****************************************************************
      * Close Stream File
      *****************************************************************
     C     CloseStreamF  BegSr
      * Close stream file
     C                   If        -1 = close(fd)
     C                   Eval      msg_data = 'close() failed. ' + geterrinfo
     C                   ExSr      PSSR
     C                   EndIf
      *
     C                   Eval      P01_Message = 'Stream file generated ' +
     C                                 'sucessfully. '
     C                   Eval      P01_Color = 'Y'
     C                   Call      'CLRPGMMSG'
     C                   Parm                    P01_Message
     C                   Parm                    P01_Color
      *
     C                   EndSr
      *****************************************************************
     C     PSSR          BegSr
      * abort
     C                   Eval      P01_Message = 'Command failed. reason - ' +
     C                                msg_data
     C                   Eval      P01_Color = 'R'
     C                   Call      'CLRPGMMSG'
     C                   Parm                    P01_Message
     C                   Parm                    P01_Color
     C                   Eval      *INLR = *On
     C                   Return
      *
     C                   EndSr
      *****************************************************************
     Pgeterrinfo       B
     Dgeterrinfo       PI           128
      *
     Dgeterrno         PR              *   EXTPROC('__errno')
      *
     Dstrerror         PR              *   EXTPROC('strerror')
     D errno                         10I 0 VALUE
      *
     Derrnum           S             10I 0 BASED(errnum_p)
      *
     C                   Eval      errnum_p = geterrno
      *
     C                   Return    %TRIM(%EDITC(errnum : '3')) + ' : ' +
     C                               %STR(strerror(errnum))
     Pgeterrinfo       E
