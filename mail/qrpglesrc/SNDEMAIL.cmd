/*********************************************************************/
/*   To create this command, issue the following:                    */
/*    CRTCMD lib/SNDEMAIL SRCFILE(srclib/srcfile) PGM(lib/SNDEMAILR) */
/*   November 2003                                                   */
/*   Author: Vengoal Chang                                           */
/*   Remarks: Can use 中文                                         */
/*********************************************************************/
       CMD    PROMPT('Send an E-mail Message')
       PARM   KWD(SENDERADDR) TYPE(*PNAME) LEN(255) MIN(1) EXPR(*YES) +
                 PROMPT('Sender email address' 2)
       PARM   KWD(TO) TYPE(TO) MIN(1) MAX(30) PROMPT('Recipient' 3)
       PARM   KWD(SENDERNAME) TYPE(*CHAR) LEN(256) DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                 PROMPT('Sender name' 1)
       PARM   KWD(CC) TYPE(CC) MAX(30) PROMPT('CC' 4)
       PARM   KWD(BCC) TYPE(BCC) MAX(30) PROMPT('BCC' 5)
       PARM   KWD(ATTACHMENT) TYPE(*PNAME) LEN(256) DFT(*NONE) SNGVAL((*NONE)) MAX(30) +
                 EXPR(*YES) PROMPT('File attachment' 6)
       PARM   KWD(SUBJECT) TYPE(*CHAR) LEN(256) DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                 PROMPT('Subject' 7)
       PARM   KWD(MESSAGE) TYPE(*CHAR) LEN(512) DFT(*NONE) SPCVAL((*NONE '')) EXPR(*YES) +
                 PROMPT('Message' 8)
       PARM   KWD(TXTF) TYPE(QUAL1) PROMPT('Text source file')

QUAL1: QUAL   TYPE(*NAME) LEN(10) DFT(*NONE) SPCVAL((*NONE *NONE))
       QUAL   TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')

       PARM   KWD(TXTMBR) TYPE(*NAME) LEN(10) PROMPT('Text source member')
       PARM   KWD(IMPORTNC) TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*MED) VALUES(*LOW *MED *HIG) +
                PROMPT('Importance')
       PARM   KWD(PRIORITY) TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*NRM) VALUES(*NUR *NRM *URG) +
                PROMPT('Priority')
       PARM   KWD(RECEIPT) TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*NO) VALUES(*NO *YES) +
                PROMPT('Return receipt')
       PARM   KWD(TMPDIR) TYPE(*PNAME) LEN(64) DFT('/tmp') PMTCTL(*PMTRQS) +
                PROMPT('Work directory')

TO:    ELEM   TYPE(*CHAR) LEN(50) MIN(1) EXPR(*YES) PROMPT('Name')
       ELEM   TYPE(*CHAR) LEN(256) EXPR(*YES) PROMPT('Mail address')

CC:    ELEM   TYPE(*CHAR) LEN(50) MIN(1) EXPR(*YES) PROMPT('Name')
       ELEM   TYPE(*CHAR) LEN(256) MIN(1) EXPR(*YES) PROMPT('Mail address')

BCC:   ELEM   TYPE(*CHAR) LEN(50) MIN(1) EXPR(*YES) PROMPT('Name')
       ELEM   TYPE(*CHAR) LEN(256) MIN(1) EXPR(*YES) PROMPT('Mail address')

