      *===================================================================*
      * Program name: PSXX0NR                                             *
      * Purpose.....: Change IFS object permissions                       *
      *                                                                   *
      * Date written: 2017/03/11                                          *
      * Remark......: Reference to:                                       *
      *   CH3PERM2: Example changing an IFS object's permissions w/*SAME  *
      *   http://www.scottklement.com/rpg/ifs_ebook/ch3perm2.html         *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- ----------------------------*
      * 2017/03/06 Alan       AC        06517 New develop                 *
      *===================================================================*
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     d/copy QCpySrc,IFSIO_H
     d/copy QCpySrc,ERRNO_H

     d path            S            640A
     d UserPerm        S             10A
     d GroupPerm       S             10A
     d OtherPerm       S             10A
     d mystat          S                   like(statds)

     d                 DS
     d Mode                          10U 0
     d CharMode3                      1A   overlay(Mode:3)
     d CharMode4                      1A   overlay(Mode:4)

      ** Warning:  call this program from the command.  If you call
      **       it directly, because "path" is larger than 32 bytes.
      **       See http://wiki.midrange.com/index.php/Parameter_passing
      **

     c     *entry        plist
     c                   parm                    path
     c                   parm                    UserPerm
     c                   parm                    GroupPerm
     c                   parm                    OtherPerm

      * Retrieve current file mode:
     c                   if        stat(%trimr(path): %addr(mystat)) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     c                   eval      p_statds = %addr(mystat)
     c                   eval      Mode = st_mode

      * Calculate desired user permissions:
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

      * Calculate desired group permissions:
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

      * Calculate desired permissions for everyone else:
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

      * Change the file's access mode:
     c                   if        chmod(%trimr(path): Mode) < 0
     c                   callp     die(%str(strerror(errno)))
     c                   endif

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QCpySrc,ERRNO_H
