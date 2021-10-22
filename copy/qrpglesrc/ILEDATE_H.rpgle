     /*-                                                                            +
      * Copyright (c) 2007 Scott C. Klement                                         +
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
      /if defined(ILEDATE_H_DEFINED)
      /eof
      /endif
      /define ILEDATE_H_DEFINED
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CEEDAYS(): Convert character date into lilian
      *
      *   InputDate = (input) character string containing date
      *     picture = (input) picture string describing date fmt
      *      lilian = (output) the returned lilian date
      *    feedback = (i/o) error code (or *OMIT)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CEEDAYS         PR                  opdesc
     D   InputDate                65535A   const options(*varsize)
     D   picture                  65535A   const options(*varsize)
     D   Lilian                      10i 0
     D   Feedback                    12a   options(*omit)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CEEDATE(): Convert lilian date into character
      *
      *      Lilian = (input) Lilian date to format
      *     picture = (input) picture string describing output fmt
      *  OutputDate = (output) the returned character string
      *    feedback = (i/o) error code (or *OMIT)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CEEDATE         PR                  opdesc
     D   Lilian                      10i 0
     D   picture                  65535A   const options(*varsize)
     D   OutputDate               65535A   const options(*varsize)
     D   Feedback                    12a   options(*omit)
