      *==============================================================*
      * JUST FOR TESTING THE SUBROUTINE IFS2BLOB                     *
      * AUTHOR : Alan Chan                                           *
      *==============================================================*
     FCBBLOBD   CF   E             WorkStn
      *
      * BLOB Size 1024*1024*5M=5242887
     D r_bytes         S               A   Len(5242887)
      *
      * Standard D spec.
      /Copy Qcpysrc,PSCY01R
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C                   Eval      D1FILE = 'yosemite.jpg'
     C                   Eval      r_bytes = *Blank
      * return
     C                   DoW       Not *In03
      * Retreive user message
      /Copy Qcpysrc,PSCY02R
     C                   Write     FT001
     C                   ExFmt     Dsp01
     C                   Eval      HDMSGID = *Blanks
     C                   Eval      HDMSG = *Blanks
     C                   Eval      *IN51 = *Off
      *
     C                   If        *In01
     C                   Call      'IFS2BLOB_T'
     C                   Parm                    D1File
     C                   Parm                    r_bytes
     C                   EndIf
      *
     C                   If        *In03
     C                   Goto      $End
     C                   EndIf
      *
     C                   EndDo
      *
      * End of Program
     C     $End          Tag
     C                   Eval      *InLr = *On
     C                   Return
