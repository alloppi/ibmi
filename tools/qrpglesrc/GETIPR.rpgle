      *====================================================================*
      * Program name: GETIPR                                               *
      * Purpose.....: Return IP address for a given Host Name reading from *
      *               Host table                                           *
      * Description :                                                      *
      *   Reference Site:                                                  *
      *               http://www.think400.dk/adhoc_3.htm#eks0018           *
      *               http://www.code400.com/viewsamples.php?lang_id=10    *
      *   To compile:                                                      *
      *    CRTBNDRPG PGM(THTOLIB/GETIPR) SRCFILE(THNCILIB/QRPGSRC)         *
      *              DFTACTGRP(*NO) ACTGRP(*CALLER)                        *
      *   Input Parameter:                                                 *
      *               Host Name                                 P_Host     *
      *   Return Parameter:                                                *
      *               IP Address in xxx.xxx.xxx.xxx format      R_IP       *
      *               Return Code                               R_RtnCde   *
      *                                                                    *
      * Modification:                                                      *
      * -------------------------------------------------------------------*
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2012/11/12 Alan       AC              New Developement             *
      *====================================================================*
     H DEBUG(*YES)
04687H DFTACTGRP(*NO) ACTGRP(*CALLER)
      * Work fields
     D gethostbyname   PR              *   extproc('gethostbyname')
     D   host_name                     *   value options(*string)
      *
     D pt_hostent      S               *
     D hostent         DS                  Based(pt_hostent)
     D   h_name                        *
     D   h_aliases                     *
     D   h_addrtype                  10I 0
     D   h_length                    10I 0
     D   h_addr_list                   *
      *
      ** -------------------------------------------------------------------
      **    inet_ntoa()--Converts an address from 32-bit IP address to
      **         dotted-decimal format.
      **
      **         char *inet_ntoa(struct in_addr internet_address)
      **
      **    Converts from 32-bit to dotted decimal, such as, x'C0A80064'
      **    to '192.168.0.100'.  Will return -1 on error
      **
      ** -------------------------------------------------------------------
     D inet_ntoa       PR              *   ExtProc('inet_ntoa')
     D  ulong_addr                   10U 0 VALUE
      ** -------------------------------------------------------------------
      ** "Special" IP Address values for reference only
      ** May be used later on
      ** -------------------------------------------------------------------
     D*                                                any address availabl
     D*INADDR_ANY      C                   CONST(0)
     D*                                                broadcast
     D*INADDR_BRO      C                   CONST(4294967295)
     D*                                                loopback/localhost
     D*INADDR_LOO      C                   CONST(2130706433)
     D*                                                no address exists
     D*INADDR_NON      C                   CONST(4294967295)
      ** -------------------------------------------------------------------
      *
     D pt_h_addr       S               *   Based(h_addr_list)
     D h_addr          S             10U 0 Based(pt_h_addr)
      ** -------------------------------------------------------------------

      * http://www.scottklement.com/rpg/socktut/dns.html
      * http://publib.boulder.ibm.com/pubs/html/as400/v4r5/ic2924/info/apis/inaddr.htm
      * IBM tells us that the prototype for the inet_addr procedure looks like this:
      *         unsigned long inet_addr(char *address_string)
      * This means that the procedure is named 'inet_addr', and it accepts one parameter,
      * called 'address_string', which is a pointer to a character string.
      * It returns an unsigned long integer, which in RPG is expressed as '10U 0'.
      * it returns the 32-bit network address when successful. And returns a -1 when it's not
      * successful.
      * In C, -1 is x'FFFFFFFF'.
      * UNSIGED Interger have value of -1 , ie x'FFFFFFFF'.
      * x'00000001' is a positive 1, twos complement format => x'FFFFFFFE', then plus 1 =>
      * x'FFFFFFFF'

     D inet_addr       PR            10U 0 ExtProc('inet_addr')
     D  address_str                    *   value options(*string)
      ** -------------------------------------------------------------------
      *
     D P_host          S             32A
     D*IP32b           S             10U 0
     D msg             S             50A
     D*** internal "work" variables. (not part of /COPY file)
     D wkInput         S            256A
     D wkLen           S             10I 0
     D pt_Name         S               *   INZ(*NULL)
     D wkName          S            256A   BASED(pt_Name)
      *
     D R_IP            S             15A
     D R_RtnCde        S              2P 0
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
      *
     C     *Entry        Plist
     C                   Parm                    P_Host
     C                   Parm                    R_IP
     C                   Parm                    R_rtnCde
      *
     C*************************************************
     C* Get the 32-bit network IP address for the host
     C*  that was supplied by the user:
     C*************************************************
      * Use inet_addr check P_host is in x.x.x.x or valid or not
     C*                  eval      IP32b = inet_addr(%trim(P_host))
     C*                  if        IP32b = INADDR_NONE
      *
     C                   eval      pt_hostent = gethostbyname(%trim(P_host))
     C                   if        pt_hostent = *NULL
     C                   Eval      R_RtnCde = 1
     C     '001'         Dump
     C                   GoTo      $End
     C                   endif
     C**                 eval      IP32b = h_addr
     C*                  endif
     C
     C* if we're returning an address, we'll need to use inet_ntoa
     C*  to convert it back to dotted-decimal x.x.x.x format.
     C*
     C                   Eval      pt_name = inet_ntoa(h_addr)
     C                   If        pt_name = *NULL
     C                   Eval      R_RtnCde = 1
     C     '002'         Dump
     C                   GoTo      $End
     c                   Else
     C     x'00'         Scan      wkName        wkLen
     C                   Eval      R_IP  = %subst(wkName:1:wkLen-1)
     C                   Endif
      *
     C     $End          Tag
     C                   Eval      *InLr = *On
     C                   Return
      *
      *====================================================================*
      * *InzSr
      *====================================================================*
     C     *InzSr        BegSr
      *
     C                   Eval      R_RtnCde = *Zero
     C                   EndSr
