      **********************************************************************
      * Program name: SCKSRVR                                              *
      * Purpose.....: Socket Enquiry Program (Socket Program)              *
      * Spec        :                                                      *
      *                                                                    *
      * Date written: 2007/02/07                                           *
      *                                                                    *
      *                                                                    *
      * Create this Service Program with the following Commands.           *
      * - CrtRpgMod command (option 15 in PDM)                             *
      * - CrtSrvPgm specifying Export (*ALL)                               *
      *                                                                    *
      * Remarks:                                                           *
      * For programs wishing to use this service program should be         *
      * cmpilied with the CrtRpgMod command.  Then, issue the              *
      * CrtPgm command spicifying BndSrvPgm(SCKSRVR).                      *
      *                                                                    *
      * Modification:                                                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2007/02/07 Alan                       New                          *
      **********************************************************************

     H NoMain
     H BndDir( 'QC2LE' )

      *
      * Prototype Definitions
      *

     D opn_tcp         pr            10i 0

     D bnd_tcp         pr            10i 0
     d  socket                       10i 0 Const
     d  port                         10i 0 Const
     d  len                          10i 0 Const

     D con_tcp         pr            10i 0
     d  socket                       10i 0 Const
     d  host                         30
     d  hostlen                       2  0 Const
     d  port                          5  0 Const

     D snd_tcp         pr            10i 0
     d  socket                       10i 0 Const
     d* data                         50
     d  data                      32650

     D rcv_tcp         pr            10i 0
     d  socket                       10i 0 Const
     d* data                         50
     d  data                      32650

     D cls_tcp         pr            10i 0
     d  socket                       10i 0 Const

     D give_Ds         pr            10i 0
     d  jobid                        20
     d  socket                       10i 0 Const

     D take_Ds         pr            10i 0
     d  jobid                        20

      * Variables
     D null            c                   const(x'00')

      *----------------------------------------------------------------
      * Open Socket
      *----------------------------------------------------------------

     P opn_tcp         B                   export
     D opn_tcp         pi            10i 0

     D retSd           s             10i 0
     D opnskt          PR            10i 0 extproc('socket')
     d                               10i 0 value
     d                               10i 0 value
     d                               10i 0 value
      * Parameter in opnskt(2:1:0)
      * 2 - indicate standard Internet addressing
      * 1 - indicate stream sockets
      * 0 - indicate that the default protocol for stream sockets (TCP) should be used
      * retSd >= 0 is success
     C                   Eval      retSd = opnskt(2:1:0)
     c                   Return    retSd

     Popn_tcp          E

      *----------------------------------------------------------------
      * End - Open Socket
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Bind/Listen/Accept -- server side
      * A server program must bind the socket descriptor to the local system IP address and to a por
      * t number assigned to the program (But now set $IP to 0 (so that the server program will
      * accept input from any valid IP address for the server)
      *
      * accept() function creates a new socket that maintains the connection between the server and
      * client programs. The original socket remains open for other incoming connection requests. On
      * ce a connection is established between the server and client programs, you can use any of th
      * e socket data transfer functions.
      *----------------------------------------------------------------
     P bnd_tcp         B                         export

     D bnd_tcp         pi            10i 0
     d retSd                         10i 0 Const
     d iport                         10i 0 Const
     d qlen                          10i 0 Const

     D size            s             10i 0
     D addr            s               *
     d retCd           s             10i 0
     d clnSd           s             10i 0
     D OptVal          S             10I 0 Inz( 1 )
     D OptValPtr       S               *   Inz( %Addr( OptVal ) )
     D LenOptVal       S             10I 0 Inz( %Size( OptVal ) )

     D addr1           ds
     d  $family                       5i 0
     d  $port                         5u 0
     d  $ip                          10u 0
     d  $zero                         8

      * Bind - Sets the local address for the socket
     D Bind            pr            10i 0 extproc('bind')
     d                               10i 0 value
     d                                 *   value
     d                               10i 0 value

      * listen - invites incoming connection requests
     D listen          pr            10i 0 extproc('listen')
     d                               10i 0 value
     d                               10i 0 value

      * accept - waits for a connection request
     D accept          pr            10i 0 extproc('accept')
     d                               10i 0 value
     d                                 *   value
     d                                 *   value

     D SetSockOpt      PR            10I 0 ExtProc( 'setsockopt' )
     D  Sckt                         10I 0 Value
     D  Level                        10I 0 Value
     D  Opt                          10I 0 Value
     D  OptValPtr                      *   Value
     D  OptValLen                    10I 0 Value

     D Socket          PR            10I 0 ExtProc( 'socket'  )
     D  AddrFam                      10I 0 Value
     D  SckType                      10I 0 Value
     D  Protocol                     10I 0 Value

      * Allow socket descriptor to be reuseable
     C                   Eval      retCd    = SetSockOpt( retSd:
     C                                                    -1:
     C                                                    55:
     C                                                    OptValPtr:
     C                                                    LenOptVal )
      * $Family = 2 (Internet Addressing), $ip = 0 (listen all IP address)
     c                   eval      $family = 2
     c                   eval      $port = iport
     c                   eval      $ip   = 0
     c                   move      *allx'00'     $zero
     c                   eval      addr = %addr(addr1)
     c                   eval      size = %size(addr)
      * Bind
     c                   eval      retCd = bind(retSd:addr:size)
      * Listen
     c                   if        retCd =  -1
     c                   return    -1
     c                   endif

     c                   eval      retCd = listen(retSd:qlen)

      * Accept
     c                   if        retCd = -1
     c                   return    -1
     c                   endif

     c                   eval      clnSd = accept(retSd:addr:%addr(size))
     c                   return    clnSd
     P bnd_tcp         E

      *----------------------------------------------------------------
      * End - Bind/Listen/Accept -- server side
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Connect socket - establishes the connection
      *----------------------------------------------------------------
     P con_tcp         B                   export
     D con_tcp         pi            10i 0
     d  retSd                        10i 0 Const
     d  rmthost                      30
     d  rmthlen                       2  0 Const
     d  rmtport                       5  0 Const

     D retCd           s             10i 0
     D size            s             10i 0
     D addr            s               *

     D addr1           ds
     d  $family                       5i 0
     d  $port                         5u 0
     d  $ip                          10u 0
     d  $zero                         8

     D connect         pr            10i 0 extproc('connect')
     d                               10i 0 value
     d                                 *   value
     d                               10i 0 value

     D inet_addr       pr            10u 0 extproc('inet_addr')
     d                                 *   value

     C                   eval      rmthost=rmthost+null

     c                   eval      $ip = inet_addr(%addr(rmthost))
     c                   eval      $port = rmtport
     c                   move      *allx'00'     $zero
     c                   eval      $family = 2
     c                   eval      addr = %addr(addr1)
     c                   eval      size = %size(addr)

     c                   eval      retCd=connect(retSd:addr:size)

     c                   Return    retCd
     P con_tcp         E
      *----------------------------------------------------------------
      * End - Connect socket
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Send - sends data
      *----------------------------------------------------------------
     P snd_tcp         B                   export

     D snd_tcp         pi            10i 0
     d  retSd                        10i 0 Const
     d* Sndstr                       50
     d  Sndstr                    32650

     d retCd           s             10i 0
     d flag            s             10i 0
     d Sndstrlen       s             10i 0
     d addr            s               *

     D send            pr            10i 0 extproc('send')
     d                               10i 0 value
     d                                 *   value
     d                               10i 0 value
     d                               10i 0 value

     C                   eval      flag = 0
     c                   eval      sndstr = %trim(sndstr) + null
     c     null          scan      sndstr        sndstrlen
     c                   eval      addr = %addr(Sndstr)
     c                   eval      retCd=send(retSd:addr:Sndstrlen:flag)
     c                   return    retCd

     P snd_tcp         E
      *----------------------------------------------------------------
      * End - Send
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Receive - receives data
      *----------------------------------------------------------------
     P rcv_tcp         B                   export

     D rcv_tcp         pi            10i 0
     d  retSd                        10i 0 Const
     d* Rcvstr                       50
     d  Rcvstr                    32650

     d retCd           s             10i 0
     d Rcvstrlen       s             10i 0
     d addr            s               *
     d flag            s             10i 0

     D recv            pr            10i 0 extproc('recv')
     d                               10i 0 value
     d                                 *   value
     d                               10i 0 value
     d                               10i 0 value

     c                   eval      flag = 0
     c                   eval      addr = %addr(Rcvstr)
     c*                  eval      Rcvstrlen =    50
     c                   eval      Rcvstrlen = 32650
     c                   eval      retCd=recv(retSd:addr:Rcvstrlen:flag)
     c                   return    retCd

     P rcv_tcp         E
      *----------------------------------------------------------------
      * End - Receive
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Close Socket - terminates the connection
      *----------------------------------------------------------------
     P cls_tcp         B                   export
     D cls_tcp         pi            10i 0
     d  retSd                        10i 0 Const

     d retCd           s             10i 0
     D closkt          PR            10i 0 extproc('close')
     d                               10i 0 value
      * Close
     c                   eval      retCd = closkt(retsd)
     c                   Return    retCd
     P cls_tcp         E
      *----------------------------------------------------------------
      * End - Close
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Give Descriptor - let a socket created in one job be used by another job
      *----------------------------------------------------------------

     P give_Ds         B                   export

     D give_Ds         pi            10i 0
     d  tgt_jobid                    20
     d  sD                           10i 0 Const

     d #bpos           s              2  0
     d retCd           s             10i 0
     d addr            s               *
     D giveds          pr            10i 0 extproc('givedescriptor')
     d                               10i 0 value
     d                                 *   value

     c     ' '           scan      tgt_jobid     #bpos
     c                   eval      %subst(tgt_jobid:#bpos:1) = X'00'
     c                   eval      addr = %addr(tgt_jobid)
     c                   eval      retcD= giveds(sD:addr)

     c                   return    retCd

     P give_Ds         E

      *---------------------------------------------------------------
      * End - Give Descriptor
      *---------------------------------------------------------------

      *---------------------------------------------------------------
      * Take Descriptor - let a socket created in one job be used by another job
      *---------------------------------------------------------------

     P take_Ds         B                   export

     D take_Ds         pi            10i 0
     d  src_jobid                    20

     d #bpos           s              2  0
     d sD              s             10i 0
     d addr            s               *
     D takeds          pr            10i 0 extproc('takedescriptor')
     d                                 *   value

     c     ' '           scan      src_jobid     #bpos
     c                   eval      %subst(src_jobid:#bpos:1) = X'00'

     c                   eval      addr = %addr(src_jobid)
     c                   eval      sD = takeds(addr)

     c                   return    sD
     P take_Ds         E

      *---------------------------------------------------------------
      * End - Take Descriptor
      *---------------------------------------------------------------

