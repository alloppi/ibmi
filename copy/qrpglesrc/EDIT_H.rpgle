     /*-                                                                            +
      * Copyright (c) 2008 Scott C. Klement                                         +
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
      /if defined(EDIT_H_DEFINED)
      /eof
      /endif
      /define EDIT_H_DEFINED
     D QECCVTEC        PR                  ExtPgm('QECCVTEC')
     D   OutMask                    256a   options(*varsize)
     D   OutMaskLen                  10i 0
     D   OutRcvLen                   10i 0
     D   OutZeroBal                   1a
     D   EditCode                     1a   const
     D   FillorFloat                  1a   const
     D   SourcePrec                  10i 0 const
     D   SourceDecPos                10i 0 const
     D   ErrorCode                32767a   options(*varsize)
     D QECCVTEW        PR                  ExtPgm('QECCVTEW')
     D   OutMask                    256a   options(*varsize)
     D   OutMaskLen                  10i 0
     D   OutRcvLen                   10i 0
     D   EditWord                   256a   options(*Varsize) const
     D   EditWordLen                 10i 0 const
     D   ErrorCode                32767a   options(*varsize)
     D   Sourcelen                   10i 0 const options(*nopass)
     D   CurrSymm                     1a   const options(*nopass)
     D QECEDT          PR                  ExtPgm('QECEDT')
     D   RcvVar                     256a   options(*varsize)
     D   RcvVarLen                   10i 0 const
     D   SrcVar                      63a   const
     D   SrcVarClass                 10a   const
     D   Precision                   10i 0 const
     D   OutMask                    256a   const options(*varsize)
     D   OutMaskLen                  10i 0 const
     D   OutZeroBal                   1a   const
     D   ErrorCode                32767a   options(*varsize)
