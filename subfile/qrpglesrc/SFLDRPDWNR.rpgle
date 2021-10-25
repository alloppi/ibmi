      ****************************************************************
      *   ___             _    _     __ __             _    _        *
      *  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _   *
      *  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |  *
      *  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|  *
      *                                                              *
      *  A program to display a dropdown box, with mouse pick.       *
      *    Features:                                                 *
      *     - If a parm is used then a mouse click on an item will   *
      *       return the clicked item as a choice.                   *
      *     - The first line displayed is always blank and provides  *
      *       a means for adding a new TERM to the list of TERMs.    *
      *     - If the program is called without a parm then the file  *
      *       is in Edit Mode and any lines may be changed or        *
      *       deleted.                                               *
      *                                                              *
      *                                                              *
      *  11/2010                                 booth@martinvt.com  *
      ****************************************************************
     H COPYRIGHT('(C) Copyright Booth Martin 2010, All rights reserved.')
     H option(*nodebugio) dftactgrp(*no) actgrp(*caller)

     FSFLDRPDWNDcf   e             workstn SFILE(SFL1:RRNA)
     FSFLDRPDWNPuf a e           k disk

      *  ..................................................

     D pTerms          s                       like(TERMS)
     D wNdx            s              5s 0
     D wRRNASaved      s                       like(RRNA)
     D weojFlag        s               n       inz(*off)
      *  ..................................................
     C     *entry        plist
     C                   parm                    pTerms

     C                   dou       weojFlag = *on
      * Clear subfile.
     C                   eval      *in90 = *off
     C                   write     FMT01
     C                   eval      *in90 = *on

      * Fill the subfile:
      *  Make a leading blank record, so a new TERMS can be entered:
     C                   eval      *in41 = *off
     C                   eval      RRNA = 1
     C                   eval      W1TERMS = *blanks
     C                   eval      W1TERMSSV = *blanks
     C                   write     SFL1
      * Allow editing of the file if this program is run stand-alone.
      *  Otherwise protect the fields.
     C                   if        %parms = 1
     C                   eval      *in41 = *on
     C                   endif
      * Fill the subfile:
     C     *start        setll     SFLDRPDWNP
     C                   read      SFLDRPDWNP
     C                   dow       not %eof
     C                   eval      RRNA = RRNA + 1
     C                   eval      W1TERMS = TERMS
     C                   eval      W1TERMSSV = TERMS
     C                   write     SFL1
     C                   read      SFLDRPDWNP
     C                   enddo
     C                   eval      *in91 = *on
      * Set subfile size:
     C                   eval      SFL1RECS = RRNA
     C                   exfmt     FMT01
     C                   eval      weojFlag = *on
      * Save the RRNA
     C                   eval      wRRNASaved = RRNA
      * See if there have been any changes:
     C                   for       wNdx = 1 to SFL1RECS
     C     wNdx          chain     SFL1
      * Look for changes in the subfile:
     C                   if        W1TERMS <> W1TERMSSV
     C                   exsr      FixTERMS
      * If any changes, (after the first line) do not end yet:
      *  or, in edit mode and still making additions.
     C                   if        (wNdx > 1)
     C                               or (%parms = 0
     C                                   and wNdx = 1
     C                                   and W1TERMS <> *blanks)
     C                   eval      weojFlag = *off
     C                   endif
     C                   endif
     C                   endfor
     C                   enddo

      * If a choice was made, save it to PARM for return:
     C                   if        (%parms = 1)
     C                               and (wRRNASaved > *zeros)
     C     wRRNASaved    chain     SFL1
     C                   eval      pTerms = W1TERMS
     C                   endif
     C                   eval      *inlr = *on
      *  ..................................................
      *  FixTERMS sub routine  add/delete/update TERMS
      *  ..................................................
     C     FixTERMS      begsr
     C                   select

      * New Terms:
     C                   when      W1TERMSSV = *blank
     C                   eval      TERMS  = W1TERMS
     C                   write(e)  RSFLDRPDWN

      * Existing record cleared:
     C                   when      W1TERMS = *blank
     C     W1TERMSSV     delete    SFLDRPDWNP

      * Only choice left is update:
     C                   other
     C     W1TERMSSV     chain     SFLDRPDWNP
     C                   eval      TERMS = W1TERMS
     C                   update    RSFLDRPDWN
     C                   endsl
     C                   endsr
      *-------------------------------------------------------------------
