      * CRTRPGMOD MODULE(SAMPTRIGR4) SRCFILE(*LIBL/QRPGLESRC) DBGVIEW(*LIST)
      * CRTPGM PGM(SAMPTRIGR4) BNDSRVPGM(OFFSETR4)
      * ADDPFTRG FILE(CUSTF) TRGTIME(*BEFORE) TRGEVENT(*INSERT) PGM(SAMPTRIGR4) ALWREPCHG(*YES)
      * ADDPFTRG FILE(CUSTF) TRGTIME(*BEFORE) TRGEVENT(*UPDATE) PGM(SAMPTRIGR4) ALWREPCHG(*YES)
      * ADDPFTRG FILE(CUSTF) TRGTIME(*DELETE) TRGEVENT(*UPDATE) PGM(SAMPTRIGR4) ALWREPCHG(*YES)

     D/COPY QRPGLESRC,OFFSET_H

     D AFTER           C                   CONST('1')
     D BEFORE          C                   CONST('2')
     D INSERT          C                   CONST('1')
     D DELETE          C                   CONST('2')
     D UPDATE          C                   CONST('3')

      ***  "Before" image of the record buffer
     D dsBefore      e ds                  EXTNAME(CUSTF)
     D                                     BASED(p_Before)
     D                                     PREFIX(B_)
     D p_Before        S               *

      ***  "After" image of the record buffer
     D dsAfter       e ds                  EXTNAME(CUSTF)
     D                                     BASED(p_After)
     D                                     PREFIX(A_)
     D p_After         S               *

     *** Trigger information passed by the operating system
      ***   as a parameter to this program.
     D dsTrg           ds
     D   dsTrgFile             1     10A                                        File Name
     D   dsTrgLib             11     20A                                        Library file is in
     D   dsTrgMbr             21     30A                                        Member Name
     D   dsTrgEvent           31     31A                                        1Add 2Del 3Chg 4Read
     D   dsTrgTime            32     32A                                        Tigger Time
     D   dsTrgCmtLk           33     33A                                        Commit lock level
     D   dsTrgFill1           34     36A                                        Reserved
     D   dsTrgCSID            37     40I 0                                      CCSID
     D   dsTrgFill2           41     48A                                        Reserved
     D   dsTrgBOff            49     52I 0                                      Offset to Before Img
     D   dsTrgBLen            53     56I 0                                      Length of Before Ima
     D   dsTrgBNOff           57     60I 0                                      Offset Bef null byte
     D   dsTrgBNLen           61     64I 0                                      Length Bef null byte
     D   dsTrgAOff            65     68I 0                                      Offset to After Imga
     D   dsTrgALen            69     72I 0                                      Length of After Imag
     D   dsTrgANOff           73     76I 0                                      Offset Aft null byte
     D   dsTrgANLen           77     80I 0                                      Length Aft null byte
     D   dsTrgFill3           81     96A                                        Reserved

     D peLength        S             10I 0                                      Length of dsTrg
     D wkDateFld       S               D

     D psds           SDS
     D  UserID               254    263A

     C     *ENTRY        PList
     C                   Parm                    dsTrg
     c                   Parm                    peLength

      **************************************************************
      ** Point the "before buffer" and the "after buffer" to the
      **   external record layouts, as appropriate.
      **************************************************************
     c                   if        dsTrgEvent = UPDATE
     c                               or dsTrgEvent = DELETE
     c                   eval      p_Before = OffsetPtr(%addr(dsTrg):
     c                                           dsTrgBOff)
     c                   endif

     c                   if        dsTrgEvent = UPDATE
     c                               or dsTrgEvent = INSERT
     c                   eval      p_After = OffsetPtr(%addr(dsTrg):
     c                                           dsTrgAOff)
     c                   endif

      **************************************************************
      ** Change the after buffer to contain the current date and
      **   the user who made the change.
      **************************************************************
     c                   if        dsTrgEvent = UPDATE
     c                               or dsTrgEvent = INSERT
     c                   eval      A_cuMDat = %Date()
     c                   eval      A_cuMUsr = UserID
     c                   endif

     c                   return
