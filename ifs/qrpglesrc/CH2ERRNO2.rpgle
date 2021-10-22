      * CH2ERRNO2: Example of writing & reading data to a stream file
      *   with error handling.  (This is the same as CH2ERRNO except
      *   with write UTF-16)
      *  (From Chap 2)
      *
      * To compile:
      *   CRTBNDRPG CH2ERRNO2 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D*copy IFSeBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSeBOOK/QRPGLESRC,ERRNO_H
     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D fd              S             10I 0
     D wrdata          S             24C   ccsid(1200)
     D rddata          S             24C   ccsid(1200)
     D flag            S             10U 0
     D mode            S             10U 0
     D ErrMsg          S            250A
     D Msg             S             50A
     D Len             S             10I 0

     C****************************************************************
     C* Example of writing data to a stream file
     C****************************************************************
     c                   eval      flag = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID

     c                   eval      mode =  S_IRUSR + S_IWUSR
     c                                   + S_IRGRP
     c                                   + S_IROTH

     c                   eval      fd = open('/home/cya012/ifs/ch2_test2.dat':
     c                                       flag: mode: 1200)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for output: ' + ErrMsg)
     c                   endif

     C* Write some data
     c                   eval      wrdata = %ucs2('THE QUICK BROWN FOX JUMP'
     c                                    + x'0d25')
     c                   if        write(fd: %addr(wrdata)
     c                                     : %len(%trimr(wrdata))*2) < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('open(): ' + ErrMsg)
     c                   endif

     C* Write some more data
     c                   eval      wrdata = %ucs2('ED OVER THE LAZY GIRAFFE'
     c                                    + x'0d25')
     c                   if        write(fd: %addr(wrdata)
     c                                     : %len(%trimr(wrdata))*2) < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('open(): ' + ErrMsg)
     c                   endif

     C* close the file
     c                   callp     close(fd)

     C****************************************************************
     C* Example of reading data from a stream file
     C****************************************************************
     c                   eval      flag = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ch2_test2.dat':
     c                                       flag)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for input: ' + ErrMsg)
     c                   endif

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))
     c                   if        len < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('read(): ' + ErrMsg)
     c                   endif

     c                   eval      Msg = 'Length read = ' +
     c                                    %trim(%editc(len:'M'))
     c     Msg           dsply
     c                   dsply                   rddata

     c                   callp     close(fd)

     c                   eval      *inlr = *on
     c                   return

      *DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
