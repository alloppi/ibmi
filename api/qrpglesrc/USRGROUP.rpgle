      * Refer to: http://www.think400.dk/apier_1.htm#eks0009
      * Use Option 15 to create module in QTEMP with DBGVIEW(*source)
      * CRTPGM PGM(*curlib/USRGROUP) MODULE(QTEMP/USRGROUP) BNDSRVPGM((GROUP))

     D/COPY QRPGLESRC,GROUP_H
     D UserID          S             10A
     D Group           S             10A
     D Msg             S             50A

     c     *entry        plist
     c                   parm                    UserID
     c                   parm                    Group

     c                   if        IsInGroup(UserID: Group) = 1
     c                   eval      Msg = 'User is in that group!'
     C                   else
     c                   eval      Msg = 'User is not in that group!'
     c                   endif

     c                   dsply                   Msg

     c                   eval      *inlr = *on
