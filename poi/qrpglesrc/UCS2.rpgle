     H CCSID(*UCS2 : 13488)
     H DFTACTGRP(*NO)

     D char            S              5A   INZ('abcde')
     D chichar         S              6A   INZ('測試')
     D*graph           S              2G   INZ(G'oAABBi')
      *
      * The %UCS2 built-in function is used to initialize a UCS-2 field.
     D ufield          S             10C   INZ(%UCS2('abcdefghij'))
     D ufield2         S              1C   CCSID(61952) INZ(*LOVAL)
     D ufield3         S              6C
     D isLess          S              1N
     D*proc            PR
     D*  uparm                        2G   CCSID(13488) CONST
     D dspchar         S             10A

     D UCS2Field       S              2C   INZ(U'00610062')
     D vucs2           S             10C   INZ(U'') VARYING

     C*                  EVAL      ufield = %UCS2(char) + %UCS2(graph)
     C*                  EVAL      dspchar = %UCS2(char)
     C                   EVAL      ufield = %UCS2(char)
     C                   EVAL      ufield3 = %UCS2(chichar)
      * ufield now has 7 UCS-2 characters representing
      * 'a.b.c.d.e.AABB' where 'x.' represents the UCS-2 form of 'x'
     C                   EVAL      isLess = ufield < %UCS2(ufield2:13488)
      * The result of the %UCS2 built-in function is the value of
      * ufield2, converted from CCSID 61952 to CCSID 13488
      * for the comparison.
     C                   EVAL      ufield = ufield2
      * The value of ufield2 is converted from CCSID 61952 to
      * CCSID 13488 and stored in ufield.
      * This conversion is handled implicitly by the compiler.
     C*                  CALLP     proc(ufield2)
      * The value of ufield2 is converted to CCSID 13488
      * implicitly, as part of passing the parameter by constant reference.
     C                   eval      *in06 = (%len(vucs2)=0)
      * *in06 is '1'
     C                   eval      *Inlr = *on
