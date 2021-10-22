      * CH3CHKOBJ: Example of checking for an object in the IFS
      *  (From Chap 3)
      *
      * To compile:
      *   CRTBNDRPG CH3CHKOBJ SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *   CRTCMD CMD(CHKIFSOBJ) PGM(CH3CHKOBJ) SRCFILE(xxx/QCMDSRC)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D*copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D Path            S            640A
     D Authority       S             10A
     D AMode           S             10I 0

      ** Warning:  call this program from the command.  If you call
      **       it directly, because "Path" is larger than 32 bytes.
      **       See http://faq.midrange.com/data/cache/70.html
      **

     C     *entry        plist
     c                   parm                    Path
     c                   parm                    Authority

     C* First, just check if the file exists:
     c                   if        Access(%trimr(Path): F_OK) < 0
     c                   callp     EscErrno(errno)
     c                   endif

     C* Next, check if the current user has authority:
     c                   if        Authority <> '*NONE'

     c                   eval      amode = 0

     c                   if        %scan('R':Authority) > 0
     c                   eval      amode = amode + R_OK
     c                   endif
     c                   if        %scan('W':Authority) > 0
     c                   eval      amode = amode + W_OK
     c                   endif
     c                   if        %scan('X':Authority) > 0
     c                   eval      amode = amode + X_OK
     c                   endif

     c                   if        access(%trimr(Path): amode) < 0
     c                   callp     EscErrno(errno)
     c                   endif

     c                   endif

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /COPY QIFSSRC,ERRNO_H
