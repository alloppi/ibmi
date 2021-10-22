      ** HELLO WORLD in the IFS Example:
      **  (From Chapter 1)
      **
      **  To compile:
      **     CRTBNDRPG CH1HELLO SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      **

     H DFTACTGRP(*NO) ACTGRP(*NEW)


      ** API call to open a stream file
      **
     D open            PR            10I 0 extproc('open')
     D   path                          *   value options(*string)
     D   oflag                       10I 0 value
     D   mode                        10U 0 value options(*nopass)
     D   codepage                    10U 0 value options(*nopass)

     D O_WRONLY        C                   2
     D O_CREAT         C                   8
     D O_TRUNC         C                   64

      ** API call to write data to a stream file
      **
     D write           PR            10I 0 extproc('write')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value

      ** API call to close a stream file
      **
     D close           PR            10I 0 extproc('close')
     D   fildes                      10I 0 value


     D fd              S             10I 0
     D data            S             12A
     D msg             S             52A

     C* Create an empty file called 'helloworld':
     c                   eval      fd = open('/helloworld':
     c                                      O_CREAT+O_TRUNC+O_WRONLY:
     c                                      (6*64)+(6*8)+(6))
     c                   if        fd < 0
     c                   eval      Msg = 'open failed!'
     c                   dsply                   msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif

     C* Write 'Hello World' to the file:
     c                   eval      data = 'Hello World!'
     c                   callp     write(fd: %addr(data): %size(data))

     C* Close the file:
     c                   callp     close(fd)

     c                   eval      *inlr = *on
