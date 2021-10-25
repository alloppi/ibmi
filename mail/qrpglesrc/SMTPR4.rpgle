     /*-                                                                            +
      * Copyright (c) 2006-2009 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +

      *  Service Program to Implement the SMTP protocol
      *  System iNetwork Programming Tips Newsletter
      *                                  Scott Klement, Aug 17, 2006
      *
      *  To Compile:
      *      - The SMTP_H, SOCKET_H, STDIO_H, ICONV_H and SIGNAL_H
      *        members must be loaded into QRPGLESRC in your *LIBL
      *
      *      - The binder source (SMTPR4) must be in the QSRVSRC
      *        file in your *LIBL
      *
      *>    CRTRPGMOD SMTPR4 SRCFILE(SMTPUTIL) DBGVIEW(*LIST)
      *>    CRTSRVPGM SMTPR4 EXPORT(*SRCFILE) SRCFILE(QSRVSRC) TEXT(&X)
      *>    DLTMOD SMTPR4
      *
      *      - These commands should be run the first time (only)
      *         CRTBNDDIR mylib/SMTP
      *         ADDBNDDIRE mylib/SMTP OBJ(SMTPR4 *SRVPGM)
      *         ADDBNDDIRE mylib/SMTP OBJ(BASE64 *SRVPGM)
      *
     H NOMAIN OPTION(*SRCSTMT) BNDDIR('QC2LE' : 'BASE64')

      /copy SMTPUTIL,SMTP_H
      /copy SMTPUTIL,SOCKET_H
      /copy SMTPUTIL,STDIO_H
      /copy SMTPUTIL,ICONV_H
      /copy SMTPUTIL,SIGNAL_H
      /copy SMTPUTIL,BASE64_H

     D SMTP_t          ds                  qualified
     D   sock                        10I 0 inz(-1)
     D   timeout                     10I 0 inz(60)
     D   server                        *   inz(*NULL)
     D   addr                        10U 0 inz(0)
     D   port                        10I 0 inz(-1)
     D   to_ascii                          like(iconv_t)
     D   to_ebcdic                         like(iconv_t)

     D memcpy_t        ds                  qualified
     D                                     based(Template)
     D   loc                           *
     D   left                        10U 0

     D arycpy_t        ds                  qualified
     D                                     based(Template)
     D   base                          *
     D   size                        10I 0
     D   cur                         10I 0

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                  32767A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 8192A   options(*varsize)

     D NullError       DS                  qualified
     D  BytesProv                    10I 0 inz(0)
     D  BytesAvail                   10I 0 inz(0)

     D ErrorData       ds
     D   ErrorMsg                    80A   inz('No error')
     D   ErrorNo                      4S 0 inz(0)
     D   ErrorNoChar                  4A   overlay(ErrorNo)

     D p_SmtpServer    s               *   inz(*NULL)
     D SmtpServer      s            256A   varying based(p_SmtpServer)
     D*Logging         s              1N   inz(*OFF)
     D Logging         s              1N   inz(*ON)
     D Alarmed         s              1N   inz(*OFF)
     D*Alarmed         s              1N   inz(*ON)

     D CRLF            C                   x'0d25'

     D get_port        PR            10I 0
     D copy_stmf       PR             1N
     D   hfile                             like(pFILE)
     D   buf                      32767A   varying
     D copy_mem        PR             1N
     D   dta                               likeds(memcpy_t)
     D   buf                      32767A   varying
     D copy_array      PR             1N
     D   data                              likeds(arycpy_t)
     D   buf                      32767A   varying
     D SetError        PR
     D   num                          4S 0 value
     D   text                        80A   const
     D SetUnixError    PR
     D   num                          4S 0 value
     D   api                         50A   varying const
     D a2e             PR
     D   SMTP                              likeds(SMTP_t)
     D   data                     32767A   varying
     D e2a_real        PR            10U 0
     D   SMTP                              likeds(SMTP_t)
     D   input                    32767A   varying
     D   output                        *   value
     D   outputsize                  10U 0 value
     D e2a_ptr         s               *   procptr
     D e2a             PR            10U 0 extproc(e2a_ptr)
     D   SMTP                              likeds(SMTP_t)
     D   input                    32767A   varying const options(*varsize)
     D   output                   32767A   options(*varsize)
     D   outputsize                  10U 0 value
     D Response        PR            10I 0
     D   p_SMTP                            like(SMTP_HANDLE) value
     D RecvText        PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   text                     32767A   varying
     D SendText        PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   text                     32767A   varying const options(*varsize)
     D SMTP_hshake     PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D DebugMsg        PR
     D   msg                      32702A   varying options(*varsize) const
     D init_signals    PR
     D caught_alarm    PR
     D   signo                       10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_new():  Allocate & Init a new SMTP handle
      *
      *    server = (input) SMTP server to communicate with
      *                      or *OMIT for this machine's
      *      port = (input) TCP port number to use
      *                      or *OMIT for SMTP default port
      *
      *  returns the new SMTP handle object
      *       or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_new        B                   export
     D SMTP_new        PI                  like(SMTP_HANDLE)
     D   server                     256A   varying const
     D                                     options(*nopass: *omit)
     D   port                        10I 0 const
     D                                     options(*nopass: *omit)
     D SMTP            DS                  likeds(SMTP_t)
     D                                     based(p_SMTP)
     D myServer        s            256A   varying
     D myPort          s                   like(port)
     D addr            s                   like(SMTP_t.addr)
     D servlen         s             10I 0
     D savserv         s            256A   based(p_savserv)

     D from            ds                  likeds(QtqCode_t)
     D to              ds                  likeds(QtqCode_t)
     D to_ascii        ds                  likeds(iconv_t)
     D to_ebcdic       ds                  likeds(iconv_t)

      /free
          e2a_ptr = %paddr(e2a_real);
          init_signals();

          // -----------------------------------------
          // Set up ASCII->EBCDIC tables
          // -----------------------------------------
          from = *allx'00';
          to   = *allx'00';

          from.ccsid = 0;
            to.ccsid = 819;
          to_ascii = QtqIconvOpen(to: from);

          if (to_ascii.return_value = -1);
             SetError( SMTP_ERR_TOASC
                     : 'Unable to create EBCDIC to ASCII translator');
             return *NULL;
          endif;

          from.ccsid = 819;
            to.ccsid = 0;
          to_ebcdic = QtqIconvOpen(to: from);

          if (to_ebcdic.return_value = -1);
             SetError( SMTP_ERR_TOEBC
                     : 'Unable to create ASCII to EBCDIC translator');
             return *NULL;
          endif;

          // -----------------------------------------
          // Get the port number, if needed
          // -----------------------------------------

          if ( %parms>=2 and %addr(port)<>*NULL and port>0 );
             myPort = port;
          else;
             myPort = get_port();
          endif;

          // -----------------------------------------
          // Look up the IP address for the server:
          // -----------------------------------------

          if ( %parms<1 or %addr(server)=*NULL );

              addr   = INADDR_LOOPBACK;
              myServer = 'localhost';

          else;

             alarm(180);

             myServer = %trim(server);
             addr = inet_addr(myServer);
             if (addr = INADDR_NONE);
                 p_hostent = gethostbyname(myServer);
                 if (p_hostent = *NULL);
                       SetError(SMTP_ERR_NOTFOUND
                       : 'Unable to find IP address for server.');
                     alarm(0);
                     return *NULL;
                 endif;
                 addr = h_addr;
             endif;

             alarm(0);

          endif;

          // -----------------------------------------
          // Create a new SMTP handle w/default values:
          // -----------------------------------------

          p_SMTP = %alloc(%size(SMTP_t));
          SMTP = SMTP_t;

          // -----------------------------------------
          // Store server & port in handle:
          // -----------------------------------------

          servlen = %len(myServer) + 1;
          SMTP.server = %alloc(servlen);
          p_savserv = SMTP.server;
          %subst(savserv:1:servlen) = myServer + x'00';

          SMTP.port      = myPort;
          SMTP.addr      = addr;
          SMTP.to_ascii  = to_ascii;
          SMTP.to_ebcdic = to_ebcdic;

          return p_SMTP;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_connect():  Connect to SMTP server
      *
      *     p_SMTP = (input) SMTP handle returned from SMTP_new()
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_connect    B                   export
     D SMTP_connect    PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value

     D SMTP            DS                  likeds(SMTP_t)
     D                                     based(p_SMTP)
     D sa              ds                  likeds(sockaddr_in)
     D s               s             10I 0
      /free
          // -----------------------------------------
          //   Create new socket
          // -----------------------------------------

          s = socket(AF_INET: SOCK_STREAM: IPPROTO_IP);
          if (s = -1);
             SetUnixError( SMTP_ERR_SOCKET : 'socket()'  );
             return *OFF;
          endif;

          // -----------------------------------------
          //   Connect to SMTP server
          // -----------------------------------------

          sa = *allx'00';
          sa.sin_family = AF_INET;
          sa.sin_addr   = SMTP.addr;
          sa.sin_port   = SMTP.port;

          alarm(SMTP.timeout);

          if (connect(s: %addr(sa): %size(sa)) = -1);
             SetUnixError( SMTP_ERR_CONNECT : 'connect()' );
             return *OFF;
          endif;

          alarm(0);

          DebugMsg('Connection to ' + %str(SMTP.server) + ' established');

          SMTP.sock = s;

          // -----------------------------------------
          //   Handshake w/server
          // -----------------------------------------

          if (SMTP_hshake(p_SMTP) = *OFF);
             callp close(SMTP.sock);
             SMTP.sock = -1;
             return *OFF;
          endif;

          return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * get_port(): Get the SMTP port for this system.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P get_port        B
     D get_port        PI            10I 0
     D se              ds                  likeds(servent) based(p)
      /free
         p = getservbyname('smtp': 'tcp');
         if (p = *NULL);
            return 25;
         else;
            return se.s_port;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_hshake(): Get server greeting and send HELO command
      *                to identify us to the server
      *
      *    p_SMTP = (input) SMTP handle
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_hshake     B                   export
     D SMTP_hshake     PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value

     D gethostname     PR            10I 0 extproc('gethostname')
     D   name                     32767A   options(*varsize)
     D   length                      10I 0 value

     D hostbuf         s            256A
     D host            s            256A   varying

     D msg             s            300A   varying
     D rc              s             10I 0

      /free

          // -----------------------------------------
          //   What's our local domain name?
          // -----------------------------------------

          if ( gethostname(hostbuf: %size(hostbuf)) = 0);
              host = %str(%addr(hostbuf));
          else;
              host = 'unknown';
          endif;

          // -----------------------------------------
          //   Server starts w/220 greeting
          // -----------------------------------------

          rc = response(p_SMTP);
          if (rc = -1);
              return *OFF;
          endif;

          if (rc <> 220);
             SetError(SMTP_ERR_INVREPLY
                     : 'Invalid reply code during greeting.');
             return *OFF;
          endif;


          // -----------------------------------------
          //  Send HELO command
          // -----------------------------------------

          msg = 'HELO ' + host + CRLF;
          if ( sendtext(p_SMTP: msg) = *OFF );
             return *OFF;
          endif;

          rc = response(p_SMTP);
          if (rc = -1);
             return *OFF;
          endif;

          if (rc <> 250);
             SetError(SMTP_ERR_INVREPLY
                     : 'Invalid reply code to HELO command.');
             return *OFF;
          endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_auth: Perform authentication login
      *
      *    p_SMTP = (input) SMTP handle
      *    autusr = (input) authenicated username in plain text
      *    autpwd = (input) authenicated password in plain text
      *
      *    Refer to Micorsoft Spec.: https://msdn.microsoft.com/library/cc433484(v=exchg.80).aspx
      *    [MS-XLOGIN]: Simple Mail Transfer Protocol (SMTP) AUTH LOGIN Extension
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_auth       B                   export
     D SMTP_auth       PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   autusr                     256A   varying
     D   autpwd                     256A   varying

     D b64autusr       s            256A   varying
     D b64autpwd       s            256A   varying
     D v64autusr       s            256A   varying
     D v64autpwd       s            256A   varying
     D b64autusrlen    s             10I 0
     D b64autpwdlen    s             10I 0
     D msg             s            300A   varying
     D rc              s             10I 0

     D autusrbuf       s            256a
     D autusrlen       s             10u 0
     D autpwdbuf       s            256a
     D autpwdlen       s             10u 0

     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toASCII         ds                  likeds(iconv_t)

     D p_input         s               *
     D p_output        s               *
     D inputleft       s             10u 0
     D outputleft      s             10u 0

      /free
         msg = 'AUTH LOGIN' + CRLF;
         if ( sendtext(p_SMTP: msg) = *OFF );
            return *OFF;
         endif;

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 334);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to AUTH LOGIN command.');
            return *OFF;
         endif;

         // -----------------------------------------
         //   sent authenicated user name in base64 format
         //   sample coding may refer to:
         //     https://www.ibm.com/developerworks/community/forums/html
         //     /topic?id=082ed87d-3407-4ee8-bb2c-5d5556a9a14d
         // -----------------------------------------

         // -----------------------------------------------
         //   find the appropriate translation 'table'
         //   for converting the job's CCSID to ISO 8859-1 ASCII
         //
         //  Note: 0 is a special value that means
         //        "job CCSID".  Better to use that than
         //        to hard-code 37.
         // -----------------------------------------------

         source = *allx'00';
         target = *allx'00';

         source.CCSID = 0;        //    0 = current job's CCSID
         target.CCSID = 819;      //  819 = ISO 8859-1 ASCII
         toASCII = QtqIconvOpen( target: source );

         if (toASCII.return_value = -1);
             SetError( SMTP_ERR_TOASC
                     : 'Unable to create EBCDIC to ASCII translator');
         endif;

         // -----------------------------------------------
         //   Translate data for authenticated user
         //
         //   the iconv() API will increment/decrement
         //   the pointers and lengths, so make sure you
         //   do not use the original pointers...
         // -----------------------------------------------

         p_input  = %addr(autusr) + 2;
         inputleft = %len(autusr);

         p_output = %addr(autusrbuf);
         outputleft = %size(autusrbuf);

         iconv( toASCII
              : p_input
              : inputleft
              : p_output
              : outputleft );

        // -----------------------------------------------
        //  if needed, you can calculate the length of
        //  the decoded data by subtracting the amount
        //  of space left in the buffer from the total
        //  buffer size.
        //
        //  At this point, 'autusrbuf' should contain
        //  the EBCDIC data.
        // -----------------------------------------------

         autusrlen = %size(autusrbuf) - outputleft;

         // -----------------------------------------------
         //   Translate data for authenticated password
         // -----------------------------------------------

         p_input  = %addr(autpwd) + 2;
         inputleft = %len(autpwd);

         p_output = %addr(autpwdbuf);
         outputleft = %size(autpwdbuf);

         iconv( toASCII
              : p_input
              : inputleft
              : p_output
              : outputleft );

         autpwdlen = %size(autpwdbuf) - outputleft;

         // -----------------------------------------------
         //  you can call iconv() many more times if you
         //  want, using the same 'toASCII' table for
         //  translation.
         //   - -
         //  when you are completely done, call iconv_close()
         //  to free up memory.
         // -----------------------------------------------

         iconv_close(toASCII);

         // -----------------------------------------------
         //   encode authenicated user, password from ascii into base64
         // -----------------------------------------------

         b64autusrlen = base64_encode( %addr(autusrbuf)
                                    : autusrlen
                                    : %addr(b64autusr)
                                    : %size(b64autusr) );

         b64autpwdlen = base64_encode( %addr(autpwdbuf)
                                    : autpwdlen
                                    : %addr(b64autpwd)
                                    : %size(b64autpwd) );

         // -----------------------------------------------
         //   sent authenicated user in base64 format
         // -----------------------------------------------

         b64autusr = b64autusr + CRLF;
         if ( sendtext(p_SMTP: b64autusr) = *OFF );
            return *OFF;
         endif;

         // -----------------------------------------
         //  Server should respond with 334.
         // -----------------------------------------

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 334);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to sent auth. user.');
            return *OFF;
         endif;

         // -----------------------------------------
         //   sent authenicated password in base64 format
         // -----------------------------------------

         b64autpwd = b64autpwd + CRLF;
         if ( sendtext(p_SMTP: b64autpwd) = *OFF );
            return *OFF;
         endif;

         // -----------------------------------------
         //  Server should respond with 235.
         //  235 means Authentication successful
         // -----------------------------------------

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 235);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to sent auth. password');
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_from: Start a new e-mail message and identify who
      *            the message is from (in the envelope)
      *
      *    p_SMTP = (input) SMTP handle
      *      from = (input) e-mail address (only) of sender
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_from       B                   export
     D SMTP_from       PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   from                       256A   const varying

     D msg             s            300A   varying
     D rc              s             10I 0
      /free
         msg = 'MAIL FROM:<' + from + '>' + CRLF;
         if ( sendtext(p_SMTP: msg) = *OFF );
            return *OFF;
         endif;

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 250);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to MAIL command.');
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_recip: Specify a msg recipient (in the envelope)
      *             you can call this more than once to indicate
      *             multiple recipients.
      *
      *    p_SMTP = (input) SMTP handle
      *        to = (input) e-mail address (only) of recipient
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_recip      B                   export
     D SMTP_recip      PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   to                         256A   const varying

     D msg             s            300A   varying
     D rc              s             10I 0
      /free
         msg = 'RCPT TO:<' + to + '>' + CRLF;
         if ( sendtext(p_SMTP: msg) = *OFF );
            return *OFF;
         endif;

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 250);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to RCPT command.');
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data: Send E-mail message to SMTP server
      *
      *    p_SMTP = (input) SMTP handle
      *  callback = (input) callback routine to retrieve the next
      *                     line of the e-mail message in EBCDIC.
      *    usrdta = (input) user data required by callback routine
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_data       B                   export
     D SMTP_data       PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   callback                      *   procptr value
     D   usrdta                        *   value

     D do_callback     PR             1N   extproc(callback)
     D    usrdta                       *   value
     D    line                    32767A   varying

     D line            s          32767A   varying
     D msg             s            300A   varying
     D rc              s             10I 0
     D savelogging     s              1N
      /free
         // -----------------------------------------
         //  Notify server that e-mail data is coming
         // -----------------------------------------

         msg = 'DATA' + CRLF;
         if ( sendtext(p_SMTP: msg) = *OFF );
            return *OFF;
         endif;

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 354);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to RCPT command.');
            return *OFF;
         endif;

         // -----------------------------------------
         //  Send the E-mail data
         // -----------------------------------------

         dow do_callback(usrdta: line);
            if (%len(line)>0 and %subst(line:1:1) = '.');
               savelogging = logging;
               Logging=*OFF;
               sendtext(p_SMTP: '.');
               Logging=savelogging;
            endif;
            if ( sendtext(p_SMTP: line) = *OFF );
               return *OFF;
            endif;
         enddo;

         // -----------------------------------------
         //   a period on a line by itself ends
         //   the message.
         // -----------------------------------------
         if ( sendtext(p_SMTP: '.' + CRLF) = *OFF );
            return *OFF;
         endif;

         // -----------------------------------------
         //  Server should respond with 250.
         // -----------------------------------------

         rc = response(p_SMTP);
         if (rc = -1);
            return *OFF;
         endif;

         if (rc <> 250);
            SetError(SMTP_ERR_INVREPLY
                    : 'Invalid reply code to DATA command.');
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_stmf(): Send E-mail message to SMTP server
      *                   from an IFS stream file
      *
      *    p_SMTP = (input) SMTP handle
      *      stmf = (input) Stream file to send
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_data_stmf  B                   export
     D SMTP_data_stmf  PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   stmf                     32767A   varying const options(*varsize)

     D fd              s                   like(pFILE)
      /free

          // ----------------------------------------
          //  Open file containing e-mail message
          // ----------------------------------------

          fd = fopen( %trim(stmf) : 'r,crln=N' );
          if (fd = *NULL);
             SetUnixError(SMTP_ERR_STMF: 'fopen()' );
             return *OFF;
          endif;

          // ----------------------------------------
          //  Send file to server
          // ----------------------------------------

          if ( SMTP_data( p_SMTP
                        : %paddr(copy_stmf)
                        : %addr(fd) ) = *OFF );
             callp fclose(fd);
             return *OFF;
          endif;

          callp fclose(fd);
          return *ON;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This is used by SMTP_data_stmf() to copy data from the
      * stream file to the SMTP server
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P copy_stmf       B
     D copy_stmf       PI             1N
     D   hfile                             like(pFILE)
     D   buf                      32767A   varying
      /free
          %len(buf) = %size(buf)-2;
          if ( fgets(%addr(buf)+2: %len(buf): hfile) = *NULL );
             return *OFF;
          endif;
          %len(buf) = %scan(x'00': buf) - 1;
          return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_ptr(): Send E-mail message to SMTP server
      *                  from an arbitrary location in memory
      *
      *    p_SMTP = (input) SMTP handle
      *       ptr = (input) Location of data to send
      *      size = (input) size of message to send.
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_data_ptr   B                   export
     D SMTP_data_ptr   PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   ptr                           *   value
     D   size                        10U 0 value

     D dta             ds                  likeds(memcpy_t)
      /free
          dta.loc  = ptr;
          dta.left = size;

          if ( SMTP_data( p_SMTP
                        : %paddr(copy_mem)
                        : %addr(dta) ) = *OFF );
             return *OFF;
          endif;

          return *ON;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This is used by SMTP_data_ptr() to copy data from a space
      * in the system's memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P copy_mem        B
     D copy_mem        PI             1N
     D   dta                               likeds(memcpy_t)
     D   buf                      32767A   varying

     D memchr          pr              *   extproc(*CWIDEN:'memchr')
     D   space                         *   value
     D   char                         1A   value
     D   size                        10U 0 value

     D pos             s               *
     D line            s          32767A   based(dta.loc)
     D len             s             10U 0
      /free

         if (dta.left = 0);
            return *OFF;
         endif;

         pos = memchr(dta.loc: x'25': dta.left);
         if (pos = *NULL);
            pos = dta.loc;
            buf = %subst(line:1:dta.left) + CRLF;
            dta.left = 0;
            return *ON;
         endif;

         len = (pos - dta.loc) + 1;
         if (len > %size(line));
             len = %size(line);
         endif;

         buf = %subst(line:1:len);

         dta.left = dta.left - len;
         if (dta.left > 0);
            dta.loc = dta.loc + len;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_var(): Send E-mail message to SMTP server
      *                  from a variable
      *
      *    p_SMTP = (input) SMTP handle
      *       var = (input) message body to send
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_data_var   B                   export
     D SMTP_data_var   PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   var                      32767A   varying options(*varsize)
      /free
        return SMTP_data_ptr(p_SMTP:%addr(var)+2:%len(var));
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_ary(): Send E-mail message to SMTP server
      *                  from an array
      *
      *    p_SMTP = (input) SMTP handle
      *       ary = (input) message body to send
      *      size = (input) number of elements in array.
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_data_ary   B                   export
     D SMTP_data_ary   PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   ary                         78A   dim(32767) options(*varsize)
     D   size                        10I 0 value

     D data            ds                  likeds(arycpy_t)
      /free
          data.base = %addr(ary);
          data.size = size;
          data.cur  = 0;

          if ( SMTP_data( p_SMTP
                        : %paddr(copy_array)
                        : %addr(data) ) = *OFF );
             return *OFF;
          endif;

          return *ON;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This is used by SMTP_data_ptr() to copy data from a space
      * in the system's memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P copy_array      B
     D copy_array      PI             1N
     D   data                              likeds(arycpy_t)
     D   buf                      32767A   varying

     D array           s             78A   dim(32767)
     D                                     based(data.base)
      /free

         data.cur = data.cur + 1;
         if (data.cur > data.size);
            return *OFF;
         else;
            buf = %trimr(array(data.cur)) + CRLF;
            return *ON;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_quit: Disconnect from SMTP server
      *
      *    p_SMTP = (input) SMTP handle
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_quit       B                   export
     D SMTP_quit       PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value

     D SMTP            ds                  likeds(SMTP_t)
     D                                     based(p_SMTP)

     D msg             s            300A   varying
     D savetime        s             10I 0
      /free

         // set the timeout to a low value.
         // we don't particularly care if the server responds nicely.

         savetime = SMTP.timeout;
         SMTP.timeout = 2;

         msg = 'QUIT' + CRLF;
         sendtext(p_SMTP: msg);
         response(p_SMTP);

         callp close(SMTP.sock);
         SMTP.sock = -1;
         SMTP.timeout = savetime;

         return *ON;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_free():  Return memory used by SMTP handle to system
      *
      *    p_SMTP = (input) SMTP handle to free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_free       B                   export
     D SMTP_free       PI
     D   p_SMTP                            like(SMTP_HANDLE) value
     D SMTP            DS                  likeds(SMTP_t)
     D                                     based(p_SMTP)
      /free
          if (p_SMTP <> *NULL);

             if (SMTP.sock <> -1);
                SMTP_quit(p_SMTP);
             endif;

             iconv_close(SMTP.to_ascii);
             iconv_close(SMTP.to_ebcdic);

             if (SMTP.server <> *NULL);
                dealloc SMTP.server;
                SMTP.server = *NULL;
             endif;

             dealloc p_SMTP;
             SMTP.server = *NULL;
          endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_SetServer(): Set the SMTP server used by SMTP_SendMail
      *
      *   Note: This is only used by SMTP_SendMail(). Then other
      *         procedures in this srvpgm use the server name
      *         you pass to SMTP_new()
      *
      *    ServName = (input) SMTP server name to use
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_SetServer  B                   export
     D SMTP_SetServer  PI
     D   ServName                   256A   const
     D  ServBuf        s                   like(SmtpServer) static
      /free
         ServBuf = %trim(ServName);
         if (%len(ServName)=0 or ServName='localhost');
            p_SmtpServer = *NULL;
         else;
            ServBuf = %trim(ServName);
            p_SmtpServer = %addr(ServBuf);
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_SendMail(): This is intended to be a "drop in
      *                  replacement" for the QtmmSendMail() API.
      *
      *    FileName = (input) Name of stream file containing msg
      * FileNameLen = (input) Length of Filename (above)
      *    FromAddr = (input) E-mail address that mail is from
      *     FromLen = (input) Length of FromAddr (above)
      *  RecipAddrs = (input) E-mail recipient addresses
      *  RecipCount = (input) number of recipients (above)
      *   ErrorCode = (i/o) standard API error code structure
      *    AuthUser = (input) Authenicated username in plain text
      *    AuthPass = (input) Authenicated password in plain text
      *
      * Note: Like QtmmSendMail(), this API takes care of deleting
      *       the stream file when it's complete.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_SendMail   B                   export
     D SMTP_SendMail   PI
     D   FileName                 32767A   const options(*varsize)
     D   FileNameLen                 10I 0 const
     D   FromAddr                 32767A   const options(*varsize)
     D   FromLen                     10I 0 const
     D   RecipAddrs               32767A   options(*varsize)
     D   RecipCount                  10I 0 const
     D   ErrorCode                32767A   options(*varsize)
     D   AuthUser                   256A   varying
     D   AuthPass                   256A   varying

     D unlink          pr            10I 0 extproc('unlink')
     D   filename                      *   value options(*string)

     D ADDT0100        DS                  based(p_Recip)
     D                                     qualified
     D   Next                        10I 0
     D   Len                         10I 0
     D   Format                       8A
     D   Type                        10I 0
     D   Resv                        10I 0
     D   Address                    256A

     D fail            ds                  qualified
     D                                     based(p_Fail)
     D   BytesProv                   10I 0
     D   BytesAvail                  10I 0
     D   MsgId                        7A
     D                                1A
     D   MsgDta                   32751A

     D hsmtp           s                   like(SMTP_HANDLE)
     D len             s             10I 0
     D Msglen          s             10I 0
     D MsgKey          s              4A
     D r               s             10I 0

      /free
          // ----------------------------------------
          //  Reset "bytes provided" field in error
          //  data structure.
          // ----------------------------------------
          p_Fail = %addr(ErrorCode);
          if (Fail.BytesProv >= 8);
             Fail.BytesAvail = 0;
          endif;


          // ----------------------------------------
          //  Connect to SMTP server
          // ----------------------------------------

          hsmtp = SMTP_new(SmtpServer : *omit);
          if (hsmtp = *NULL);
             exsr Failure;
          endif;

          if ( SMTP_connect( hsmtp ) = *OFF );
             exsr Failure;
          endif;


          // ----------------------------------------
          //  Tell Authenticate user and password for SMTP server
          // ----------------------------------------

          if ( SMTP_auth( hsmtp : AuthUser : AuthPass ) = *OFF );
             exsr Failure;
          endif;


          // ----------------------------------------
          //   Tell who the message is from
          // ----------------------------------------

          if ( SMTP_from( hsmtp : %subst(FromAddr:1:FromLen) ) = *OFF );
             exsr Failure;
          endif;


          // ----------------------------------------
          //   List the recipients
          // ----------------------------------------

          p_recip = %addr(RecipAddrs);
          for r = 1 to RecipCount;

              if (ADDT0100.Format <> 'ADDT0100'
                  and ADDT0100.Format <> 'ADDR0100');
                  SetError( SMTP_ERR_FORMAT
                          : 'ADDT0100 is the only supported format.' );
                  exsr Failure;
              endif;

              len = ADDT0100.Len;
              if (Len<1 or Len>256);
                  SetError( SMTP_ERR_FORMAT
                          : 'Recip addr must be 1-256 chars long.' );
                  exsr Failure;
              endif;

              if ( SMTP_recip( hsmtp
                             : %subst(ADDT0100.Address:1:Len)) = *OFF);
                  exsr Failure;
              endif;

              if (r = RecipCount);
                 p_recip = *NULL;
              else;
                 p_recip = p_recip + ADDT0100.Next;
              endif;

          endfor;


          // ----------------------------------------
          //   Send the messsage body
          // ----------------------------------------

          if ( SMTP_data_stmf( hsmtp : %subst(FileName:1:FileNameLen) )
              =  *OFF );
             exsr Failure;
          endif;

          SMTP_free( hsmtp );
          if ( unlink( %subst(FileName:1:FileNameLen)) = -1 );
             SetUnixError( SMTP_ERR_UNLINK : 'unlink()' );
             exsr Failure;
          endif;

          return;

          // ----------------------------------------
          //   If a failure occurs, set the QUSEC
          //   style return structure (yuck!)
          // ----------------------------------------

          begsr Failure;
              SMTP_free( hsmtp );
              MsgLen = %len(%trimr(ErrorMsg));

              if (Fail.BytesProv<8 or Fail.BytesProv>%size(Fail));
                  QMHSNDPM( 'CPF9897'
                          : 'QCPFMSG   *LIBL'
                          : ErrorMsg
                          : MsgLen
                          : '*ESCAPE'
                          : '*PGMBDY'
                          : 1
                          : MsgKey
                          : NullError );
              endif;

              Fail.BytesAvail = 16 + MsgLen;
              if (Fail.BytesAvail > Fail.BytesProv);
                  Fail.BytesAvail = Fail.BytesProv;
                  MsgLen = Fail.BytesProv - 16;
              endif;

              if ( Fail.BytesProv >= 15 );
                  Fail.MsgId = 'CPF9897';
              endif;

              if ( MsgLen > 4 );
                  %subsT(Fail.MsgDta:1:4) = ErrorNoChar;
                  MsgLen = MsgLen - 4;
              endif;

              if ( MsgLen > 0 );
                  %subst(Fail.MsgDta:5:MsgLen) = ErrorMsg;
              endif;

              return;
          endsr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_Error(): Get last error message from this
      *               service program
      *
      *     errnum = (output/optional) 4-digit error number
      *               corresponding to an SMTP_ERR_XXXX constant
      *
      * Returns the human-readable error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_error      B                   export
     D SMTP_error      PI            80A
     D   errnum                       4S 0 options(*nopass:*omit)
      /free
         if %parms>=1 and %addr(errnum)<>*NULL;
             errnum = ErrorNo;
         endif;
         return ErrorMsg;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SetError():  Set an error number & message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetError        B
     D SetError        PI
     D   num                          4S 0 value
     D   text                        80A   const
      /free
         ErrorMsg = text;
         ErrorNo  = num;
         DebugMsg('ERROR: ' + %trimr(text));
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SetUnixError():  Set Unix API error number & message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetUnixError    B
     D SetUnixError    PI
     D   num                          4S 0 value
     D   api                         50A   varying const
     D EINTR           C                   3407
     D errno           s             10I 0 based(p_errno)
     D sys_errno       pr              *   extproc('__errno')
     D strerror        PR              *   ExtProc('strerror')
     D    errnum                     10I 0 value
      /free
         p_errno = sys_errno();
         if ( errno = EINTR );
            SetError(num: api+': Timed out!');
         else;
            SetError(num: api+': '+%str(strerror(errno)));
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SendText(): Convert text from EBCDIC to ASCII and send
      *             it to SMTP socket.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SendText        B
     D SendText        PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   text                     32767A   varying const options(*varsize)

     D SMTP            ds                  likeds(SMTP_t)
     D                                     based(p_SMTP)
     D buf             s          32767A
     D len             s             10I 0
     D slen            s             10I 0
      /free
          DebugMsg(text);
          len = e2a(SMTP: text: buf: %size(buf));
          alarm(SMTP.timeout);
          slen = send(SMTP.sock: %addr(buf): len: 0);
          alarm(0);
          if (slen < len);
             SetUnixError( SMTP_ERR_SEND: 'send()' );
             return *OFF;
          endif;
          return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * RecvText(): Receive 1 line of text, and convert it from
      *             ASCII to EBCDIC
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P RecvText        B
     D RecvText        PI             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   text                     32767A   varying

     D SMTP            ds                  likeds(SMTP_t)
     D                                     based(p_SMTP)

     D ch              s              1A
     D len             s             10I 0

      /free
         %len(text) = 0;

         alarmed = *OFF;
         alarm(SMTP.timeout);

         dou ( ch = x'0a' or alarmed = *on );
             len = recv( SMTP.sock: %addr(ch): %size(ch): 0);
             if (len < 1);
                leave;
             endif;
             text = text + ch;
         enddo;
         alarm(0);

         if %len(text) > 0;
            a2e(SMTP:text);
            DebugMsg(text);
            return *ON;
         else;
            SetUnixError( SMTP_ERR_RECV : 'recv()' );
            return *OFF;
         endif;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Response(): Get SMTP response code from server
      *
      *  Returns the response code or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Response        B
     D Response        PI            10I 0
     D   p_SMTP                            like(SMTP_HANDLE) value

     D atoi            PR            10I 0 extproc('atoi')
     D   input                         *   value options(*string)

     D looping         s              1N   inz(*OFF)
     D buf             s          32767A   varying
     D retval          s             10I 0
     D resp            s              3A

      /free
          // The first 3 bytes of an SMTP response must be
          // a 3-digit response number.
          // The 4th byte can be a blank or a dash.

          // If it's a dash, the response is multi-line and
          // continues until the same 3 digit response is
          // received without a dash.

          // Single line example:
          //    250 Successful.

          // Silly multi-line example:
          //    250-Good Job. You are so clever that you will
          //        be put in the hall of fame for wonderful
          //        people, and recognized all over the world.
          //    250 Please dial 555-1212 for further instructions.

          if (recvtext( p_SMTP: buf ) = *OFF);
             return -1;
          endif;

          if (%len(buf) < 4);
             return -1;
          endif;

          resp = %subst(buf:1:3);
          retval = atoi(resp);
          if (%subst(buf:4:1) = '-');
              looping = *ON;
          endif;

          dow (looping);
             if (recvtext(p_SMTP: buf) = *OFF);
                return -1;
             endif;
             if (%len(buf)>=4
                   and %subst(buf:1:3) = resp
                   and %subst(buf:4:1) <> '-' );
                looping = *OFF;
             endif;
          enddo;

          return retval;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * e2a(): Translate from EBCDIC to ASCII
      *        any untranslatable characters are copied as-is
      *
      *       input = (input)  EBCDIC text to be converted
      *      output = (output) pointer to output buffer
      *  outputsize = (input)  size of output buffer
      *
      * returns the length of the translated data in the output buf
      *
      * Note: e2a is an alternate prototype for e2a_real.  The
      *       alternate prototype is needed to dereference a CONST
      *       field.  Technically, it "tricks" the compiler.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P e2a_real        B
     D e2a_real        PI            10U 0
     D   SMTP                              likeds(SMTP_t)
     D   input                    32767A   varying
     D   output                        *   value
     D   outputsize                  10U 0 value

     D p_input         s               *
     D inchar          s              1A   based(p_input)
     D inputleft       s             10U 0
     D outputleft      s             10U 0
     D outchar         s              1A   based(p_output)
      /free
          p_input    = %addr(input) + 2;
          inputleft  = %len(input);
          outputleft = outputsize;

          dow (inputleft>0 and outputleft>0);

             iconv( SMTP.to_ascii
                  : p_input
                  : inputleft
                  : output
                  : outputleft );

             if (inputleft > 0);
                outchar = inchar;
                p_input = p_input + 1;
                inputleft = inputleft - 1;
             endif;

          enddo;

          return (outputsize - outputleft);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * a2e(): convert ASCII data to EBCDIC
      *        any untranslatable chars are copied as-is
      *        Ahh, the hoops we jump through...
      *
      *        input = (i/o) data to convert
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P a2e             B
     D a2e             PI
     D   SMTP                              likeds(SMTP_t)
     D   input                    32767A   varying

     D p_input         s               *
     D inchar          s              1A   based(p_input)
     D inputleft       s             10U 0
     D output          s          32767A   varying
     D p_output        s               *
     D outputleft      s             10U 0
     D outchar         s              1A   based(p_output)

      /free

          p_input      = %addr(input) + 2;
          inputleft    = %len(input);
          %len(output) = %size(output) - 2;
          p_output     = %addr(output) + 2;
          outputleft   = %len(output);

          dow (inputleft>0 and outputleft>0);

             iconv( SMTP.to_ebcdic
                  : p_input
                  : inputleft
                  : p_output
                  : outputleft );

             if (inputleft > 0);
                outchar = inchar;
                p_input = p_input + 1;
                inputleft = inputleft - 1;
             endif;

          enddo;

          %len(output) = %len(output) - outputleft;
          Input = Output;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Write a debugging message to the job log
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P DebugMsg        B
     D DebugMsg        PI
     D   msg                      32702A   varying options(*varsize) const
     D MsgKey          s              4A
     D len             s             10I 0
      /free
          if (not Logging);
             return;
          endif;

          len = %len(msg);
          if (len>1 and %subst(msg:len-1:2) = CRLF);
             len = len - 2;
          endif;

          QMHSNDPM( 'CPF9897'
                  : 'QCPFMSG   *LIBL'
                  : msg
                  : len
                  : '*DIAG'
                  : '*PGMBDY'
                  : 0
                  : MsgKey
                  : NullError );
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_getTime(): Formats a date/time according to the
      *                 SMTP standard.
      *
      *   inpTS = (input/optional) if provided, this is the date
      *                 that will be converted to SMTP formatting
      *                 if not given, the date will be taken from
      *                 the system clock.
      *
      *     For example:  'Mon, 15 Aug 2006 14:30:06 -0500'
      *
      *  returns the date/time string.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_getTime    B                   export
     D SMTP_getTime    PI            31A
     D   inpTS                         Z   const options(*nopass:*omit)

     D CEEUTCO         PR                  opdesc
     D   Hours                       10I 0
     D   Minutes                     10I 0
     D   Seconds                      8F
     D   fc                          12A   options(*omit)

     D SUNDAY          C                   d'1899-12-31'

     D junk1           s              8F
     D hours           s             10I 0
     D mins            s             10I 0
     D tz_hours        s              2P 0
     D tz_mins         s              2P 0
     D tz              s              5A   varying

     D CurTS           s               Z   inz(*sys)
     D CurTime         s              8a   varying
     D CurDay          s              2p 0
     D CurYear         s              4p 0
     D CurMM           s              2p 0
     D CurMonth        s              3a   varying
     D TempDOW         s             10i 0
     D CurDOW          s              3a   varying

     D DateString      s             31a

      /free
         if (%parms>=1 and %addr(inpTS)<>*null);
            CurTS = inpTS;
         endif;

         //
         //  Calculate the Timezone in format '+0000', for example
         //    CST should show up as '-0600'
         //

         CEEUTCO(hours: mins: junk1: *omit);
         tz_hours = %abs(hours);
         tz_mins = mins;

         if (hours < 0);
            tz = '-';
         else;
            tz = '+';
         endif;

         tz += %editc(tz_hours:'X') + %editc(tz_mins:'X');

         //
         //  Get the current time and convert it to the format
         //    specified for e-mail in RFC 2822
         //

         CurTime = %char(%time(CurTS): *HMS:);

         CurDay  = %subdt(CurTS: *DAYS);
         CurYear = %subdt(CurTS: *YEARS);
         CurMM   = %subdt(CurTS: *MONTHS);

         select;
         when CurMM = 1;
           CurMonth = 'Jan';
         when CurMM = 2;
           CurMonth = 'Feb';
         when CurMM = 3;
           CurMonth = 'Mar';
         when CurMM = 4;
           CurMonth = 'Apr';
         when CurMM = 5;
           CurMonth = 'May';
         when CurMM = 6;
           CurMonth = 'Jun';
         when CurMM = 7;
           CurMonth = 'Jul';
         when CurMM = 8;
           CurMonth = 'Aug';
         when CurMM = 9;
           CurMonth = 'Sep';
         when CurMM = 10;
           CurMonth = 'Oct';
         when CurMM = 11;
           CurMonth = 'Nov';
         when CurMM = 12;
           CurMonth = 'Dec';
         endsl;

         TempDOW = %diff( %date(CurTS) : SUNDAY : *DAYS );
         TempDOW = %rem( TempDOW : 7 );

         Select;
         when TempDOW = 0;
           CurDOW = 'Sun';
         when TempDOW = 1;
           CurDOW = 'Mon';
         when TempDOW = 2;
           CurDOW = 'Tue';
         when TempDOW = 3;
           CurDOW = 'Wed';
         when TempDOW = 4;
           CurDOW = 'Thu';
         when TempDOW = 5;
           CurDOW = 'Fri';
         when TempDOW = 6;
           CurDOW = 'Sat';
         endsl;

         DateString = CurDOW + ', '
                    + %editc( CurDay: 'X' ) + ' '
                    + CurMonth + ' '
                    + %editc( CurYear: 'X' ) + ' '
                    + CurTime + ' '
                    + tz;

         return DateString;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * init_signals():  Enable signal handling/catching.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P init_signals    B
     D init_signals    PI
     D act             ds                  likeds(sigaction_t)
     D done            s              1N   static inz(*OFF)
      /free
         if (not done);
            act.sa_flags = 0;
            act.sa_sigaction = *NULL;
            act.sa_handler = %paddr(caught_alarm);
            sigfillset(act.sa_mask);
            sigaction(SIGALRM: act: *omit);
            done = *ON;
            alarmed = *OFF;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * caught_alarm(): This is run (by the operating system)
      * each time an alarm signal (SIGALRM) is send to the program
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P caught_alarm    B
     D caught_alarm    PI
     D   signo                       10I 0 value
      /free
         Alarmed = *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_crash(): Crash with error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_crash      B                   export
     D SMTP_crash      PI

     D wwKey           s              4a
     D wwMsg           s             80a
      /free
          wwMsg = SMTP_error();
          QMHSNDPM( 'CPF9897'
                  : 'QCPFMSG   *LIBL'
                  : wwMsg
                  : %len(wwMsg)
                  : '*ESCAPE'
                  : '*PGMBDY'
                  : 1
                  : wwKey
                  : NullError );
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_extract(): Extract address from sender/recip string
      *                 if no < or > found, source is assumed to
      *                 already be a valid e-mail address and is
      *                 returned as-is.
      *
      *    peString = (input) recip string to extract from
      *
      * returns e-mail address.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SMTP_extract    B                   export
     D SMTP_extract    PI           256a   varying
     D   peRecip                    256a   varying const options(*varsize)
     D myRecip         s            256a   varying
     D x               s             10i 0
      /free
         x = %scan('<' : peRecip);
         if (x>0 and x<%len(peRecip));
            myRecip = %subst(peRecip:x+1);
            x = %scan('>': myRecip);
            if (x>2);
               myRecip = %subst(myRecip:1:x-1);
               return myRecip;
            endif;
         endif;
         return peRecip;
      /end-free
     P                 E
