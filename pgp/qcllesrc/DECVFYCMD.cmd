/*=========================================================================================*/
/* Program name: DECVFYCMD                                                                 */
/* Purpose.....: Decrypt and Verifying File Command                                        */
/*                                                                                         */
/* Command created :                                                                       */
/*  CRTCMD lib/DECVFYCMD srcfile(srclib/srcfile) pgm(lib/DECVFYC)                          */
/*                                                                                         */
/*  For AML Project                                                                        */
/*  ===============                                                                        */
/*  Verifying? . . . . . . . . . . .    *YES                                               */
/*  Path . . . . . . . . . . . . . .   /AML/REPORT                                         */
/*  Encrypted File  (w/o .asc Ext)     Batch_Hit.asc                                       */
/*  Private Key File(w/o .asc Ext)     Lyods_sftp_private                                  */
/*  Private Key Password . . . . . .                                                       */
/*  Public Key File (w/o .asc Ext)     Lyods_sftp_public                                   */
/*                                                                                         */
/* Modification:                                                                           */
/* Date       Name       Pre  Ver  Mod#  Remarks                                           */
/* ---------- ---------- --- ----- ----- ------------------------------------------------- */
/* 2020/12/04 Alan       AC        08170 New                                               */
/*=========================================================================================*/
             CMD        PROMPT('Decrypt and Verifying File')

             PARM       KWD(VFG) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) +
                          VALUES(*YES *NO) +
                          CHOICE('*YES, *NO') +
                          PROMPT('Verifying?')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(24) +
                          PROMPT('Path')

             PARM       KWD(INFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Encrypted File  (w/o .asc Ext)')

             PARM       KWD(PVTKEYFILE) TYPE(*PNAME) LEN(24) +
                          PROMPT('Private Key File(w/o .asc Ext)')

             PARM       KWD(PASSPHRASE) TYPE(*PNAME) LEN(20) +
                          PROMPT('Private Key Password')

             PARM       KWD(PUBKEYFILE) TYPE(*CHAR) LEN(24) +
                          PROMPT('Public Key File (w/o .asc Ext)')

