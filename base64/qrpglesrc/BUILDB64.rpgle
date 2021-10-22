/*====================================================================*/
/* Name:    base64                                                    */
/* version: 1.1                                                       */
/* build:   Scott Klement                                             */
/*====================================================================*/
    CRTRPGMOD MODULE(*CURLIB/BASE64R4) SRCFILE(*CURLIB/QBASE64SRC) DBGVIEW(*LIST)
    CRTSRVPGM  SRVPGM(*CURLIB/BASE64R4) SRCFILE(*CURLIB/QSRVSRC)
    CRTBNDDIR  BNDDIR(*CURLIB/BASE64)
    ADDBNDDIRE BNDDIR(BASE64) OBJ((BASE64R4 *SRVPGM))
