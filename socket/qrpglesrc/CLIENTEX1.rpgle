     H DFTACTGRP(*NO) ACTGRP(*NEW)

     D getservbyname   PR              *   ExtProc('getservbyname')
     D  service_name                   *   value options(*string)
     D  protocol_name                  *   value options(*string)

     D p_servent       S               *
     D servent         DS                  based(p_servent)
     D   s_name                        *
     D   s_aliases                     *
     D   s_port                      10I 0
     D   s_proto                       *

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

     D socket          PR            10I 0 ExtProc('socket')
     D  addr_family                  10I 0 value
     D  type                         10I 0 value
     D  protocol                     10I 0 value

     D AF_INET         C                   CONST(2)
     D SOCK_STREAM     C                   CONST(1)
     D IPPROTO_IP      C                   CONST(0)

     D connect         PR            10I 0 ExtProc('connect')
     D  sock_desc                    10I 0 value
     D  dest_addr                      *   value
     D  addr_len                     10I 0 value

     D p_sockaddr      S               *
     D sockaddr        DS                  based(p_sockaddr)
     D   sa_family                    5I 0
     D   sa_data                     14A
     D sockaddr_in     DS                  based(p_sockaddr)
     D   sin_family                   5I 0
     D   sin_port                     5U 0
     D   sin_addr                    10U 0
     D   sin_zero                     8A

     D send            PR            10I 0 ExtProc('send')
     D   sock_desc                   10I 0 value
     D   buffer                        *   value
     D   buffer_len                  10I 0 value
     D   flags                       10I 0 value

     D recv            PR            10I 0 ExtProc('recv')
     D   sock_desc                   10I 0 value
     D   buffer                        *   value
     D   buffer_len                  10I 0 value
     D   flags                       10I 0 value

     D close           PR            10I 0 ExtProc('close')
     D  sock_desc                    10I 0 value

     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   data                     32766A   options(*varsize)
     D   table                       10A   const

     D msg             S             50A
     D sock            S             10I 0
     D port            S              5U 0
     D addrlen         S             10I 0
     D ch              S              1A
     D host            s             32A
     D file            s             32A
     D IP              s             10U 0
     D p_Connto        S               *
     D RC              S             10I 0
     D Request         S             60A
     D ReqLen          S             10I 0
     D RecBuf          S             50A
     D RecLen          S             10I 0

     C*************************************************
     C* The user will supply a hostname and file
     C*  name as parameters to our program...
     C*************************************************
     c     *entry        plist
     c                   parm                    host
     c                   parm                    file

     c                   eval      *inlr = *on

     C*************************************************
     C* what port is the http service located on?
     C*************************************************
     c                   eval      p_servent = getservbyname('http':'tcp')
     c                   if        p_servent = *NULL
     c                   eval      msg = 'Can''t find the http service!'
     c                   dsply                   msg
     c                   return
     c                   endif

     c                   eval      port = s_port

     C*************************************************
     C* Get the 32-bit network IP address for the host
     C*  that was supplied by the user:
     C*************************************************
     c                   eval      IP = inet_addr(%trim(host))
     c                   if        IP = INADDR_NONE
     c                   eval      p_hostent = gethostbyname(%trim(host))
     c                   if        p_hostent = *NULL
     c                   eval      msg = 'Unable to find that host!'
     c                   dsply                   msg
     c                   return
     c                   endif
     c                   eval      IP = h_addr
     c                   endif

     C*************************************************
     C* Create a socket
     C*************************************************
     c                   eval      sock = socket(AF_INET: SOCK_STREAM:
     c                                           IPPROTO_IP)
     c                   if        sock < 0
     c                   eval      msg = 'Error calling socket()!'
     c                   dsply                   msg
     c                   return
     c                   endif

     C*************************************************
     C* Create a socket address structure that
     C*   describes the host & port we wanted to
     C*   connect to
     C*************************************************
     c                   eval      addrlen = %size(sockaddr)
     c                   alloc     addrlen       p_connto

     c                   eval      p_sockaddr = p_connto
     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = IP
     c                   eval      sin_port = port
     c                   eval      sin_zero = *ALLx'00'

     C*************************************************
     C* Connect to the requested host
     C*************************************************
     C                   if        connect(sock: p_connto: addrlen) < 0
     c                   eval      msg = 'unable to connect to server!'
     c                   dsply                   msg
     c                   callp     close(sock)
     c                   return
     c                   endif

     C*************************************************
     C* Format a request for the file that we'd like
     C* the http server to send us:
     C*************************************************
     c                   eval      request = 'GET ' + %trim(file) +
     c                               ' HTTP/1.0' + x'0D25' + x'0D25'
     c                   eval      reqlen = %len(%trim(request))
     c                   callp     Translate(reqlen: request: 'QTCPASC')

     C*************************************************
     c*  Send the request to the http server
     C*************************************************
     c                   eval      rc = send(sock: %addr(request): reqlen:0)
     c                   if        rc < reqlen
     c                   eval      Msg = 'Unable to send entire request!'
     c                   dsply                   msg
     c                   callp     close(sock)
     c                   return
     c                   endif

     C*************************************************
     C* Get back the server's response
     C*************************************************
     c                   dou       rc<1
     C                   exsr      DsplyLine
     c                   enddo

     C*************************************************
     C*  We're done, so close the socket.
     C*   do a dsply with input to pause the display
     C*   and then end the program
     C*************************************************
     c                   callp     close(sock)
     c                   dsply                   pause             1
     c                   return

     C*===============================================================
     C* This subroutine receives one line of text from a server and
     C*  displays it on the screen using the DSPLY op-code
     C*===============================================================
     CSR   DsplyLine     begsr
     C*------------------------
     C*************************************************
     C* Receive one line of text from the HTTP server.
     C*  note that "lines of text" vary in length,
     C*  but always end with the ASCII values for CR
     C*  and LF.  CR = x'0D' and LF = x'0A'
     C*
     C* The easiest way for us to work with this data
     C* is to receive it one byte at a time until we
     C* get the LF character.   Each time we receive
     C* a byte, we add it to our receive buffer.
     C*************************************************
     c                   eval      reclen = 0
     c                   eval      recbuf = *blanks

     c                   dou       reclen = 50 or ch = x'0A'
     c                   eval      rc = recv(sock: %addr(ch): 1: 0)
     c                   if        rc < 1
     c                   leave
     c                   endif
     c                   if        ch<>x'0D' and ch<>x'0A'
     c                   eval      reclen = reclen + 1
     c                   eval      %subst(recbuf:reclen:1) = ch
     c                   endif
     c                   enddo

     C*************************************************
     C* translate the line of text into EBCDIC
     C* (to make it readable) and display it
     C*************************************************
     c                   if        reclen > 0
     c                   callp     Translate(reclen: recbuf: 'QTCPEBC')
     c                   endif
     c     recbuf        dsply
     C*------------------------
     Csr                 endsr

