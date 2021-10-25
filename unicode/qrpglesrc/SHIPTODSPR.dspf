     fshiptodspfcf   e             workstn sfile(sflrcd:RelRecNbr)
     Forder     if   e           k disk
     Forddet    if   e           k disk
     Finven     if   e           k disk
      *
      * Work fields
     dRelRecNbr        s              4  0
      *
      * Prompt for order number until command Key F03
     c                   dow       *in03 <> '1'
     c                   exfmt     prompt

      * Get summary order information if it exists
     c     ordno         chain     ordrec                             50
     c                   if        *in50
     c                   iter
     c                   endif

      * Get detail order information
     c     ordno         setll     orddec
     c     ordno         reade     orddec                                 51
     c                   dow       not *in51

      * Get translated part descriptions
     c     partno        chain     invrec
     c                   eval      RelRecNbr += 1
     c                   write     SflRcd
     c     ordno         reade     orddec                                 51
     c                   enddo
      *
      * Write the display
     c                   write     Fmt1
     c                   if        RelRecNbr > 0
     c                   eval      *in21 = *on
     c                   endif
     c                   exfmt     SflCtl
     c                   eval      *in21 = *off
      *
      * Clear the subfile and return to prompt for order number
     c                   eval      *in25 = *on
     c                   write     SflCtl
     c                   eval      *in25 = *off
     c                   eval      RelRecNbr = 0
     c                   enddo
      *
     c                   eval      *inlr = *on
     c                   return
      *
     c     *inzSr        begsr
      *
     c                   endsr
