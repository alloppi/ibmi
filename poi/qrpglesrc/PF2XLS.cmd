 /*   CRTCMD CMD(ALAN/PF2XLS)           */
 /*          PGM(ALAN/PF2XLSR)          */
 /*          SRCFILE(ALAN/POI313)       */
 /*          VLDCKR((ALAN/PF2XLSV)      */

  CMD                  PROMPT('Generate Excel from PF')

  PARM KWD(FILE)       TYPE(QUAL1) MIN(1) PROMPT('File')
/*PARM KWD(MEMBER)     TYPE(*NAME) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Member') */

  PARM KWD(EXCELPATH)  TYPE(*CHAR) LEN(32) DFT('/tmp/') MIN(0) +
                       PROMPT('Excel path')

  PARM KWD(EXCELNAME)  TYPE(*CHAR) LEN(20) DFT('yourexcel.xlsx') +
                       CASE(*MIXED) PROMPT('  Filename')

/*PARM KWD(COLHDR)     TYPE(*CHAR) LEN(7) RSTD(*YES) +
                       DFT(*NONE) VALUES(*NONE *FLDNAM *TEXT) +
                       MIN(0) EXPR(*YES) PROMPT('Column Header')       */

/*PARM KWD(TITLE)      TYPE(*CHAR) LEN(50) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('Sheet Title')         */

/*PARM KWD(TITLECOL)   TYPE(*INT4) DFT(*COLS) RANGE(1 20) +
                          SPCVAL((*COLS -1)) EXPR(*YES) +
                          PROMPT('Title columns')                      */

/*PARM KWD(TITLEALIGN) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                       DFT(*NONE) VALUES(*NONE *CENTER) +
                       EXPR(*YES) PROMPT('  Alignment')                */

/*PARM KWD(ACTION)     TYPE(*CHAR) LEN(9) RSTD(*YES) +
                       DFT(*CONTINUE) SPCVAL((*CONTINUE) (*ESCAPE)) +
                       PMTCTL(*PMTRQS) PROMPT('Action on Error')       */

/*PARM KWD(LOG)        TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*YES) VALUES(*YES *NO) +
                       PMTCTL(*PMTRQS) PROMPT('Log Command')           */

  QUAL1:    QUAL       TYPE(*NAME) LEN(10)
            QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')

