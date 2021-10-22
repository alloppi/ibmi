      /if defined(SMTP_H_DEFINED)
      /eof
      /endif
      /define SMTP_H_DEFINED
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

     D SMTP_HANDLE     s               *   based(Template)

     D SMTP_ERR_TOASC...
     D                 C                   const(1001)
     D SMTP_ERR_TOEBC...
     D                 C                   const(1002)
     D SMTP_ERR_NOTFOUND...
     D                 C                   const(1003)
     D SMTP_ERR_SOCKET...
     D                 C                   const(1004)
     D SMTP_ERR_CONNECT...
     D                 C                   const(1005)
     D SMTP_ERR_INVREPLY...
     D                 C                   const(1006)
     D SMTP_ERR_STMF...
     D                 C                   const(1007)
     D SMTP_ERR_FORMAT...
     D                 C                   const(1008)
     D SMTP_ERR_LENGTH...
     D                 C                   const(1009)
     D SMTP_ERR_SEND...
     D                 C                   const(1010)
     D SMTP_ERR_RECV...
     D                 C                   const(1011)
     D SMTP_ERR_UNLINK...
     D                 C                   const(1012)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * The following definitions aim to make SMTPR4 a drop-in
      * replacement for QtmmSendMail
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      /if not defined(SENDMAIL_H)
     D ADDTO0100       ds                  qualified
     D                                     based(Template)
     D   NextOffset                  10I 0
     D   AddrLen                     10I 0
     D   AddrFormat                   8A
     D   DistType                    10I 0
     D   Reserved                    10I 0
     D   SmtpAddr                   256A

     D ADDR_NORMAL     C                   CONST(0)
     D ADDR_CC         C                   CONST(1)
     D ADDR_BCC        C                   CONST(2)

     D SMTPSendMail    PR                  Extproc('SMTP_SENDMAIL')
     D   FileName                   255A   const options(*varsize)
     D   FileNameLen                 10I 0 const
     D   MsgFrom                    256A   const options(*varsize)
     D   MsgFromLen                  10I 0 const
     D   RecipBuf                          likeds(ADDTO0100)
     D                                     dim(32767)
     D                                     options(*varsize)
     D   NumRecips                   10I 0 const
     D   ErrorCode                 8000A   options(*varsize)
      /endif

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
     D SMTP_new        PR                  like(SMTP_HANDLE)
     D   server                     256A   varying const
     D                                     options(*nopass: *omit)
     D   port                        10I 0 const
     D                                     options(*nopass: *omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_connect():  Connect to SMTP server
      *
      *     p_SMTP = (input) SMTP handle returned from SMTP_new()
      *
      * Returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_connect    PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_from: Start a new e-mail message and identify who
      *            the message is from (in the envelope)
      *
      *    p_SMTP = (input) SMTP handle
      *      from = (input) e-mail address (only) of sender
      *
      * returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_from       PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   from                       256A   const varying


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_recip: Specify a msg recipient (in the envelope)
      *             you can call this more than once to indicate
      *             multiple recipients.
      *
      *    p_SMTP = (input) SMTP handle
      *        to = (input) e-mail address (only) of recipient
      *
      * returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_recip      PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   to                         256A   const varying


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data: Send E-mail message to SMTP server
      *
      *    p_SMTP = (input) SMTP handle
      *  callback = (input) callback routine to retrieve the next
      *                     line of the e-mail message in EBCDIC.
      *    usrdta = (input) user data required by callback routine
      *
      * returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_data       PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   callback                      *   procptr value
     D   usrdta                        *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_stmf(): Send E-mail message to SMTP server
      *                   from an IFS stream file
      *
      *    p_SMTP = (input) SMTP handle
      *      stmf = (input) Stream file to send
      *
      * returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_data_stmf  PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   stmf                     32767A   varying const options(*varsize)


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
     D SMTP_data_ptr   PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   ptr                           *   value
     D   size                        10U 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_data_var(): Send E-mail message to SMTP server
      *                  from a variable
      *
      *    p_SMTP = (input) SMTP handle
      *       var = (input) message body to send
      *
      * returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_data_var   PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   var                      32767A   varying options(*varsize)


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
     D SMTP_data_ary   PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value
     D   ary                         78A   dim(32767) options(*varsize)
     D   size                        10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_quit: Disconnect from SMTP server
      *
      *    p_SMTP = (input) SMTP handle
      *
      * returns SUCCESS or FAIL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_quit       PR             1N
     D   p_SMTP                            like(SMTP_HANDLE) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_free():  Return memory used by SMTP handle to system
      *
      *    p_SMTP = (input) SMTP handle to free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_free       PR
     D   p_SMTP                            like(SMTP_HANDLE) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_SetServer(): Set the SMTP server used by SMTP_SendMail
      *
      *   Note: This is only used by SMTP_SendMail(). Then other
      *         procedures in this srvpgm use the server name
      *         you pass to SMTP_new()
      *
      *    ServName = (input) SMTP server name to use
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_SetServer  PR
     D   ServName                   256A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_SendMail(): This is intended to be a "drop in
      *                  replacement" for the QtmmSendMail() API.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_SendMail   PR
     D   FileName                 32767A   const options(*varsize)
     D   FileNameLen                 10I 0 const
     D   FromAddr                 32767A   const options(*varsize)
     D   FromLen                     10I 0 const
     D   RecipAddrs               32767A   options(*varsize)
     D   RecipCount                  10I 0 const
     D   ErrorCode                32767A   options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_Error(): Get last error message from this
      *               service program
      *
      *     errnum = (output/optional) 4-digit error number
      *               corresponding to an SMTP_ERR_XXXX constant
      *
      * Returns the human-readable error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_error      PR            80A
     D   errnum                       4S 0 options(*nopass:*omit)


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
     D SMTP_getTime    PR            31A
     D   inpTS                         Z   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SMTP_crash(): Crash with error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SMTP_crash      PR


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
     D SMTP_extract    PR           256a   varying
     D   peRecip                    256a   varying const options(*varsize)
