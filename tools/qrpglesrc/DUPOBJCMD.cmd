 /*====================================================================*/
 /* Program name: DUPOBJCMD                                            */
 /* Purpose.....: Create Selected Duplicate Objects in Library         */
 /* Compile.....: CRTCMD CMD(*CURLIB/DUPOBJCMD) PGM(*CURLIB/DUPOBJC)   */
 /*                 SRCFILE(*LIBL/QRPGSRC)                             */
 /*                                                                    */
 /* Date       Name       Pre  Ver  Mod#  Remarks                      */
 /* ---------- ---------- --- ----- ----- -----------------------------*/
 /* 2017/06/14 Alan       AC              New Development              */
 /*====================================================================*/
             CMD        PROMPT('Create Selected Duplicate Obj')
             PARM       KWD(FROMOBJ)   TYPE(FROMOBJ) MIN(1) PROMPT('From object')
 FROMOBJ:    QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL))
             PARM       KWD(FROMLIB)   TYPE(*CHAR) LEN(10) MIN(1) PROMPT('From library')
             PARM       KWD(OBJTYPE)   TYPE(*CHAR) LEN(10) MIN(1) PROMPT('Object type')
             PARM       KWD(OBJATTR)   TYPE(*CHAR) LEN(10) DFT(*ALL) PROMPT('Object attribute')
             PARM       KWD(CHGDATE)   TYPE(*CHAR) LEN(8) DFT(*ALL) +
                          PROMPT('Begin change date (yyyymmdd)')
             PARM       KWD(CHGDATTIM) TYPE(*CHAR) LEN(14) DFT(*ALL) +
                          PROMPT('Begin change date time (d+hms)') +
                          CHOICE('*ALL, yyyymmddhhmmss')
             PARM       KWD(OWNER)     TYPE(*CHAR) LEN(10) DFT(*ALL) PROMPT('Object owner')
             PARM       KWD(DATA)      TYPE(*CHAR) LEN(4)  DFT(*YES) PROMPT('Duplicate data') +
                          RSTD(*YES) VALUES(*YES *NO)
             PARM       KWD(TOLIB)     TYPE(*CHAR) LEN(10) MIN(1) PROMPT('To library')
             PARM       KWD(NEWOWNER)  TYPE(*CHAR) LEN(10) DFT(*FROMLIB) PROMPT('New Owner')
