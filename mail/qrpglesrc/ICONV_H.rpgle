      /if defined(ICONV_H)
      /eof
      /endif
      /define ICONV_H

     /*-                                                                            +
      * Copyright (c) 2006 Scott C. Klement                                         +
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

     d iconv_t         DS                  qualified
     d                                     based(StructureTemplate)
     d   return_value                10I 0
     d   cd                          10I 0 dim(12)

     d QtqCode_T       DS                  qualified
     d  CCSID                        10I 0 inz
     d  ConvAlt                      10I 0 inz
     d  SubsAlt                      10I 0 inz
     d  ShiftAlt                     10I 0 inz(1)
     d  InpLenOp                     10I 0 inz(0)
     d  ErrorOpt                     10I 0 inz(1)
     d  Reserved                      8A   inz(*ALLx'00')

     d QtqIconvOpen    PR                  extproc('QtqIconvOpen')
     d                                     like(iconv_t)
     d    toCode                           likeds(QtqCode_t) const
     d    fromCode                         likeds(QtqCode_t) const

     d iconv           PR            10I 0 extproc('iconv')
     d   cd                                like(iconv_t) value
     d   inbuf                         *
     d   inbytesleft                 10U 0
     d   outbuf                        *
     d   outbytesleft                10U 0

     D iconv_close     PR            10I 0 extproc('iconv_close')
     D   cd                                like(iconv_t) value
