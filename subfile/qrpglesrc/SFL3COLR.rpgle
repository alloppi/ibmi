	     *************************************************************
      * A program to select from 3 different files                *
      *    6/00  Booth Martin                                     *
      *                                                           *
      *                                                           *
      *************************************************************
     FSFL3ColFM CF   E             WorkStn
     F                                     SFile(SFLA:RRN)
     FFilters1P IF   E             Disk
     FFilters2P IF   E             Disk
     FFilters3P IF   E             Disk

     D ReadFilters1P   S              3    Inz('Yes')
     D ReadFilters2P   S              3    Inz('Yes')
     D ReadFilters3P   S              3    Inz('Yes')

      * Arrays of Selected Items
     D RRN             S              4P 0
     D Inx             S              3S 0
     D Inx1            S              3S 0
     D AR1             S              2    Dim(60)
     D Inx2            S              3S 0
     D AR2             S              2    Dim(60)
     D Inx3            S              3S 0
     D AR3             S              2    Dim(60)

      *  ..................................................

     C                   Eval      RRN = 1

      * Clear subfile & screen, prepare to re-fill or fill:
     C                   Eval      *IN90 = *OFF
     C                   Clear                   SFLA
     C                   Write     FOOTer
     C                   Write     FMT01
     C                   ExSr      FillSubfileSR

      **
     C*    RRN           IFLT      11
     C     RRN           IFGT      11
     C                   MOVE      *ON           *IN91
     C                   END
     C                   MOVE      *ON           *IN90

     C                   DoW       *INLR = *Off
     C                   EXFMT     FMT01
     C                   Read      Footer

     C                   Select

      * Footer Push button Choices:
      * Refresh Subfile:
     C                   When      PB1 = 1 Or *INKE = *On
     C                   Eval      ReadFilters1P = 'Yes'
     C                   Eval      ReadFilters2P = 'Yes'
     C                   Eval      ReadFilters3P = 'Yes'
     C                   GOTO      RefreshTag
      * Run the job
     C                   When      PB1 = 2 Or *INKJ
     C                   ExSr      AcceptSR
     C*                  Eval      *INLR = *ON
      * end the job
     C                   When      PB1 = 3 or *INKC Or *INKL
     C                   Eval      *INLR = *ON

      * Mouse clicked in Column 1, toggle the field
      *  (Note: The DDS has a mouse button click = F11.  The reason for this is
      *         so that a regular Enter while the cursor is in a Filter field
      *         won't toggle the field's value.  F11=*INKK)

     C                   When      FLD = 'COL1O' And *INKK
     C     Relrcd        Chain     SFLA
     C                   If        Col1o = 'Y'
     C                   Eval      Col1o = ' '
     C                   Else
     C                   Eval      Col1o = 'Y'
     C                   End
     C                   Update    Sfla

      * Mouse clicked in Column 2, toggle the field
     C                   When      FLD = 'COL2O' And *INKK
     C     Relrcd        Chain     SFLA
     C                   If        Col2o = 'Y'
     C                   Eval      Col2o = ' '
     C                   Else
     C                   Eval      Col2o = 'Y'
     C                   End
     C                   Update    Sfla

      * Mouse clicked in Column 3, toggle the field
     C                   When      FLD = 'COL3O' And *INKK
     C     Relrcd        Chain     SFLA
     C                   If        Col3o = 'Y'
     C                   Eval      Col3o = ' '
     C                   Else
     C                   Eval      Col3o = 'Y'
     C                   End
     C                   Update    Sfla

     C                   EndSL
     C                   END

     C     RefreshTag    Tag
      *  _________________________________________________________________
     C     AcceptSR      BegSR
      * If a choice was made, then do the required action:
     C                   Eval      Inx  = 1
     C                   Eval      Inx1 = 1
     C                   Eval      Inx2 = 1
     C                   Eval      Inx3 = 1

     C     Inx           Chain     SFLA

     C                   If        %Found
     C                   DoU       %EOF or Not %Found

     C                   If        Col1o = 'Y'
     C                   Eval      Ar1(Inx1) = Col1H
     C                   Eval      Inx1 = Inx1 + 1
     C                   EndIf

     C                   If        Col2o = 'Y'
     C                   Eval      Ar2(Inx2) = Col2H
     C                   Eval      Inx2 = Inx2 + 1
     C                   EndIf

     C                   If        Col3o = 'Y'
     C                   Eval      Ar3(Inx3) = Col3H
     C                   Eval      Inx3 = Inx3 + 1
     C                   EndIf

     C                   Eval      Inx = Inx + 1
     C     Inx           Chain     SFLA
     C                   EndDo
     C                   EndIf
      * Sort the arrays so we can do look ups:
     C                   Sorta     AR1
     C                   Sorta     AR2
     C                   Sorta     AR3

      * Write a file of records for printing the report(s):
     C                   ExSr      WriteRecordSR

     C                   EndSR
      *  _________________________________________________________________
     C     WriteRecordSR BegSR
      * This sub routine is blank.  It is trivial to add whatever code is
      * needed to make the filters selected be useful.  The purpose of this
      * exercise is to show the 3-column subfile and the toggling of the values
     C                   EndSR
      *  _________________________________________________________________
     C     FillSubfileSR BegSR

     C     1             Setll     Filters1P
     C     1             Setll     Filters2P
     C     1             Setll     Filters3P

     C                   DoW       ReadFilters1P = 'Yes' Or
     C                             ReadFilters2P = 'Yes' Or
     C                             ReadFilters3P = 'Yes'
     C                   ExSr      WriteLineSR
     C                   If        ReadFilters1P = 'Yes' Or
     C                             ReadFilters2P = 'Yes' Or
     C                             ReadFilters3P = 'Yes'
     C                   Write     SFLA
     C                   Eval      RRN = RRN + 1
     C                   EndIf
     C                   EndDo

     C                   Eval      NBRREC = RRN
     C                   EndSR
      *  _________________________________________________________________
      * Write the line in the subfile:
     C     WriteLineSR   BegSR

      * Column 1: Status
     C                   Eval      Col1O = ' '
     C                   Eval      Col2O = ' '
     C                   Eval      Col3O = ' '

      * Column 1: Filters 1
     C                   Eval      Col1  = *Blanks
     C                   Eval      Col1H = ' '
     C                   If        ReadFilters1P = 'Yes'
     C                   Read      Filters1P

     C                   If        Not %EOF
     C                   Eval      Col1  = TypeID + ' ' + TYPEDS
     C                   Eval      Col1H = TypeID
     C                   Eval      Col1O = 'Y'
     C                   Else
     C                   Eval      ReadFilters1P = 'No '
     C                   Eval      *In31 = *On
     C                   EndIf

     C                   EndIf

      * Column 2: Filters2P
     C                   Eval      Col2  = *Blanks
     C                   Eval      Col2H = ' '

     C                   If        ReadFilters2P = 'Yes'
     C                   Read      Filters2P

     C                   If        Not %EOF
     C                   Eval      Col2  = ST + ' ' + STATE
     C                   Eval      Col2H = ST
     C                   Eval      Col2O = 'Y'
     C                   Else
     C                   Eval      ReadFilters2P = 'No '
     C                   Eval      *In32 = *On
     C                   EndIf

     C                   EndIf

      * Column 3: FiltersP
     C                   Eval      Col3  = *Blanks
     C                   Eval      Col3H = ' '

     C                   If        ReadFilters3P = 'Yes'
     C                   Read      Filters3P

     C                   If        Not %EOF
     C                   Eval      Col3  = CNTRY + ' ' + COUNTRY
     C                   Eval      Col3H = CNTRY
     C                   Eval      Col3O = 'Y'
     C                   Else
     C                   Eval      ReadFilters3P = 'No '
     C                   Eval      *In33 = *On
     C                   EndIf

     C                   EndIf

     C                   EndSR
      *  _____________________________________________________

