      *====================================================================*
      * Program name: JSONEX3                                              *
      * Purpose.....: JSON and REST API Example with OAuth authentication  *
      *                                                                    *
      * Description : Update Data after Parasing                           *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2021/07/23 Alan       AC              New Develop                  *
      *====================================================================*

     H Debug(*Yes)
     H DftActGrp(*No) ActGrp(*Caller) Option(*SrcStmt) DecEdit('0.')
     H BndDir('YAJL/YAJL')

     FJSONTREEF IF   E           K Disk     UsrOpn                              JSON Tree File

     FJSOLPF01  IF A E           K Disk     UsrOpn Commit                       Order List Parsed Fi
     FJSTUEF01  IF A E           K Disk     UsrOpn Commit                       TU Parsed File

     FJSRNPF01  IF A E           K Disk     UsrOpn Commit                       Result Notice Parasd
     FJSSRPF01  IF A E           K Disk     UsrOpn Commit                       Success Result Paras
     FJSCFPF01  IF A E           K Disk     UsrOpn Commit                       Confirm Parasd File

      * Parameters
     D P_ApiType       s              1a

     D K_PATH          s                    Like(JSONPATH)

      /include YAJL/QRPGLESRC,yajl_h
      *
     c     *Entry        PList
     c                   Parm                    P_APIType

     c                   Eval      K_PATH = '/header/resCode'
     c     K_PATH        Chain     JSONTREEFR                         96
     c                   If        *In96
     c                             or (Not *In96 and JSONVAL <> OP0000)
     c     '0001'        Dump
     c                   Goto      $EndPgm
     c                   EndIf

     c     $EndPgm       Tag
     c                   Eval      *inlr = *on
     c                   Return
