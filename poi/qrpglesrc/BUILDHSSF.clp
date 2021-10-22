/*    THIS CONTAINS THE CODE NEEDED TO BUILD THE HSSF/XSSF RPG      +
      INTERFACES AND SAMPLE PROGRAMS.                               +
                                 SCOTT KLEMENT   FEBRUARY 25, 2010  +
                                                                    +
      BY DEFAULT, OBJECTS ARE CREATED IN *CURLIB.  EDIT THE         +
      VARIABLES, BELOW, TO CONTROL THIS.                            +
*/
PGM

/*    DCL VAR(&RPGSRC) TYPE(*CHAR) LEN(10) VALUE('QRPGLESRC') */
      DCL VAR(&RPGSRC) TYPE(*CHAR) LEN(10) VALUE('POI36')
      DCL VAR(&SRVSRC) TYPE(*CHAR) LEN(10) VALUE('QSRVSRC')
/*    DCL VAR(&SQLSRC) TYPE(*CHAR) LEN(10) VALUE('QSQLSRC')   */
      DCL VAR(&SQLSRC) TYPE(*CHAR) LEN(10) VALUE('POI36')
      DCL VAR(&OBJLIB) TYPE(*CHAR) LEN(10) VALUE('*CURLIB')
      DCL VAR(&EXISTS) TYPE(*LGL)
      DCL VAR(&TEXT)   TYPE(*CHAR) LEN(50) +
          VALUE('Excel Spreadsheets from RPG')

      MONMSG MSGID(CPF0000 CPE0000 MCH0000) EXEC(GOTO FAIL)

      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(HSSFR4)
      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(HSSF_H)
      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(IFSIO_H)
      CHKOBJ OBJ(QSYSINC/QRPGLESRC) OBJTYPE(*FILE) MBR(JNI)
      CHKOBJ OBJ(&SRVSRC) OBJTYPE(*FILE) MBR(HSSFR4)

      CRTRPGMOD MODULE(QTEMP/HSSFR4) +
                SRCFILE(&RPGSRC) +
                DBGVIEW(*LIST) +
                TEXT(&TEXT)

      CRTSRVPGM SRVPGM(&OBJLIB/HSSFR4) +
                MODULE(QTEMP/HSSFR4) +
                ACTGRP(HSSFR4) +
                TEXT(&TEXT)

      CRTBNDDIR BNDDIR(HSSF) TEXT(&TEXT)
      MONMSG MSGID(CPF2112 CPF5D10 CPF5D0B)

      ADDBNDDIRE BNDDIR(HSSF) OBJ((HSSFR4 *SRVPGM))

      CHGVAR &EXISTS '1'
      CHKOBJ OBJ(&OBJLIB/DIVSALES) OBJTYPE(*FILE)
      MONMSG CPF0000 EXEC(CHGVAR &EXISTS '0')
      IF (&EXISTS *EQ '0') DO
         CHKOBJ OBJ(&SQLSRC) OBJTYPE(*FILE) MBR(DIVSALES)
         RUNSQLSTM SRCFILE(&SQLSRC) SRCMBR(DIVSALES) +
                   COMMIT(*NONE) NAMING(*SYS) ERRLVL(20) +
                   DATFMT(*ISO) DATSEP(-)
      ENDDO

      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(XLCRTDEMO)
      CRTBNDRPG PGM(XLCRTDEMO) SRCFILE(&RPGSRC) DBGVIEW(*LIST) +
                TEXT('Excel Create Demo')

      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(HDRDEMO)
      CRTBNDRPG PGM(HDRDEMO) SRCFILE(&RPGSRC) DBGVIEW(*LIST) +
                TEXT('Excel Page Header/Footer Demo')

      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(UPDDEMO)
      CRTBNDRPG PGM(UPDDEMO) SRCFILE(&RPGSRC) DBGVIEW(*LIST) +
                TEXT('Read/Update Excel Spreadsheet Demo')

      CHKOBJ OBJ(&RPGSRC) OBJTYPE(*FILE) MBR(ADDPIC)
      CRTBNDRPG PGM(ADDPIC) SRCFILE(&RPGSRC) DBGVIEW(*LIST) +
                TEXT('Add logo to Excel spreadsheet Demo')
      RETURN

FAIL:
   /************************************************/
   /*  RE-SEND ERROR MESSAGE BACK TO CALLER        */
   /************************************************/
      CALL PGM(QMHMOVPM) PARM( '    '              +
                               '*DIAG'             +
                               x'00000001'         +
                               '*PGMBDY   '        +
                               x'00000001'         +
                               x'0000000800000000' )

      CALL PGM(QMHRSNEM) PARM( '    '              +
                               x'0000000800000000' )
ENDPGM
