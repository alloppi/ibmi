/*=========================================================================================*/
/* Program name: AMLPG02CMD                                                                */
/* Purpose.....: PGP Encrypt and Signing File Command                                      */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/AMLPG02CMD srcfile(srclib/srcfile) pgm(lib/AMLPG02C)                        */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  Signing? . . . . . . . . . . . .   *NO                                                 */
/*  Path . . . . . . . . . . . . . .   /AML/Report                                         */
/*  Text File       (w/o .asc Ext)     AMLBFYYYYMMDD                                       */
/*  Public Key File (w/o .asc Ext)     sftp_public                                         */
/*  Private Key File(w/o .asc Ext)                                                         */
/*  Private Key Password . . . . . .                                                       */
/*  Return Code  . . . . . . . . . .   0                                                   */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC              New                                               */
/*=========================================================================================*/
             CMD        PROMPT('Encrypt and Signing File')

             PARM       KWD(SIGN) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) +
                          VALUES(*YES *NO) +
                          CHOICE('*YES, *NO') +
                          PROMPT('Signing?')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Path')

             PARM       KWD(INFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Text File       (w/o .asc Ext)')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Public Key File (w/o .asc Ext)')

             PARM       KWD(PVTKEYFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PASSPHRASE) TYPE(*CHAR) LEN(20) +
                          CASE(*MIXED) +
                          PROMPT('Private Key Password')

             PARM       KWD(RTNCDE) TYPE(*DEC) LEN(2 0) +
                          DFT(0) +
                          PROMPT('Return Code')

