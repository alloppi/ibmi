      * CH3RENDEL: Example of deleting/renaming objects in the IFS
      *  (From Chap 3)
      *
      * To compile:
      *   CRTBNDRPG CH3RENDEL SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     FCH3RENDELSCF   E             WORKSTN

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H

     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'

     D Path            S            640A
     D NewPath         S            640A
     D LowerNewPath    S            640A
     D MyStat          S                   like(statds)
     D Len             S             10I 0
     D Pos             S             10I 0

      ** Warning:  call this program from the command.  If you call
      **       it directly, because "Path" is larger than 32 bytes.
      **       See http://faq.midrange.com/data/cache/70.html
      **

     C     *entry        plist
     c                   parm                    Path
     c                   parm                    NewPath

     c     upper:lower   xlate     NewPath       LowerNewPath

     c                   if        LowerNewPath = '*delete'
     c                   exsr      KillIt
     c                   else
     c                   exsr      NewIdentity
     c                   endif

     c                   eval      *inlr = *on


     C**************************************************************
     C* Kill off the file (Delete it from the IFS)
     C**************************************************************
     CSR   KillIt        begsr
     C*-------------------------
     C* Retrieve current file stats:
     c                   if        stat(%trimr(path): %addr(mystat)) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     C* Get file size from stats
     c                   eval      p_statds = %addr(mystat)
     c                   eval      scSize = st_size

     C* Strip directory names from front of pathname:
     c                   eval      Len = %len(%trimr(path))
     c                   eval      Pos = Len
     c                   dow       Pos > 0
     c                   if        %subst(path:Pos:1) = '/'
     c                   leave
     c                   endif
     c                   eval      Pos = Pos -1
     c                   enddo
     c                   if        Pos<Len and %subst(path:Pos:1) = '/'
     c                   eval      scFile = %subst(path:Pos+1)
     c                   else
     c                   eval      scFile = path
     c                   endif

     C* Ask user if he/she REALLY wants to delete it?
     c                   exfmt     RENDELS1

     C* Then ignore his choice and delete it anyway.
     C* (just kidding)
     c                   if        scReally = 'Y'
     c                   if        unlink(%trimr(path)) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif
     c                   endif
     C*-------------------------
     CSR                 endsr


     C**************************************************************
     C* Give the file a new identity.  A new purpose in life!
     C* (okay, rename it...)
     C**************************************************************
     CSR   NewIdentity   begsr
     C*-------------------------
     c                   if        rename(%trimr(Path): %trimr(NewPath))<0
     c                   callp     die(%str(strerror(errno)))
     c                   endif
     C*-------------------------
     CSR                 endsr


      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
