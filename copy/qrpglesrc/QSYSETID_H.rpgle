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
      /if defined(QSYSETID_H)
      /eof
      /endif
      /define QSYSETID_H
     D uid_t           s             10U 0 based(template)
     D gid_t           s             10U 0 based(template)
     D QSYSETID_NOCHANGE...
     D                 c                   const(4294967295)
     D qsysetuid       PR            10I 0 extproc('qsysetuid')
     D   uid                               like(uid_t) value
     D qsyseteuid      PR            10I 0 extproc('qsyseteuid')
     D   uid                               like(uid_t) value
     D qsysetreuid     PR            10I 0 extproc('qsysetreuid')
     D   ruid                              like(uid_t) value
     D   euid                              like(uid_t) value
     D qsysetgid       PR            10I 0 extproc('qsysetgid')
     D   gid                               like(gid_t) value
     D qsysetegid      PR            10I 0 extproc('qsysetegid')
     D   gid                               like(gid_t) value
     D qsysetregid     PR            10I 0 extproc('qsysetregid')
     D   rgid                              like(gid_t) value
     D   egid                              like(gid_t) value
     D qsygetgroups    PR            10I 0 extproc('qsygetgroups')
     D   gidsize                     10I 0 value
     D   grouplist                         like(gid_t)
     D                                     dim(32767)
     D                                     options(*varsize)
     D qsysetgroups    PR            10I 0 extproc('qsysetgroups')
     D   gidsize                     10I 0 value
     D   grouplist                         like(gid_t)
     D                                     dim(32767)
     D                                     const
     D                                     options(*varsize)
