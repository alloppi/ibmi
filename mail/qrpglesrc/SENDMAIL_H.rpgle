     /*-                                                                            +
      * Copyright (c) 2004 Scott C. Klement                                         +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms
      * modification
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT
      * DAMAGES (INCLUDING
      * OR SERVICES; LOSS OF USE
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY
      * LIABILITY
      * OUT OF THE USE OF THIS SOFTWARE
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      /if defined(SENDMAIL_H)
      /eof
      /endif
      /define SENDMAIL_H
     D QtmmSendMail    PR                  ExtProc('QtmmSendMail')
     D   FileName                   255A   const options(*varsize)
     D   FileNameLen                 10I 0 const
     D   MsgFrom                    256A   const options(*varsize)
     D   MsgFromLen                  10I 0 const
     D   RecipBuf                          likeds(ADDTO0100)
     D                                     dim(32767)
     D                                     options(*varsize)
     D   NumRecips                   10I 0 const
     D   ErrorCode                 8000A   options(*varsize)
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
