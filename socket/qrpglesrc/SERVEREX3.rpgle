     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

      *** header files for calling service programs & APIs

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h

      *** Prototypes for externally called programs:

     D Translate       PR                  ExtPgm('QDCXLATE')
     D    peLength                    5P 0 const
     D    peBuffer                32766A   options(*varsize)
     D    peTable                    10A   const

      *** Prototypes for local subprocedures:

     D die             PR
     D   peMsg                      256A   const

     D NewListener     PR            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D NewClient       PR            10I 0
     D   peServ                      10I 0 value

     D ReadClient      PR            10I 0
     D   peClient                    10I 0 value

     D HandleClient    PR            10I 0
     D   peClient                    10I 0 value

     D EndClient       PR            10I 0
     D   peClient                    10I 0 value

     D GetLine         PR            10I 0
     D   peClient                    10I 0 value
     D   peLine                     256A

      *** Configuration

     D MAXCLIENTS      C                   CONST(100)

      *** Global Variables:

     D Msg             S            256A
     D to              S               *
     D tolen           S             10I 0
     D serv            S             10I 0
     D max             S             10I 0
     D rc              S             10I 0
     D C               S             10I 0
     D readset         S                   like(fdset)
     D excpset         S                   like(fdset)
     D endpgm          S              1N   inz(*off)

      *** Variables in the "client" data structure are kept
      *** seperate for each connected client socket.

     D Client          DS                  Occurs(MAXCLIENTS)
     D   sock                        10I 0
     D   wait                         1N
     D   rdbuf                      256A
     D   rdbuflen                    10I 0
     D   state                       10I 0
     D   line                       256A


     c                   eval      *inlr = *on

     c                   exsr      Initialize

     C*********************************************************
     C*  Main execution loop:
     C*
     C*     1) Make 2 descriptor sets.  One to check which
     C*         sockets have data to read, one to check which
     C*         sockets have exceptional conditions pending.
     C*         Each set will contain the listner socket, plus
     C*         each connected client socket
     C*
     C*    2) Call select() to find out which descriptors need
     C*         to be read from or have exceptions pending.
     C*         We have a timeout value set here as well.  It's
     C*         set to 1 minute if all sockets are waiting for
     C*         user input, or 1/10 second if the sockets need
     C*         us to write data to them.  (the 1/10 second is
     C*         just to keep this program from gobbling too
     C*         much CPU time)
     C*
     C*    3) Check to see if a user told us to shut down, or
     C*         if the job/subsystem/system has requested us to
     C*         end the program.
     C*
     C*    4) If the listener socket ("server socket") has data
     C*         to read, it means someone is trying to connect
     C*         to us, so call the NewClient procedure.
     C*
     C*    5) Check each socket for incoming data and load into
     C*         the appropriate read buffer.
     C*
     C*    6) Do the next "task" that each socket needs.
     C*         (could be sending a line of text, or waiting
     C*         for input, or disconnecting, etc)
     C*********************************************************
     c                   dow       1 = 1

     c                   exsr      MakeDescSets

     c                   eval      rc = select(max+1: %addr(readset):
     c                                *NULL: %addr(excpset): to)

     c                   exsr      ChkShutDown

     c                   if        rc > 0
     c                   if        FD_ISSET(serv: readset)
     c                   callp     NewClient(serv)
     c                   endif
     c                   exsr      CheckSockets
     c                   endif

     c                   exsr      DoClients

     c                   enddo


     C*===============================================================
     C* Initialize some program vars & set up a server socket:
     C*===============================================================
     CSR   Initialize    begsr
     C*------------------------
     c                   do        MAXCLIENTS    C
     c     C             occur     client
     c                   eval      sock = -1
     c                   callp     EndClient(C)
     c                   enddo

     c                   eval      tolen = %size(timeval)
     c                   alloc     tolen         to
     c                   eval      p_timeval = to

     C*********************************************************
     C* Start listening to port 4000
     C*********************************************************
     c                   eval      serv = NewListener(4000: Msg)
     c                   if        serv < 0
     c                   callp     die(Msg)
     c                   endif
     C*------------------------
     CSR                 endsr


     C*===============================================================
     C* This sets up the "readset" and "excpset" descriptor sets
     C*  for use with select().   It also calculates the appropriate
     C*  timeout value, and the maximum descriptor number to check
     C*===============================================================
     CSR   MakeDescSets  begsr
     C*------------------------
     c                   callp     FD_ZERO(readset)
     c                   callp     FD_SET(serv: readset)

     C* By default, set a 60 second timeout...  but if one or more
     C* of the client's is not in 'wait' mode, change that timeout
     C* to only 100,000 microseconds (1/10 second)
     c                   eval      tv_sec = 60
     c                   eval      tv_usec = 0
     c                   eval      max = serv

     c                   do        MAXCLIENTS    C
     c     C             occur     client
     c                   if        sock <> -1
     c                   callp     FD_SET(sock: readset)
     c                   if        not wait
     c                   eval      tv_sec = 0
     c                   eval      tv_usec = 100000
     c                   endif
     c                   if        sock > max
     c                   eval      max = sock
     c                   endif
     c                   endif
     c                   enddo

     C* We can just copy excpset to readset... no point in going thru
     C*  all of that again :)
     c                   eval      excpset = readset
     C*------------------------
     CSR                 endsr


     C*===============================================================
     C*  Check for a 'shutdown' condition.  If shutdown was requested
     C*  tell all connected sockets, and then close them.
     C*===============================================================
     CSR   ChkShutDown   begsr
     C*------------------------
     c                   shtdn                                        99
     c                   if        *in99 = *on
     c                   eval      endpgm = *On
     c                   endif

      * Note that the 'endpgm' flag can also be set by the
      *   'HandleClient' subprocedure, not just the code above...

     c                   if        endpgm = *on
     c                   do        MAXCLIENTS    C
     c     C             occur     client
     c                   if        sock <> -1
     c                   callp     WrLine(sock: 'Sorry!  We''re shutting ' +
     c                              'down now!')
     c                   callp     EndClient(C)
     c                   endif
     c                   enddo
     c                   callp     close(serv)
     c                   callp     Die('shut down requested...')
     c                   return
     c                   endif
     C*------------------------
     CSR                 endsr


     C*===============================================================
     C*  This loads any data that has been sent by the various client
     C*  sockets into their respective read buffers, and also checks
     C*  for clients that may have disconnected:
     C*===============================================================
     CSR   CheckSockets  begsr
     C*------------------------
     c                   do        MAXCLIENTS    C

     c     C             occur     client

     c                   if        sock <> -1

     c                   if        FD_ISSET(sock: readset)
     c                   if        ReadClient(C) < 0
     c                   callp     EndClient(C)
     c                   callp     FD_CLR(sock: excpset)
     c                   endif
     c                   endif

     c                   if        FD_ISSET(sock: excpset)
     c                   callp     EndClient(C)
     c                   endif

     c                   endif

     c                   enddo
     C*------------------------
     CSR                 endsr

     C*===============================================================
     C*  This finally gets down to "talking" to the client programs.
     C*  It switches between each connected client, and then sends
     C*  data or receives data as appropriate...
     C*===============================================================
     CSR   DoClients     begsr
     C*------------------------
     c                   do        MAXCLIENTS    C
     c     C             occur     client
     c                   if        sock <> -1
     c                   callp     HandleClient(C)
     c                   endif
     c                   enddo
     C*------------------------
     CSR                 endsr


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Create a new TCP socket that's listening to a port
      *
      *       parms:
      *         pePort = port to listen to
      *        peError = Error message (returned)
      *
      *    returns: socket descriptor upon success, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P NewListener     B
     D NewListener     PI            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D sock            S             10I 0
     D len             S             10I 0
     D bindto          S               *
     D on              S             10I 0 inz(1)
     D linglen         S             10I 0
     D ling            S               *
     D flags           S             10I 0

     C*** Create a socket
     c                   eval      sock = socket(AF_INET:SOCK_STREAM:
     c                                           IPPROTO_IP)
     c                   if        sock < 0
     c                   eval      peError = %str(strerror(errno))
     c                   return    -1
     c                   endif

     C*** Tell socket that we want to be able to re-use the server
     C***  port without waiting for the MSL timeout:
     c                   callp     setsockopt(sock: SOL_SOCKET:
     c                                SO_REUSEADDR: %addr(on): %size(on))

     C*** create space for a linger structure
     c                   eval      linglen = %size(linger)
     c                   alloc     linglen       ling
     c                   eval      p_linger = ling

     C*** tell socket to only linger for 2 minutes, then discard:
     c                   eval      l_onoff = 1
     c                   eval      l_linger = 120
     c                   callp     setsockopt(sock: SOL_SOCKET: SO_LINGER:
     c                                ling: linglen)

     C*** free up resources used by linger structure
     c                   dealloc(E)              ling

     C*** tell socket we don't want blocking...
     c                   eval      flags = fcntl(sock: F_GETFL)
     c                   eval      flags = flags + O_NONBLOCK
     c                   if        fcntl(sock: F_SETFL: flags) < 0
     c                   eval      peError = %str(strerror(errno))
     c                   return    -1
     c                   endif

     C*** Create a sockaddr_in structure
     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           bindto
     c                   eval      p_sockaddr = bindto

     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = INADDR_ANY
     c                   eval      sin_port = pePort
     c                   eval      sin_zero = *ALLx'00'

     C*** Bind socket to port
     c                   if        bind(sock: bindto: len) < 0
     c                   eval      peError = %str(strerror(errno))
     c                   callp     close(sock)
     c                   dealloc(E)              bindto
     c                   return    -1
     c                   endif

     C*** Listen for a connection
     c                   if        listen(sock: MAXCLIENTS) < 0
     c                   eval      peError = %str(strerror(errno))
     c                   callp     close(sock)
     c                   dealloc(E)              bindto
     c                   return    -1
     c                   endif

     C*** Return newly set-up socket:
     c                   dealloc(E)              bindto
     c                   return    sock
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This accepts a new client connection, and adds him to
      *   the 'client' data structure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P NewClient       B
     D NewClient       PI            10I 0
     D   peServ                      10I 0 value

     D X               S             10I 0
     D S               S             10I 0
     D cl              S             10I 0
     D flags           S             10I 0
     D ling            S               *
     D connfrom        S               *
     D len             S             10I 0
     D Msg             S             52A

     C*************************************************
     C* See if there is an empty spot in the data
     C* structure.
     C*************************************************
     c                   eval      cl = 0
     c                   do        MAXCLIENTS    X
     c     X             occur     Client
     c                   if        sock = -1
     c                   eval      cl = X
     c                   leave
     c                   endif
     c                   enddo

     C*************************************************
     C*  Accept new connection
     C*************************************************
     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           connfrom

     c                   eval      S = accept(peServ: connfrom: len)
     c                   if        S < 0
     c                   return    -1
     c                   endif

     c                   dealloc(E)              connfrom

     C*************************************************
     C* Turn off blocking & limit lingering
     C*************************************************
     c                   eval      flags = fcntl(S: F_GETFL: 0)
     c                   eval      flags = flags + O_NONBLOCK
     c                   if        fcntl(S: F_SETFL: flags) < 0
     c                   eval      Msg = %str(strerror(errno))
     c                   dsply                   Msg
     c                   return    -1
     c                   endif

     c                   eval      len = %size(linger)
     c                   alloc     len           ling
     c                   eval      p_linger = ling
     c                   eval      l_onoff = 1
     c                   eval      l_linger = 120
     c                   callp     setsockopt(S: SOL_SOCKET: SO_LINGER:
     c                                ling: len)
     c                   dealloc(E)              ling

     C*************************************************
     C*  If we've already reached the maximum number
     C*  of connections, let client know and then
     C*  get rid of him
     C*************************************************
     c                   if        cl = 0
     c                   callp     wrline(S: 'Maximum number of connect' +
     c                              'tions has been reached!')
     c                   callp     close(s)
     c                   return    -1
     c                   endif

     C*************************************************
     C*  Add client into the structure
     C*************************************************
     c     cl            occur     client
     c                   eval      sock = S
     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  If there is data to be read from a Client's socket, add it
      *    to the client's buffer, here...
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ReadClient      B
     D ReadClient      PI            10I 0
     D   peClient                    10I 0 value

     D left            S             10I 0
     D p_read          S               *
     D err             S             10I 0
     D len             S             10I 0

     c     peClient      occur     client

     c                   eval      left = %size(rdbuf) - rdbuflen
     c                   eval      p_read = %addr(rdbuf) + rdbuflen

     c                   eval      len = recv(sock: p_read: left: 0)
     c                   if        len < 0
     c                   eval      err = errno
     c                   if        err = EWOULDBLOCK
     c                   return    0
     c                   else
     c                   return    -1
     c                   endif
     c                   endif

     c                   eval      rdbuflen = rdbuflen + len
     c                   return    len
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This disconnects a client and cleans up his spot in the
      *    client data structure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndClient       B
     D EndClient       PI            10I 0
     D   peClient                    10I 0 value
     c     peClient      occur     client
     c                   if        sock >= 0
     c                   callp     close(sock)
     c                   endif
     c                   eval      sock = -1
     c                   eval      wait = *off
     c                   eval      rdbuf = *Blanks
     c                   eval      rdbuflen = 0
     c                   eval      state = 0
     c                   eval      line = *blanks
     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  As we're switching between each different client, this
      *  routine is called to handle whatever the next 'step' is
      *  for a given client.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HandleClient    B
     D HandleClient    PI            10I 0
     D   peClient                    10I 0 value

     c     peClient      occur     client

     c                   select
     c                   when      state = 0
     c                   callp     WrLine(sock: 'Please enter your name' +
     c                                   ' now!')
     c                   eval      state = 1

     c                   when      state = 1
     c                   eval      wait = *on
     c                   if        GetLine(peClient: line) > 0
     c                   eval      wait = *off
     c                   eval      state = 2
     c                   endif

     c                   when      state = 2
     c                   if        %trim(line) = 'quit'
     c                   eval      endpgm = *on
     c                   eval      state = 4
     c                   else
     c                   callp     WrLine(sock: 'Hello ' + %trim(line))
     c                   eval      state = 3
     c                   endif

     c                   when      state = 3
     c                   callp     WrLine(sock: 'Goodbye ' + %trim(line))
     c                   eval      state = 4

     c                   when      state = 4
     c                   callp     EndClient(peClient)
     c                   endsl

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This removes one line of data from a client's read buffer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P GetLine         B
     D GetLine         PI            10I 0
     D   peClient                    10I 0 value
     D   peLine                     256A

     D pos             S             10I 0

     C*** Load correct client:
     c     peClient      occur     client
     c                   if        rdbuflen < 1
     c                   return    0
     c                   endif

     C*** Look for an end-of-line character:
     c                   eval      pos = %scan(x'0A': rdbuf)
     c                   if        pos < 1 or pos > rdbuflen
     c                   return    0
     c                   endif

     C*** Add line to peLine variable, and remove from rdbuf:
     c                   eval      peLine = %subst(rdbuf:1:pos-1)

     c                   if        pos < %size(rdbuf)
     c                   eval      rdbuf = %subst(rdBuf:pos+1)
     c                   else
     c                   eval      rdbuf = *blanks
     c                   endif

     c                   eval      rdbuflen = rdbuflen - pos

     C*** If CR character found, remove that too...
     c                   eval      pos = pos - 1
     c                   if        %subst(peLine:pos:1) = x'0D'
     c                   eval      peLine = %subst(peLine:1:pos-1)
     c                   eval      pos = pos - 1
     c                   endif

     C*** Convert to EBCDIC:
     c                   if        pos > 0
     c                   callp     Translate(pos: peLine: 'QTCPEBC')
     c                   endif

     C*** return length of line:
     c                   return    pos
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This ends this program abnormally, and sends back an escape.
      *   message explaining the failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P die             B
     D die             PI
     D   peMsg                      256A   const

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32766A   options(*varsize)

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c                   eval      wwMsgLen = %len(%trimr(peMsg))
     c                   if        wwMsgLen<1
     c                   return
     c                   endif

     c                   callp     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsg: wwMsgLen: '*ESCAPE':
     c                               '*PGMBDY': 1: wwTheKey: dsEC)

     c                   return
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy socktut/qrpglesrc,errno_h
