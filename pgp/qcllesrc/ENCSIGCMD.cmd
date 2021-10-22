/*=========================================================================================*/
/* Program name: ENCSIGCMD                                                                 */
/* Purpose.....: Encrypt and Signing File Command                                          */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/ENCSIGCMD srcfile(srclib/srcfile) pgm(lib/ENCSIGC)                          */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  Signing? . . . . . . . . . . . .   *YES                                                */
/*  Path . . . . . . . . . . . . . .   /AML/REPORT                                         */
/*  Text File       (w/o .asc Ext)     PHAMLBFYYYYMMDD                                     */
/*  Public Key File (w/o .asc Ext)     LYODS_SFTP_PUBLIC                                   */
/*  Private Key File(w/o .asc Ext)                                                         */
/*  Private Key Password . . . . . .   LYODS_SFTP_PRIVATE                                  */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC        08170 New                                               */
/*=========================================================================================*/
             CMD        PROMPT('Encrypt and Signing File')

             PARM       KWD(SIGN) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) +
                          VALUES(*YES *NO) +
                          CHOICE('*YES, *NO') +
                          PROMPT('Signing?')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(24) +
                          PROMPT('Path')

             PARM       KWD(INFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Text File       (w/o .asc Ext)')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Public Key File (w/o .asc Ext)')

             PARM       KWD(PVTKEYFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PASSPHRASE) TYPE(*CHAR) LEN(20) +
                          PROMPT('Private Key Password')

