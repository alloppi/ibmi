/*===================================================================*/
/* Program name: PSXX0NCMD                                           */
/* Purpose.....: Change IFS object permissions                       */
/*                                                                   */
/* Description : Create by command                                   */
/*  CRTCMD lib/PSXX0NCMD srcfile(srclib/srcfile) pgm(lib/PSXX0NR)    */
/*                                                                   */
/* Modification:                                                     */
/* Date       Name       Pre  Ver  Mod#  Remarks                     */
/* ---------- ---------- --- ----- ----- --------------------------- */
/* 2017/03/11 Alan       AC        06517 New Development             */
/*===================================================================*/
             CMD        PROMPT('Change IFS object permissions')

             PARM       KWD(OBJ) TYPE(*CHAR) LEN(640) MIN(1) +
                          PROMPT('OBJECT')
             PARM       KWD(USER) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*SAME) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X *SAME) PROMPT('Owner permissions')
             PARM       KWD(GROUP) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*SAME) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X *SAME) PROMPT('Group permissions')
             PARM       KWD(OTHER) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*SAME) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X *SAME) PROMPT('Others permissions')
