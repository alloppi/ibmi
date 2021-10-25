      *  http://www.think400.dk/apier_1.htm#eks0014

      ** Note:  To do this right, we should put this prototype into
      *  a /COPY member.  (but will work okay as-is)
     H DFTACTGRP(*NO)

     D Msg             S             50A
     D MyName          S              8A

     D RtvSysName      PR            10I 0
     D   SystemName                   8A

     c                   if        RtvSysName(MyName) < 0
     c                   eval      Msg = 'RtvSysName ended in error!'
     c                   dsply                   Msg
     c                   else
     c                   dsply                   MyName
     c                   endif

     c                   eval      *inlr = *on

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Retrieve System Name procedure:   RtvSysName
      *
      *    Parm:    SysName = name of system returned.
      *
      *   Returns:  0 = Success
      *             negative value if an error occurred.  See below
      *             for a list of possible negative values.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P RtvSysName      B                   Export
     D RtvSysName      PI            10I 0
     D   SysName                      8A

     D QWCRNETA        PR                  ExtPgm('QWCRNETA')
     D   RcvVar                   32766A   OPTIONS(*VARSIZE)
     D   RcvVarLen                   10I 0 const
     D   NbrNetAtr                   10I 0 const
     D   AttrNames                   10A   const
     D   ErrorCode                  256A

     D* Error code structure
     D EC              DS
     D*                                    Bytes Provided (size of struct)
     D  EC_BytesP              1      4B 0 INZ(256)
     D*                                    Bytes Available (returned by API)
     D  EC_BytesA              5      8B 0 INZ(0)
     D*                                    Msg ID of Error Msg Returned
     D  EC_MsgID               9     15
     D*                                    Reserved
     D  EC_Reserve            16     16
     D*                                    Msg Data of Error Msg Returned
     D  EC_MsgDta             17    256

     D* Receiver variable for QWCRNETA with only one attribute
     D RV              ds
     D*                                    Number of Attrs returned
     D   RV_Attrs                    10I 0
     D*                                    Offset to first attribute
     D   RV_Offset                   10I 0
     D*                                    Add'l data returned.
     D   RV_Data                      1A   DIM(1000)

     D* Network attribute structure
     D p_NA            S               *
     D NA              ds                  based(p_NA)
     D*                                    Attribute Name
     D   NA_Attr                     10A
     D*                                    Type of Data.  C=Char, B=Binary
     D   NA_Type                      1A
     D*                                    Status. L=Locked, Blank=Normal
     D   NA_Status                    1A
     D*                                    Length of Data
     D   NA_Length                   10I 0
     D*                                    Actual Data (in character)
     D   NA_DataChr                1000A
     D*                                    Actual Data (in binary)
     D   NA_DataInt                  10I 0 overlay(NA_DataChr:1)

     C* Call API to get system name
     C*   -1 = API returned an error
     C                   callp     QWCRNETA(RV: %size(RV): 1: 'SYSNAME': EC)
     c                   if        EC_BytesA > 0
     c                   return    -1
     c                   endif

     C*   -2 = RcvVar contained data that we
     C*        dont understand :(
     c                   if        RV_Attrs <> 1
     c                               or RV_Offset < 8
     c                               or RV_Offset > 1000
     c                   return    -2
     c                   endif

     C*   Attach NetAttr structure
     c                   eval      RV_Offset = RV_Offset - 7
     c                   eval      p_NA = %addr(RV_Data(RV_Offset))

     C*   -3 = NetAttr structure had data
     C*        that we don't understand :(
     c                   if        NA_Attr <> 'SYSNAME'
     c                               or NA_Length < 1
     c                               or NA_Length > 8
     c                   return    -3
     c                   endif

     C*   -4 = Network attributes are locked
     c                   if        NA_Status = 'L'
     c                   return    -4
     c                   endif

     C*   Ahhh... we got it!
     c                   eval      SysName = %subst(NA_DataChr:1:NA_Length)
     c                   return    0
     P                 E
