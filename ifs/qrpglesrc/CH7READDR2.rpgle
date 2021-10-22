      * CH7READDIR: Example of reading a directory in the IFS
      *  (From Chap 7)
      *
      * To compile:
      *   CRTBNDRPG CH7READDIR SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D dir             s               *
     D Msg             S             52A

     c                   eval      dir = opendir('/home/cya012')
     c                   if        dir = *NULL
     c                   callp     die('opendir(): '+%str(strerror(errno)))
     c                   endif

     c                   eval      p_dirent = readdir(dir)
     c                   dow       p_dirent <> *NULL
     c                   eval      Msg = %subst(d_name:1:d_namelen)
     c     msg           dsply
     c                   eval      p_dirent = readdir(dir)
     c                   enddo

     c                   callp     closedir(dir)

     c                   eval      Msg = 'Press ENTER to end'
     c                   dsply                   Msg

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
