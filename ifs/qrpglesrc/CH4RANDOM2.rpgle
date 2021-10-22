      * CH4RANDOM: Example of random access to an IFS object
      *  (From Chap 3)
      *
      * To compile:
      *   CRTBNDRPG CH3RANDOM SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D fd              S             10I 0
     D err             S             10I 0
     D wrdata          S             48A
     D rddata          S             22A
     D ShowMe          S             48A   varying

     c                   eval      fd = open('/ifstest/ch2_test.dat':
     c                                    O_WRONLY+O_CREAT+O_TRUNC:
     c                                    S_IRUSR+S_IWUSR+S_IRGRP)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     C* Write some data
     c                   eval      wrdata = 'THE QUICK BROWN FOX JUMP' +
     c                                      'ED OVER THE LAZY GIRAFFE'
     c                   if        write(fd: %addr(wrdata): %size(wrdata))<1
     c                   eval      err = errno
     c                   callp     close(fd)
     c                   callp     die('write(): ' + %str(strerror(errno)))
     c                   endif

     c                   callp     close(fd)

     c                   eval      fd = open('/ifstest/ch2_test.dat':
     c                                    O_RDONLY)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   eval      %len(ShowMe) = 0

     C* Read the first 16 bytes
     c                   callp     read(fd: %addr(rddata): 16)
     c                   eval      ShowMe = ShowMe + %subst(rddata:1:16)

     C* Jump to byte 41 of the file
     C* and read 7 bytes
     c                   if        lseek(fd: 41: SEEK_SET) < 0
     c                   callp     die('lseek(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     read(fd: %addr(rddata): 7)
     c                   eval      ShowMe = ShowMe + %subst(rddata:1:7)

     C* Jump to byte 19 of the file
     C* and read 22 bytes
     c                   if        lseek(fd: 19: SEEK_SET) < 0
     c                   callp     die('lseek(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     read(fd: %addr(rddata): 22)
     c                   eval      ShowMe = ShowMe + %subst(rddata:1:22)

     C* Jump to byte 16 of the file
     C* and read 3 bytes
     c                   if        lseek(fd: 16: SEEK_SET) < 0
     c                   callp     die('lseek(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     read(fd: %addr(rddata): 3)
     c                   eval      ShowMe = ShowMe + %subst(rddata:1:3)

     c                   callp     close(fd)

     C* Show what we read
     c                   dsply                   ShowMe

     c                   eval      *inlr = *on

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
