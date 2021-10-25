/*===================================================================*/
/* Program name: DSPAUTLIB                                           */
/* Purpose.....: Display Authority of All Objects in a Library       */
/*                                                                   */
/* Remarks     : Compiled this command with PGM(DSPAUTLIBC)          */
/*                                                                   */
/* Modification:                                                     */
/* Date       Name       Pre  Ver  Mod#  Remarks                     */
/* ---------- ---------- ---- ---- ----- --------------------------- */
/* 2013/01/04 Alan       AC        04769 New Develop                 */
/*===================================================================*/
             CMD        PROMPT('Display Obj Authority in Lib')

/* Input library name */
             PARM       KWD(LIBRARY) TYPE(*NAME) MIN(1) +
                          PROMPT('Library Name:')
             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          VALUES(*ALL *FILE *PGM *SRVPGM *CMD *OVL +
                          *DTAARA *BNDDIR *OUTQ *SQLPKG *MODULE +
                          *JOBD *QRYDFN) MIN(1) PROMPT('Object Type:')

/* Output file name */
             PARM       KWD(OUTFILE) TYPE(OUTFILE1) PROMPT('Output +
                          File:')

 OUTFILE1:   QUAL       TYPE(*NAME) DFT(OBJAUT)
             QUAL       TYPE(*NAME) LEN(10) DFT(QTEMP) SPCVAL((*LIBL +
                          *N)) PROMPT('Output Library:')

