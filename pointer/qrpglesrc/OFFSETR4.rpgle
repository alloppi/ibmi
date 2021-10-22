      ******************************************************************
      * Compile: CRTRPGMOD MODULE(OFFSETR4) SRCFILE(*LIBL/QPTRSRC) DBGVIEW(*LIST)
      *          CRTSRVPGM SRVPGM(OFFSETR4) EXPORT(*ALL)
      ******************************************************************
     H NOMAIN

     D/COPY QPTRSRC,OFFSET_H

     P*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P* Return a pointer at a specified offset value from another ptr
     P*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P OffsetPtr       B                   EXPORT
     D OffsetPtr       PI              *
     D   pePointer                     *   Value
     D   peOffset                    10I 0 Value

     D p_NewPtr        S               *
     D wkMove          S              1A   DIM(4097) BASED(p_NewPtr)

     c                   eval      p_NewPtr = pePointer

     c                   if        peOffset > 0

     C                   dow       peOffset > 4096
     C                   eval      p_NewPtr = %addr(wkMove(4097))
     c                   eval      peOffset = peOffset - 4096
     c                   enddo

     C                   eval      p_NewPtr = %addr(wkMove(peOffset+1))

     c                   endif

     c                   return    p_NewPtr
     P                 E
