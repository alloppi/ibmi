      * Refer to: http://www.think400.dk/apier_1.htm#eks0009

      * Use Option 15 to create module in QTEMP with DBGVIEW(*source)
      * CRTSRVPGM SRVPGM(GROUP) MODULE(QTEMP/GROUP) EXPORT(*ALL)

      * Retrieve User Information (QSYRUSRI) API:
      * https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/apis/qsyrusri.htm

     H NOMAIN

     D/COPY QRPGLESRC,GROUP_H
     P*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P*  IsInGroup( UserProfile : GroupProfile)
     P*       Checks if a user is in a given group profile.
     P*
     P*  Returns:  -1 = Error, 0 = Not In Group, 1 = Is In Group
     P*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P IsInGroup       B                   export
     D IsInGroup       PI            10I 0
     D   UsrPrf                      10A   const
     D   GrpPrf                      10A   const

     D RtvUsrPrf       PR                  ExtPgm('QSYRUSRI')
     D   RcvVar                   32766A   OPTIONS(*VARSIZE)
     D   RcvVarLen                   10I 0 const
     D   Format                       8A   const
     D   UsrPrf                      10A   const
     D   Error                    32766A   OPTIONS(*VARSIZE)

     D dsEC            DS
     D*                                    Bytes Provided (size of struct)
     D  dsECBytesP             1      4B 0 INZ(256)
     D*                                    Bytes Available (returned by API)
     D  dsECBytesA             5      8B 0 INZ(0)
     D*                                    Msg ID of Error Msg Returned
     D  dsECMsgID              9     15
     D*                                    Reserved
     D  dsECReserv            16     16
     D*                                    Msg Data of Error Msg Returned
     D  dsECMsgDta            17    256

     D* USRI0200 Format Receiver Variable Description
     D dsRU            DS
     D*                                    Bytes Returned
     D   dsRUBytRtn                  10I 0
     D*                                    Bytes Available
     D   dsRUBytAvl                  10I 0
     D*                                    User Profile Name
     D   dsRUUsrPrf                  10A
     D*                                    User Class
     D   dsRUClass                   10A
     D*                                    Special Authorities
     D   dsRUSpcAut                  15A
     D*                                    Group Profile Name
     D   dsRUGrpPrf                  10A
     D*                                    Owner
     D   dsRUOwner                   10A
     D*                                    Group Authority
     D   dsRUGrpAut                  10A
     D*                                    Limit Capabilities
     D   dsRULmtCap                  10A
     D*                                    Group Authority Type
     D   dsRUAutTyp                  10A
     D*                                    (reserved)
     D   dsRUResrv1                   3A
     D*                                    Offset to Supplemental Groups
     D   dsRUoffSG                   10I 0
     D*                                    Number of Supplemental Groups
     D   dsRUnumSG                   10I 0
     D*                                    Supplemental Groups
     D   dsRUSupGrp                  10A   DIM(15)

     D X               S              5I 0

     C* Get User Profile
     c                   callp     RtvUsrPrf( dsRU: %Size(dsRU): 'USRI0200':
     c                                           UsrPrf: dsEC)

     C* Check for errors
     c                   if        dsECBytesA > 0
     c                   return    -1
     c                   endif
     c                   if        dsRUnumSG<0 or dsRUnumSG>15
     c                   return    -1
     c                   endif

     C* In primary group?
     c                   if        dsRUGrpPrf = GrpPrf
     c                   return    1
     c                   endif

     C* In supplemental group?
     c                   do        dsRUnumSG     X
     c                   if        dsRUSupGrp(X) = GrpPrf
     c                   return    1
     c                   endif
     c                   enddo

     C* Not in group.
     c                   return    0
     P                 E
