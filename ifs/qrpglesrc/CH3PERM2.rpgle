      * CH3PERM2: Example of changing permissions of an IFS object w/*SAME
      *  (From Chap 3)
      *
      * To compile:
      *   CRTBNDRPG CH3PERM2 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D Path            S            640A
     D UserPerm        S             10A
     D GroupPerm       S             10A
     D OtherPerm       S             10A
     D MyStat          S                   like(statds)

     D                 DS
     D Mode                          10I 0
     D CharMode3                      1A   overlay(Mode:3)
     D CharMode4                      1A   overlay(Mode:4)

      ** Warning:  call this program from the command.  If you call
      **       it directly, because "Path" is larger than 32 bytes.
      **       See http://faq.midrange.com/data/cache/70.html
      **

     C     *entry        plist
     c                   parm                    Path
     c                   parm                    UserPerm
     c                   parm                    GroupPerm
     c                   parm                    OtherPerm

     C* Retrieve current file mode:
     c                   if        stat(%trimr(path): %addr(mystat)) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     c                   eval      p_statds = %addr(mystat)
     c                   eval      Mode = st_mode

     C* Calculate desired user permissions:
     c                   if        UserPerm <> '*SAME'

     c                   bitoff    x'FF'         CharMode3
     c                   bitoff    x'C0'         CharMode4

     c                   if        %scan('R': UserPerm) > 0
     c                   eval      Mode = Mode + S_IRUSR
     c                   endif
     c                   if        %scan('W': UserPerm) > 0
     c                   eval      Mode = Mode + S_IWUSR
     c                   endif
     c                   if        %scan('X': UserPerm) > 0
     c                   eval      Mode = Mode + S_IXUSR
     c                   endif

     c                   endif

     C* Calculate desired group permissions:
     c                   if        GroupPerm <> '*SAME'

     c                   bitoff    x'38'         CharMode4

     c                   if        %scan('R': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IRGRP
     c                   endif
     c                   if        %scan('W': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IWGRP
     c                   endif
     c                   if        %scan('X': GroupPerm) > 0
     c                   eval      Mode = Mode + S_IXGRP
     c                   endif

     c                   endif

     C* Calculate desired permissions for everyone else:
     c                   if        OtherPerm <> '*SAME'

     c                   bitoff    x'07'         CharMode4

     c                   if        %scan('R': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IROTH
     c                   endif
     c                   if        %scan('W': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IWOTH
     c                   endif
     c                   if        %scan('X': OtherPerm) > 0
     c                   eval      Mode = Mode + S_IXOTH
     c                   endif

     c                   endif

     C* Change the file's access mode:
     c                   if        chmod(%trimr(path): Mode) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
