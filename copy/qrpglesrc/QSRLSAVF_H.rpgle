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
      /if defined(QSRLSAVF_H_DEFINED)
      /eof
      /endif
      /define QSRLSAVF_H_DEFINED
     D QSRLSAVF        PR                  ExtPgm('QSRLSAVF')
     D    UsrSpc                     20a   const
     D    Format                      8a   const
     D    QualSavf                   20a   const
     D    Filter                     10a   const
     D    Contin                     36a   const
     D    ErrorCode                  16a   const
     D SAVF0100_t      ds                  qualified
     D                                     based(Template)
     D   library                     10a
     D   savecmd                     10a
     D   savets                       8a
     D   Asp                         10i 0
     D   Records                     10i 0
     D   Objects                     10i 0
     D   AccPath                     10i 0
     D   Active                      10a
     D   Release                      6a
     D   DtaCpr                       1a
     D   SysSrl                       8a
     D                                3a
     D   AspDev                      10a
     D                                2a
     D   Mbrs                        10i 0
     D   Splfs                       10i 0
     D SAVF0200_t      ds                  qualified
     D                                     based(Template)
     D   object                      10a
     D   SavLib                      10a
     D   ObjType                     10a
     D   ExtAttr                     10a
     D   SavedTs                      8a
     D   ObjSize                     10i 0
     D   SizeMult                    10i 0
     D   Asp                         10i 0
     D   Data                         1a
     D   Owner                       10a
     D   DLO                         20a
     D   Folder                      63a
     D   Text                        50a
     D   AspDev                      10a
     D SAVF0300_t      ds                  qualified
     D                                     based(Template)
     D   file                        10a
     D   lib                         10a
     D   mbr                         10a
     D   extattr                     10a
     D   savets                       8a
     D   mbrs                        10i 0
