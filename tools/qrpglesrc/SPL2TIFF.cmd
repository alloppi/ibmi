/*=========================================================================*/
/* Program name: SPL2TIFF                                                  */
/* Purpose.....: Spool File to TIFF File                                   */
/*               CRTCMD CMD(MYLIB/SPL2TIFF) PGM(MYLIB/SPL2TIFFR)           */
/*                 SRCFILE(MYLIB/QCMDSRC) SRCMBR(SPL2TIFF)                 */
/* Modification:                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                           */
/* ---------- ---------- --- ----- ----- ----------------------------      */
/*=========================================================================*/
             CMD        PROMPT('CONVERT SPOOL TO TIFF FILE')
             PARM       KWD(FILE) TYPE(*NAME) MIN(1) MAX(1) +
                          FILE(*OUT) EXPR(*YES) PROMPT('SPOOLED +
                          FILE NAME')

             PARM       KWD(JOB) TYPE(Q2) DFT(*) SNGVAL((* *N)) +
                          MAX(1) PROMPT('JOB NAME')
 Q2:         QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES) +
                          PROMPT('USER NAME')
             QUAL       TYPE(*CHAR) LEN(6) RANGE(000000 999999) +
                          SPCVAL((' ' *N)) EXPR(*YES) PROMPT('JOB + +
                          NUMBER')

             PARM       KWD(SPLNBR) TYPE(*DEC) LEN(4) DFT(*LAST) +
                          RANGE(1 9999) SPCVAL((*ONLY 0) (*LAST +
                          -1)) PROMPT('SPOOLED FILE NUMBER')

             PARM       KWD(TOTIFF) TYPE(*PNAME) LEN(128) MIN(1) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('STREAM +
                          FILE NAME')

             PARM       KWD(REPLACE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('REPLACE STREAM FILE')
