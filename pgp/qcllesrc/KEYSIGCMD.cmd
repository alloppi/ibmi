/*=========================================================================================*/
/* Program name: KEYSIGCMD                                                                 */
/* Purpose.....: Generate PGP signing key pair Command                                     */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/KEYSIGCMD srcfile(srclib/srcfile) pgm(lib/KEYSIGC)                          */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  RSA Key Size . . . . . . . . . .   2048                                                */
/*  Expiry Months, 0=Never Expired     0                                                   */
/*  Path . . . . . . . . . . . . . .   /AML/REPORT                                         */
/*  Private Key File(w/o .asc Ext)     Lyods_sftp_private                                  */
/*  Public Key File (w/o .asc Ext)     Lyods_sftp_public                                   */
/*  Key User Name  . . . . . . . . .                                                       */
/*  Key User E-mail  . . . . . . . .                                                       */
/*  Private Key Password . . . . . .                                                       */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC        08170 New                                               */
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
                          PROMPT('Path')

             PARM       KWD(PVTKEYFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Public Key File (w/o .asc Ext)')

             PARM       KWD(USRNAME) TYPE(*CHAR) LEN(32) +
                          PROMPT('Key User Name')

             PARM       KWD(USREMAIL) TYPE(*CHAR) LEN(32) +
                          PROMPT('Key User E-mail')

             PARM       KWD(PASSPHRASE) TYPE(*CHAR) LEN(20) +
                          PROMPT('Private Key Password')

