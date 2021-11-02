/*=========================================================================================*/
/* Program name: AMLPG03CMD                                                                */
/* Purpose.....: PGP Generate PGP signing key pair Command                                 */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/AMLPG03CMD srcfile(srclib/srcfile) pgm(lib/AMLPG03C)                        */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  RSA Key Size . . . . . . . . . .   2048                                                */
/*  Expiry Months, 0=Never Expired     0                                                   */
/*  Path . . . . . . . . . . . . . .   /AML/Report                                         */
/*  Private Key File(w/o .asc Ext)     sftp_private                                        */
/*  Public Key File (w/o .asc Ext)     sftp_public                                         */
/*  Key User Name  . . . . . . . . .   AML                                                 */
/*  Key User E-mail  . . . . . . . .   itdept@system.com.hk                                */
/*  Private Key Password . . . . . .                                                       */
/*  Return Code  . . . . . . . . . .                                                       */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC              New                                               */
/*=========================================================================================*/
             CMD        PROMPT('Generate PGP Signing Key Pair')

             PARM       KWD(KEYSIZE) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) +
                          VALUES(1024 2048 4096 8192) +
                          PROMPT('RSA Key Size')

             PARM       KWD(EXPMTH) TYPE(*CHAR) LEN(2) +
                          RSTD(*YES) +
                          VALUES(0 12 24 36 48 60 72) +
                          PROMPT('Expiry Months, 0=Never Expired')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Path')

             PARM       KWD(PVTKEYFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Public Key File (w/o .asc Ext)')

             PARM       KWD(USRNAME) TYPE(*CHAR) LEN(32) +
                          CASE(*MIXED) +
                          PROMPT('Key User Name')

             PARM       KWD(USREMAIL) TYPE(*CHAR) LEN(32) +
                          CASE(*MIXED) +
                          PROMPT('Key User E-mail')

             PARM       KWD(PASSPHRASE) TYPE(*CHAR) LEN(20) +
                          CASE(*MIXED) +
                          PROMPT('Private Key Password')

             PARM       KWD(RTNCDE) TYPE(*DEC) LEN(2 0) +
                          DFT(0) +
                          PROMPT('Return Code')

