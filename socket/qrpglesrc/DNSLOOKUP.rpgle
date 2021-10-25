      *********************************************************
      * Usage:
      *     CALL DNSLOOKUP PARM('STDTIME.GOV.HK')
      *  or CALL DNSLOOKUP PARM('118.143.17.82')
      *********************************************************
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     D inet_addr       PR            10U 0 ExtProc('inet_addr')
     D  address_str                    *   value options(*string)

     D INADDR_NONE     C                   CONST(4294967295)

     D inet_ntoa       PR              *   ExtProc('inet_ntoa')
     D  internet_addr                10U 0 value

     D p_hostent       S               *
     D hostent         DS                  Based(p_hostent)
     D   h_name                        *
     D   h_aliases                     *
     D   h_addrtype                  10I 0
     D   h_length                    10I 0
     D   h_addr_list                   *
     D p_h_addr        S               *   Based(h_addr_list)
     D h_addr          S             10U 0 Based(p_h_addr)

     D gethostbyname   PR              *   extproc('gethostbyname')
     D   host_name                     *   value options(*string)

     D host            S             32A
     D IP              S             10U 0
     D Msg             S             50A

     c     *entry        plist
     c                   parm                    host

     c                   eval      IP = inet_addr(%trim(host))

     c                   if        IP = INADDR_NONE
     c                   eval      p_hostent = gethostbyname(%trim(host))
     c                   if        p_hostent <> *NULL
     c                   eval      IP = h_addr
     c                   endif
     c                   endif

     c                   if        IP = INADDR_NONE
     c                   eval      Msg = 'Host not found!'
     c                   else
     c                   eval      Msg = 'IP = ' + %str(inet_ntoa(IP))
     c                   endif

     c                   dsply                   Msg

     c                   eval      *inlr = *on

