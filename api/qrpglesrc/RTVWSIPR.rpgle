      *==============================================================*
      * Program name: RTVWSIPR                                       *
      * Purpose.....: Retrieve Current Workstation IP address        *
      * Remark......: Use Retrieve Device Description (QDCRDEVD) API *
      *                                                              *
      * Date written: 2018/03/16                                     *
      *                                                              *
      * Modification:                                                *
      * Date       Name       Pre  Ver  Mod#  Remarks                *
      * ---------- ---------- --- ----- ----- ---------------------- *
      * 2018/03/16 Alan       AC              New Development        *
      *==============================================================*
     H DftActGrp(*No) ActGrp(*Caller) BndDir('QC2LE')
      *
     D RtvIpAdr        PR            15a
     D  Device                       10a   const
      *
     D R_ClientIP      S             15a
      *
     D                SDS
     D  Device               244    253
      *
      *==============================================================*
     C     *Entry        PList
     C                   Parm                    R_ClientIP

      * Retrieve IP Address from Curent WorkStation
     C                   eval      R_ClientIP = RtvIpAdr(Device)

     C                   eval      *Inlr = *on

      *===================================================================*
      * RtvIpAdr - Subprocedure To Retrieve device IP Address
      *===================================================================*
     P RtvIpAdr        B
     D RtvIpAdr        PI            15a
     D  Inp_Device                   10a   const

     D ApiErr          DS
     D  Bytprv                 1      4B 0 inz(216)
     D  Bytavl                 5      8B 0 inz
     D  Errid                  9     15a   inz
     D  Rsvd                  16     16a   inz
     D  Errdta                17    216a   inz

     D Net_Address     S             15a   inz
     D Format          S              8A   inz('DEVD0600')
     D RcvVar          S           1000A   inz
     D VarLen          S              4B 0 inz(1000)

     C                   eval      Device = Inp_Device
     C                   call      'QDCRDEVD'
     C                   parm                    RcvVar
     C                   parm                    Varlen
     C                   parm                    Format
     C                   parm                    Device
     C                   parm                    ApiErr
     C                   if        BytAvl = 0
     C                   eval      Net_Address = %subst(RcvVar:878:15)
     C                   endif
     C                   return    Net_Address

     P RtvIpAdr        E
