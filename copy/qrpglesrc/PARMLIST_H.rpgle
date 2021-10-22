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
      /if defined(PARMLIST_H_DEFINED)
      /eof
      /endif
      /define PARMLIST_H_DEFINED
     D npm_ParmList_Addr...
     D                 PR              *   ExtProc('_NPMPARMLISTADDR')
     D Npm_ParmList_t  ds                  qualified
     D                                     based(Template)
     D   desclist                      *
     D   workarea                    16A
     D   parm                          *   dim(400)
     D Npm_DescList_t  ds                  qualified
     D                                     based(Template)
     D   argc                        10i 0
     D                               28A
     D   desc                          *   dim(400)
     D Npm_Desc_t      ds                  qualified
     D                                     based(Template)
     D   type                         3i 0
     D   datatype                     3i 0
     D   inf1                         3i 0
     D   inf2                         3i 0
     D   len                         10i 0
