/*=================================================================*/
/* Program name: SNDMAILCMD                                        */
/* Purpose.....: Send Email Command                                */
/* Description : Creat by command                                  */
/*  CRTCMD lib/SNDMAILCMD srcfile(srclib/srcfile) pgm(lib/SNDMAILR)*/
/*                        SEND AN E-MAIL MESSAGE (SNDMAILCMD       */
/*                                                                 */
/*  TYPE COMMAND PSXX81CMD AND PRESS F4                            */
/*                                                                 */
/*  MIME HEADER FILE NAME  . . . . . > '/EMAIL/EMAIL'              */
/*  E-MAIL ADDRESS OF RECIPIENT  . . > ALAN@SYSTEM.COM.HK          */
/*  NAME OF E-MAIL RECIPIENT . . . . > ALAN                        */
/*  E-MAIL ADDRESS OF SENDER . . . . > DEPT@SYSTEM.COM.HK          */
/*  NAME OF E-MAIL SENDER  . . . . . > DEPT                        */
/*  FILE ATTACHMENT  . . . . . . . . > *NONE                       */
/*  SUBJECT .........................> 'TESTING'                   */
/*                                                                 */
/*                                                                 */
/* Modification:                                                   */
/* Date       Name       Pre  Ver  Mod#  Remarks                   */
/* ---------- ---------- --- ----- ----- --------------------------*/
/* 2011/08/23 Alan       AC              New                       */
/*=================================================================*/
             CMD        PROMPT('Send an E-mail Message')
             /* In CL Len is 256, RPG Len is 255 */
             PARM       KWD(FILENAME) TYPE(*PNAME) LEN(256) MIN(1) +
                          EXPR(*YES) PROMPT('MIME header file +
                          name' 1)
             PARM       KWD(RECIPADDR) TYPE(*PNAME) LEN(256) MIN(1) +
                          EXPR(*YES) PROMPT('E-mail address of +
                          recipient' 2)
             PARM       KWD(SENDERADDR) TYPE(*PNAME) LEN(255) MIN(1) +
                          EXPR(*YES) PROMPT('E-mail address of +
                          sender' 4)
             PARM       KWD(RECIPNAME) TYPE(*CHAR)  LEN(256) +
                          DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                          PROMPT('Name of e-mail recipient' 3)
/*           PARM       KWD(SENDERNAME) TYPE(*CHAR) LEN(256) +   */
             PARM       KWD(SENDERNAME) TYPE(*CHAR) LEN(80)  +
                          DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                          PROMPT('Name of e-mail sender' 5)
             PARM       KWD(ATTACHMENT) TYPE(*PNAME) LEN(256) +
                          DFT(*NONE) SNGVAL((*NONE)) MAX(30) +
                          EXPR(*YES) PROMPT('File attachment')
             PARM       KWD(SUBJECT)    TYPE(*CHAR) LEN(256) +
                          DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                          PROMPT('Subject')
             PARM       KWD(MESSAGE)    TYPE(*CHAR) LEN(1024)  +
                          DFT(*HTML) SPCVAL((*NONE '')) EXPR(*YES) +
                          PROMPT('Message')
