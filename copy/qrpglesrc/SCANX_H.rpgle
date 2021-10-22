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
      *  /COPY information for the _SCANX MI builtin:
      *
      /if defined(SCANX_H_DEFINED)
      /eof
      /endif
      /define SCANX_H_DEFINED
     D SCWC_Control_T  ds                  qualified
     D                                     based(Template)
     D   Inds                         3U 0
     D                                1A
     D   Comp_Char                    2A
     D                                1A
     D   Work_Area                    1A
     D   Base_Length                  5I 0
     D   Enh_Length                  20U 0
     D   Enh_Resume                  20U 0
      *
      * flags for "Inds" parameter of controls
      *
     D SCANX_BASE_EXTENDED...
     D                 C                   128
     D SCANX_COMP_EXTENDED...
     D                 C                   64
     D SCANX_ENHANCED...
     D                 C                   2
     D SCANX_SCAN_START...
     D                 C                   1
      *
      * flags for "scan_opt" parameter of _SCANX
      *
     D SCANX_NONMIXED...
     D                 C                   1073741824
     D SCANX_EQ...
     D                 C                   134217728
     D SCANX_GT...
     D                 C                   67108864
     D SCANX_LT...
     D                 C                   33554432
     D SCANX_TEST_ESCAPE...
     D                 C                   16777216
     D SCANX           PR            10I 0 extproc('_SCANX')
     D   base_locator                  *
     D   controls                          likeds(SCWC_Control_T)
     D   scan_opts                   10I 0 value
