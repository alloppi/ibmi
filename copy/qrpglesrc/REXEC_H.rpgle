     /*-                                                                            +
      * Copyright (c) 2005 Scott C. Klement                                         +
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
      /if defined(REXEC_H_DEFINED)
      /eof
      /endif
      /define REXEC_H_DEFINED
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * rexec() - Issue a command on a remote host
      *
      * int rexec(char **host
      *             char *command
      *
      * Returns:  socket to remote host
      *        or -1 if unsuccessful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D rexec           PR            10I 0 extproc('rexec')
     D   host                          *   value
     D   port                        10I 0 value
     D   user                          *   value options(*string)
     D   password                      *   value options(*string)
     D   command                       *   value options(*string)
     D   errorDescrip                10I 0 options(*omit)
