  CMD   PROMPT('SQL to Excel')

  PARM KWD(SQLSTMT)    TYPE(*CHAR) LEN(5000) MIN(1) +
                       EXPR(*YES) PROMPT('SQL statement')

  PARM KWD(TOXLS)      TYPE(*CHAR) LEN(63) MIN(1) +
                       EXPR(*YES) PROMPT('To Xls')

  PARM KWD(FROMXLS)    TYPE(*CHAR) LEN(63) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('From Xls')

  PARM KWD(COLHDRS)    TYPE(*CHAR) LEN(10) RSTD(*YES) +
                       DFT(*NONE) VALUES(*NONE *FLDNAM *SQLLABEL *ANY) +
                       MIN(0) EXPR(*YES) PROMPT('Column headers')

  PARM KWD(TITLE)      TYPE(*CHAR) LEN(120) DFT(*NONE) +
                       MIN(0) EXPR(*YES) PROMPT('Sheet title')

  PARM KWD(TITLECOLS)  TYPE(*INT2) DFT(*COLS) RANGE(1 20) +
                       SPCVAL((*COLS -1)) EXPR(*YES) +
                       PROMPT('Title columns')

  PARM KWD(TITLEALIGN) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                       DFT(*NONE) VALUES(*NONE *CENTER) +
                       EXPR(*YES) PROMPT('Title alignment')

  PARM KWD(NAMING)     TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*SYS) SPCVAL((*SYS ) (*SQL )) +
                       PMTCTL(*PMTRQS) PROMPT('Naming')

  PARM KWD(ACTION)     TYPE(*CHAR) LEN(9) RSTD(*YES) +
                       DFT(*CONTINUE) SPCVAL((*CONTINUE) (*ESCAPE)) +
                       PMTCTL(*PMTRQS) PROMPT('Action on error')

  PARM KWD(LOGSQL)     TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*YES) VALUES(*YES *NO) +
                       PMTCTL(*PMTRQS) PROMPT('Log SQL command')

  PARM KWD(SQLLOCVAL)  TYPE(*CHAR) LEN(4) RSTD(*YES) +
                       DFT(*NO) VALUES(*YES *NO) PMTCTL(*PMTRQS) +
                       PROMPT('Use local SQL sys values')
