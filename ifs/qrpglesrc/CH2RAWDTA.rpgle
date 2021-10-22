      * CH2RAWDTA: Example of writing non-text to a stream file
      *  (From Chap 2)
      *
      * To compile:
      *   CRTBNDRPG CH2RAWDTA SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D*copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D fd              S             10I 0
     D wrdata          S             79A
     D err             S             10I 0

     c                   eval      wrdata = x'B409BA0C01CD21B8004CCD21' +
     c                                      x'416C6C206F626A6563747320' +
     c                                      x'6F6E20746865205043206172' +
     c                                      x'652073746F72656420696E20' +
     c                                      x'2273747265616D2066696C65' +
     c                                      x'73222C206576656E2070726F' +
     c                                      x'6772616D732124'

     c                   eval      fd = open('/home/cya012/ifs/littlepgm.com':
     c                                       O_WRONLY+O_CREAT+O_TRUNC:
     c                                       S_IRUSR + S_IWUSR + S_IXUSR
     c                                     + S_IRGRP + S_IXGRP
     c                                     + S_IROTH + S_IXOTH)
     c                   if        fd < 0
     c                   callp     EscErrno(errno)
     c                   endif

     c                   if        write(fd: %addr(wrdata): %size(wrdata))
     c                                  < %size(wrdata)
     c                   eval      err = errno
     c                   callp     close(fd)
     c                   callp     EscErrno(err)
     c                   endif

     c                   callp     close(fd)

     c                   eval      *inlr = *on
     c                   return

      /DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /COPY QIFSSRC,ERRNO_H
