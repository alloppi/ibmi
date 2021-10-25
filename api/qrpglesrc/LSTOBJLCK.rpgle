      * Refer http://www.think400.dk/apier_1.htm#eks0020

     H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT)

     D CrtUsrSpc       PR                  ExtPgm('QUSCRTUS')
     D   UsrSpc                      20A   CONST
     D   ExtAttr                     10A   CONST
     D   InitSize                    10I 0 CONST
     D   InitVal                      1A   CONST
     D   PublicAuth                  10A   CONST
     D   Text                        50A   CONST
     D   Replace                     10A   CONST
     D   ErrorCode                32766A   options(*varsize)

     D RtvPtrUS        PR                  ExtPgm('QUSPTRUS')
     D   UsrSpc                      20A   CONST
     D   Pointer                       *

     D LstObjLck       PR                  ExtPgm('QWCLOBJL')
     D   UsrSpc                      20A   const
     D   Format                       8A   const
     D   Object                      20A   const
     D   ObjType                     10A   const
     D   Member                      10A   const
     D   ErrorCode                32766A   options(*varsize)

     D*****************************************************
     D* API error code data structure
     D*****************************************************
     D dsEC            DS
     D*                                    Bytes Provided (size of struct)
     D  dsECBytesP             1      4I 0 INZ(256)
     D*                                    Bytes Available (returned by API)
     D  dsECBytesA             5      8I 0 INZ(0)
     D*                                    Msg ID of Error Msg Returned
     D  dsECMsgID              9     15
     D*                                    Reserved
     D  dsECReserv            16     16
     D*                                    Msg Data of Error Msg Returned
     D  dsECMsgDta            17    256

     D*****************************************************
     D* List API generic header data structure
     D*****************************************************
     D dsLH            DS                   BASED(p_UsrSpc)
     D*                                     Filler
     D   dsLHFill1                  103A
     D*                                     Status (I=Incomplete,C=Complete
     D*                                             F=Partially Complete)
     D   dsLHStatus                   1A
     D*                                     Filler
     D   dsLHFill2                   12A
     D*                                     Header Offset
     D   dsLHHdrOff                  10I 0
     D*                                     Header Size
     D   dsLHHdrSiz                  10I 0
     D*                                     List Offset
     D   dsLHLstOff                  10I 0
     D*                                     List Size
     D   dsLHLstSiz                  10I 0
     D*                                     Count of Entries in List
     D   dsLHEntCnt                  10I 0
     D*                                     Size of a single entry
     D   dsLHEntSiz                  10I 0

     D*****************************************************
     D*  List Object Locks API format OBJL0100
     D*****************************************************
     D dsOL            DS                  based(p_Entry)
     D*                                     Job Name
     D  dsOL_JobName                 10A
     D*                                     Job User Name
     D  dsOL_UserName                10A
     D*                                     Job Number
     D  dsOL_JobNbr                   6A
     D*                                     Lock State
     D  dsOL_LckState                10A
     D*                                     Lock Status
     D  dsOL_LckSts                  10i 0
     D*                                     Lock Type
     D  dsOL_LckType                 10i 0
     D*                                     Member (or *BLANK)
     D  dsOL_Member                  10A
     D*                                     1=Shared File, 0=Not Shared
     D*                                        (or 0=not applicable)
     D  dsOL_Share                    1A
     D*                                     Lock Scope
     D  dsOL_LckScope                 1A
     D*                                     Thread identifier
     D  dsOL_ThreadID                 8A


     D p_UsrSpc        S               *
     D p_Entry         S               *
     D Msg             S             50A
     D x               S             10I 0

     C     *entry        plist
     c                   parm                    ObjName          10
     C                   parm                    ObjLib           10
     c                   parm                    ObjType          10
     c                   parm                    Member           10

     c                   eval      *inlr = *on

     c                   if        %parms < 4
     c                   eval      Msg = 'Usage: objlock NAME LIB TYPE MBR'
     c                   dsply                   Msg
     c                   return
     c                   endif

     C*******************************************
     C* Create a user space to store output of
     C*  the list object locks API
     C*******************************************
     c                   callp     CrtUsrSpc('OBJLOCKS  QTEMP': 'USRSPC':
     c                               1: x'00': '*ALL': 'Output of List ' +
     c                               'Object Locks API': '*YES': dsEC)
     c                   if        dsECBytesA > 0
     c                   eval      Msg = 'QUSCRTUS error ' + dsECMsgID
     c                   dsply                   msg
     c                   return
     c                   endif

     C*******************************************
     C* Dump the Object Locks to the user space
     C*******************************************
     c                   callp     LstObjLck('OBJLOCKS  QTEMP': 'OBJL0100':
     c                               ObjName+ObjLib: ObjType: Member: dsEC)
     c                   if        dsECBytesA > 0
     c                   eval      Msg = 'QWCLOBJL error ' + dsECMsgID
     c                   dsply                   msg
     c                   return
     c                   endif

     C*******************************************
     C*  Get a pointer to the user space
     C*******************************************
     c                   callp     RtvPtrUS('OBJLOCKS  QTEMP': p_UsrSpc)

     C*******************************************
     C* Read each entry in the list
     C*   and (for sake of example) display
     C*   the lock details
     C*******************************************
     c                   for       x = 0 to (dsLHEntCnt-1)
     c                   eval      p_Entry = p_UsrSpc +
     c                                 (dsLHLstOff + (dsLHEntSiz*x))

     c                   eval      Msg = 'Job = '+%trimr(dsOL_JobNbr) +'/'+
     c                                            %trimr(dsOL_UserName)+'/'+
     c                                            %trimr(dsOL_JobName)
     c     Msg           dsply

     c                   eval      Msg = 'Lock State = ' + dsOL_LckState
     c     Msg           dsply

     c                   select
     c                   when      dsOL_LckSts = 1
     c                   eval      Msg = 'Lock Status = HELD'
     c                   when      dsOL_LckSts = 2
     c                   eval      Msg = 'Lock Status = WAIT'
     c                   when      dsOL_LckSts = 2
     c                   eval      Msg = 'Lock Status = REQ'
     c                   endsl
     c     Msg           dsply

     c                   eval      Msg = 'Member = ' + dsOL_Member
     c     Msg           dsply

     c                   if        dsOL_Share = '1'
     c                   eval      Msg = 'Share lock = YES'
     c                   else
     c                   eval      Msg = 'Share lock = NO'
     c                   endif
     c     Msg           dsply

     c                   if        dsOL_LckScope = '1'
     c                   eval      Msg = 'Scope = THREAD'
     c                   else
     c                   eval      Msg = 'Scope = JOB'
     c                   endif
     c     Msg           dsply

     c                   eval      Msg = '<< PRESS ENTER >>'
     c                   dsply                   Msg

     c                   endfor
