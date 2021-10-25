/********************************************************************/
/* CREATION : CRTCMD CMD(YOURLIB/DLTUSPLF) +                        */
/*                   PGM( YOURLIB/DLTUSPLFC)                        */
/********************************************************************/
             CMD        PROMPT('Delete User Spool File')

             PARM       KWD(SLTUSER) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('User')
             PARM       KWD(OUTQNAME) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('OutQ Name')
             PARM       KWD(OUTQLIB) TYPE(*CHAR) LEN(10) DFT(*LIBL) +
                          PROMPT('OutQ Library')
             PARM       KWD(SLTSFLF) TYPE(*CHAR) LEN(10) +
                          DFT(*ALL) PROMPT('Spool File Name')

 OUTQLIB1:   QUAL       TYPE(*NAME) DFT(*LIBL)
