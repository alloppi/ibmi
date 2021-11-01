/*=========================================================================================*/
/* Program name: AMLPG01CMD                                                                */
/* Purpose.....: PGP Decrypt and Verifying File Command                                    */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/AMLPG01CMD srcfile(srclib/srcfile) pgm(lib/AMLPG01C)                        */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  Verifying? . . . . . . . . . . .   *NO                                                 */
/*  Path . . . . . . . . . . . . . .   /AML/Report                                         */
/*  Encrypted File  (w/o .asc Ext)     enc_file.asc                                        */
/*  Private Key File(w/o .asc Ext)     sftp_private                                        */
/*  Private Key Password . . . . . .                                                       */
/*  Public Key File (w/o .asc Ext)                                                         */
/*  Return Code  . . . . . . . . . .   0                                                   */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC              New                                               */
/*=========================================================================================*/
             CMD        PROMPT('Decrypt and Verifying File')

             PARM       KWD(VFG) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) +
                          VALUES(*YES *NO) +
                          CHOICE('*YES, *NO') +
                          PROMPT('Verifying?')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Path')

             PARM       KWD(INFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Encrypted File  (w/o .asc Ext)')

             PARM       KWD(PVTKEYFILE) TYPE(*PNAME) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PASSPHRASE) TYPE(*PNAME) LEN(20) +
                          CASE(*MIXED) +
                          PROMPT('Private Key Password')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          CASE(*MIXED) +
                          PROMPT('Public Key File (w/o .asc Ext)')

             PARM       KWD(RTNCDE) TYPE(*DEC) LEN(2 0) +
                          DFT(0) +
                          PROMPT('Return Code')

