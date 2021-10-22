 /*   CRTCMD CMD(ALAN/CPYPF2XLS)           */
 /*          PGM(ALAN/CPYPF2XLSR)          */
 /*          SRCFILE(ALAN/POI313)          */
 /*          VLDCKR((ALAN/CPYPF2XLSV)      */

 CPYPF2XLS:  CMD        PROMPT('Copy PF to Excel')

             PARM       KWD(FILE) TYPE(QUAL) MIN(1) PROMPT('File')
             PARM       KWD(MEMBER) TYPE(*CHAR) LEN(10) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Member')
             PARM       KWD(IFSFILE) TYPE(*CHAR) LEN(1024) +
                          PROMPT('IFS file name')

 QUAL:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
