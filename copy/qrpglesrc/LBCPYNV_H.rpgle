     /*-                                                                            +
      * Copyright (c) 2006 Scott C. Klement                                         +
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
      /if defined(LBCPYNV_H_DEFINED)
      /eof
      /endif
      /define LBCPYNV_H_DEFINED
     D LBCPYNV_attr_t  ds                  qualified
     D   type                         1A   inz(TYPE_INT)
     D   decpos                       3U 0 inz(0)
     D   digits                       3U 0 inz(0)
     D                               10I 0 inz(0)
     D TYPE_INT        c                   const(x'00')
     D TYPE_FLOAT      c                   const(x'01')
     D TYPE_ZONED      c                   const(x'02')
     D TYPE_PACKED     c                   const(x'03')
     D TYPE_CHAR       c                   const(x'04')
     D TYPE_UINT       c                   const(x'0A')
     D LBCPYNV         PR                  extproc('_LBCPYNV')
     D   Output                        *   value
     D   OutAttr                           likeds(LBCPYNV_attr_t) const
     D   Input                         *   value
     D   InpAttr                           likeds(LBCPYNV_attr_t) const
