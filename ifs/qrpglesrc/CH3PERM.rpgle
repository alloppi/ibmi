      * CH3PERM: Example changing an IFS object's permissions
      *  (From Chap 3)
      *
      * To compile:
      *   CRTBNDRPG CH3PERM SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D*copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D Path            S            640A
     D UserPerm        S             10A
     D GroupPerm       S             10A
     D OtherPerm       S             10A
     D Mode            S             10I 0

      ** Warning:  call this program from the command.  If you call
      **       it directly, because "Path" is larger than 32 bytes.
      **       See http://faq.midrange.com/data/cache/70.html
      **

     C     *entry        plist
     c                   parm                    Path
     c                   parm                    UserPerm
     c                   parm                    GroupPerm
     c                   parm                    OtherPerm

     c                   eval      Mode = 0

     C* Calculate desired user permissions:
     c                   if        %scan('R': UserPerm) > 0
     c                   eval      Mode = Mode + S_IRUSR
     c                   endif
     c                   if        %scan('W': UserPerm) > 0
     c                   eval      Mode = Mode + S_IWUSR
     c                   endif
     c                   if        %scan('X': UserPerm) > 0
     c                   eval      Mode = Mode + S_IXUSR
     c                   endif

     C* Calculate desired group permissions:
     c                   if        %scan('R': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IRGRP
     c                   endif
     c                   if        %scan('W': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IWGRP
     c                   endif
     c                   if        %scan('X': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IXGRP
     c                   endif

     C* Calculate desired permissions for everyone else:
     c                   if        %scan('R': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IROTH
     c                   endif
     c                   if        %scan('W': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IWOTH
     c                   endif
     c                   if        %scan('X': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IXOTH
     c                   endif

     C* Change the file's access mode:
     c                   if        chmod(%trimr(path): Mode) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /COPY QIFSSRC,ERRNO_H
