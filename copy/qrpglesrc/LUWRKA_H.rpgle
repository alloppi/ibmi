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
      /if defined(LUWRKA_DEFINED)
      /eof
      /endif
      /define LUWRKA_DEFINED
     D LU_Work_Area_t  ds                  qualified
     D                                     based(Template)
     D   LU_RC                        5i 0
     D                                2a
     D   Invoc_Mark                  10i 0
     D   Product_RC                  10i 0
     D   Exit_Status                 10i 0
     D   Cntrld_End                   1n
     D   JobDate                      7a
     D   Sws                          1n   dim(8)
     D LUWRKA          PR              *   ExtProc('_LUWRKA')
