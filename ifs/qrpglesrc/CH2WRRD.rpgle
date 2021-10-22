      * CH2WRRD: Example of writing & reading data to a stream file
      *  (From Chap 2)
      *
      * To compile:
      *   CRTBNDRPG CH2WRRD SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     D*copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy QIFSSRC,IFSIO_H

     D fd              S             10I 0
     D wrdata          S             24A
     D rddata          S             48A
     D flags           S             10U 0
     D mode            S             10U 0
     D Msg             S             50A
     D Len             S             10I 0

     C****************************************************************
     C* Example of writing data to a stream file
     C****************************************************************
     c                   eval      flags = O_WRONLY + O_CREAT + O_TRUNC

     c                   eval      mode =  S_IRUSR + S_IWUSR
     c                                   + S_IRGRP
     c                                   + S_IROTH

     c                   eval      fd = open('/home/cya012/ifs/ch2_test.dat':
     c                                       flags: mode)
     c                   if        fd < 0
     c                   eval      Msg = 'open(): failed for writing'
     c                   dsply                   Msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif

     C* Write some data
     c                   eval      wrdata = 'THE QUICK BROWN FOX JUMP'
     c                   callp     write(fd: %addr(wrdata): %size(wrdata))

     C* Write some more data
     c                   eval      wrdata = 'ED OVER THE LAZY GIRAFFE'
     c                   callp     write(fd: %addr(wrdata): %size(wrdata))

     C* close the file
     c                   callp     close(fd)

     C****************************************************************
     C* Example of reading data from a stream file
     C****************************************************************
     c                   eval      flags = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ch2_test.dat':
     c                                       flags)
     c                   if        fd < 0
     c                   eval      Msg = 'open(): failed for reading'
     c                   dsply                   Msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))
     c                   eval      Msg = 'Length read = ' +
     c                                  %trim(%editc(len:'M'))
     c     Msg           dsply
     c                   dsply                   rddata

     c                   callp     close(fd)

     c                   eval      *inlr = *on
     c                   return
