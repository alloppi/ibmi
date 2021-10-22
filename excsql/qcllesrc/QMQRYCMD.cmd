        /*********************************************************************/
        /*                                                                   */
        /* Command definition for EXCSQL command                             */
        /* Command processing program is QMQRYCLP.                           */
        /*                                                                   */
        /*********************************************************************/
        /*                                                                   */
        /* Description: Process SQL commands using QM query.                 */
        /*                                                                   */
        /*********************************************************************/
                     CMD        PROMPT('Execute SQL commands')
                     PARM       KWD(REQUEST) TYPE(*CHAR) LEN(550) MIN(1) +
                                  PROMPT('SQL request')
                     PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                                  DFT(*) VALUES(* *PRINT *OUTFILE) MIN(0) +
                                  PROMPT('Output')
                     PARM       KWD(OUTFILE) TYPE(T1) MIN(0) PMTCTL(P1) +
                                  PROMPT('File to receive output')
                     PARM       KWD(MEMBER) TYPE(T2) MIN(0) PMTCTL(P1) +
                                  PROMPT('Output member options')
                     PARM       KWD(PRTFILE) TYPE(T3) MIN(0) PMTCTL(P2) +
                                  PROMPT('Printer file to use')
         T1:         QUAL       TYPE(*NAME) LEN(10)
                     QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                                  SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')
         T2:         QUAL       TYPE(*NAME) LEN(10) DFT(*FIRST) +
                                  SPCVAL((*FIRST))
                     QUAL       TYPE(*NAME) LEN(10) RSTD(*YES) DFT(*REPLACE) +
                                  SPCVAL((*REPLACE) (*ADD)) PROMPT('Replace +
                                  or add records')
         T3:         QUAL       TYPE(*NAME) LEN(10) DFT(QPQXPRTF)
                     QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                                  SPCVAL((*LIBL) (*CURLIB)) PROMPT('Library')
         P1:         PMTCTL     CTL(OUTPUT) COND((*EQ *OUTFILE))
         P2:         PMTCTL     CTL(OUTPUT) COND((*EQ *PRINT))
