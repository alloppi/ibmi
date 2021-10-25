      * https://www.scottklement.com/rpg/pointers.html#topic7

      * CRTRPGMOD MODULE(LISTMBRR4) SRCFILE(*CURLIB/QRPGLESRC) DBGVIEW(*LIST)
      * CRTPGM PGM(LISTMBRR4) BNDSRVPGM(OFFSETR4)

      ******************************************************************
      * API Error Code Structure -- used with most non-bindable API's
      ******************************************************************
     D dsEC            DS
     D*                                    Bytes Provided (size of struct)
     D  dsECBytesP             1      4B 0 inz(256)
     D*                                    Bytes Available (returned by API)
     D  dsECBytesA             5      8B 0 inz(0)
     D*                                    Msg ID of Error Msg Returned
     D  dsECMsgID              9     15
     D*                                    Reserved
     D  dsECReserv            16     16
     D*                                    Msg Data of Error Msg Returned
     D  dsECMsgDta            17    256


      ******************************************************************
      ** List Header (Generic Header for List API's)
      ******************************************************************
     D p_GenHdr        S               *
     D dsLH            DS                   BASED(p_GenHdr)
     D*                                     User Area
     D   dsLHUsrAra                  64A
     D*                                     Size of Generic Header
     D   dsLHSize                    10I 0
     D*                                     Data structure release & level
     D   dsLHDsLvl                    4A
     D*                                     Format Name
     D   dsLHFormat                   8A
     D*                                     API that generated this
     D   dsLHAPI                     10A
     D*                                     Date & Time generated
     D   dsLHCrtDT                   13A
     D*                                     Status (I=Incomplete,C=Complete
     D*                                             F=Partially Complete)
     D   dsLHStatus                   1A
     D*                                     Size Of User Space Used
     D   dsLHSpcSiz                  10I 0
     D*                                     Offset to input parms section
     D   dsLHInpOff                  10I 0
     D*                                     Size of input parms section
     D   dsLHInpSiz                  10I 0
     D*                                     Header section offset
     D   dsLHHdrOff                  10I 0
     D*                                     Header section size
     D   dsLHHdrSiz                  10I 0
     D*                                     List section offset
     D   dsLHLstOff                  10I 0
     D*                                     List section size
     D   dsLHLstSiz                  10I 0
     D*                                     Count of Entries in List
     D   dsLHEntCnt                  10I 0
     D*                                     Size of a single entry
     D   dsLHEntSiz                  10I 0
     D*                                     CCSID of data in list section
     D   dsLHCCSID                   10I 0
     D*                                     Country ID
     D   dsLHCntry                    2A
     D*                                     Language ID
     D   dsLHLang                     3A
     D*                                     Subsetted List Ind
     D   dsLHSubSet                   1A
     D*                                     Reserved
     D   dsLHReserv                  42A

      ******************************************************************
      * Prototypes:
      ******************************************************************
      * Create User Space API
      *
     D CrtUsrSpc       PR                  ExtPgm('QUSCRTUS')
     D   UsrSpc                      20A   Const                                quali user space nam
     D   ExtAttr                     10A   Const                                extend attribute
     D   InitSiz                     10I 0 Const                                initial size
     D   InitVal                      1A   Const                                initial value
     D   PubAuth                     10A   Const                                public authority
     D   Text                        50A   Const                                text description
     D   Replace                     10A   Const Options(*nopass)               replace
     D   ErrorCode                  256A   Options(*varsize: *nopass)           error code

      * Retrieve Pointer to User Space API
      *
     D RtvPtrUS        PR                  ExtPgm('QUSPTRUS')
     D   UsrSpc                      20A   Const                                quali user space nam
     D   PtrUsrSpc                     *                                        return pointer
     D   ErrorCode                  256A   Options(*varsize: *nopass)           error code

      * List Members (QUSLMBR) API
      *
     D ListMbrs        PR                  ExtPgm('QUSLMBR')
     D   UsrSpc                      20A   Const                                quali user space nam
     D   Format                       8A   Const                                format name
     D   DataBase                    20A   Const                                qualified file name
     D   Member                      10A   Const                                record format name
     D   Override                     1A   Const                                override format name
     D   ErrorCode                  256A   Options(*varsize: *nopass)           error code

      * OffsetPtr service program:
      *
     D/COPY QRPGLESRC,OFFSET_H

      ******************************************************************
      * Local variables:
      ******************************************************************
     D p_MbrName       S               *
     D MbrName         S             10A   BASED(p_MbrName)
     D Offset          S             10I 0
     D Msg             S             50A


      *** Create the User Space QTEMP/MBRDATA
     c                   callp     CrtUsrSpc('MBRDATA   QTEMP': 'USRSPC':
     c                             1: x'00': '*ALL': 'List of Members in File':
     c                             '*YES': dsEC)

     c                   if        dsECBytesA > 0
     c                   eval      Msg = 'Error ' + dsECMsgID + ' calling -
     c                             QUSCRTUS API!'
     c                   dsply                   Msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif


      *** Ask the List Members API to put a list of members in the
      ***   QRPGLESRC file into the desired user space:
     c                   callp     ListMbrs('MBRDATA   QTEMP':'MBRL0100':
     c                             'QRPGLESRC *LIBL':'*ALL':'0':dsEC)

     c                   if        dsECBytesA > 0
     c                   eval      Msg = 'Error ' + dsECMsgID + ' calling -
     c                             QUSLMBR API'
     c                   dsply                   Msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif

      *** Get a pointer to the start of the user space.
     C                   callp     RtvPtrUS('MBRDATA   QTEMP':p_GenHdr)


      *** Loop through the list of members, each time changing the
      ***   p_MbrName pointer to point to the next member in the list
     c                   do        dsLHEntCnt    Entry             4 0
     c                   eval      Offset = ((Entry-1) * dsLHEntSiz)
     c                               + dsLHLstOff
     c                   eval      p_MbrName = OffsetPtr(p_GenHdr: Offset)
     c     MbrName       dsply
     c                   enddo

     c                   eval      Msg = 'Press ENTER to end program'
     c                   dsply                   Msg

      *** End Program
     c                   eval      *InLr = *On
     c                   Return
