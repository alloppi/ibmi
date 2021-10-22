     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE')

     D*copy ifsebook/qrpglesrc,ifsio_h
     D*copy ifsebook/qrpglesrc,errno_h
     D/copy qifssrc,ifsio_h
     D/copy qifssrc,errno_h

     c                   if        chmod('/home/cya012/ifs/littlepgm.com':
     c                                   S_IRUSR + S_IWUSR + S_IXUSR) < 0
     c                   callp     EscErrno(errno)
     c                   endif

     c                   eval      *inlr = *on

     D/define ERRNO_LOAD_PROCEDURE
     D*copy ifsebook/qrpglesrc,errno_h
     D/copy qifssrc,errno_h
