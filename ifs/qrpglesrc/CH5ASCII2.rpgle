      * CH5ASCII: Example of text file in ASCII mode
      *  (From Chap 5)
      *
      * To compile:
      *   CRTBNDRPG CH5ASCII SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE') BNDDIR('IFSTEXT')

     D*copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D*copy IFSEBOOK/QRPGLESRC,IFSTEXT_H
     D/copy QIFSSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H
     D/copy QIFSSRC,IFSTEXT_H

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   len                         15P 5 const

     D fd              S             10I 0
     D line            S            100A
     D len             S             10I 0
     D msg             S             52A
     D err             S             10I 0

     D DataToConvert   s              5a
     D AsciiData       s              5a   ccsid(1208)
     D ChineseData     s             10a
     D UTF8Data        s             10a   ccsid(1208)

     c                   exsr      MakeFile
     c                   exsr      EditFile
     c                   exsr      ShowFile
     c                   eval      *inlr = *on


     C**************************************************************
     C* Write some text to a text file
     C**************************************************************
     CSR   MakeFile      begsr
     C*------------------------
     C* Make sure we don't have an old file that might be in the way
     C* (ENOENT means it didnt exist to begin with)
     c                   if        unlink('/home/cya012/ch5_file.txt') < 0
     c                   eval      err = errno
     c                   if        err <> ENOENT
     c                   callp     die('unlink(): ' + %str(strerror(err)))
     c                   endif
     c                   endif

     C* Create a new file, and assign it a code page of 1208:
     c                   eval      fd = open('/home/cya012/ch5_file.txt':
     c                                  O_CREAT+O_WRONLY+O_CODEPAGE:
     c                                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
     c                                  1208)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     close(fd)

     C* Now re-open the file in text mode.  Since it was assigned a
     C* code page of 1208, and we're opening it in text mode, OS/400
     C* will automatically translate to/from ASCII for us.
     c                   eval      fd = open('/home/cya012/ch5_file.txt':
     c                                       O_WRONLY+O_TEXTDATA+O_CCSID)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c*                  eval      ChineseData = '測試'
     c*                  eval      line = ChineseData
     c*                  eval      len = %len(%trimr(line))
     c*                  callp     writeline(fd: %addr(line): len)

     c                   eval      line = %ucs2('Dear Cousin,')
     c                   eval      len = %len(%trimr(line)) * 2
     c                   callp     writeline(fd: %addr(line): len)


     c                   callp     close(fd)
     C*------------------------
     CSR                 endsr


     C**************************************************************
     C*  Call the OS/400 text editor, and let the user change the
     C*  text around.
     C**************************************************************
     CSR   EditFile      begsr
     C*------------------------
     c                   callp     cmd('EDTF STMF(''/home/cya012/' +
     c                                           'ch5_file.txt'')': 200)
     C*------------------------
     CSR                 endsr


     C**************************************************************
     C*  Read file, line by line, and dsply what fits
     C*  (DSPLY has a lousy 52-byte max... blech)
     C**************************************************************
     CSR   ShowFile      begsr
     C*------------------------
     c                   eval      fd = open('/home/cya012/ch5_file.txt':
     c                                  O_RDONLY+O_TEXTDATA)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   dow       readline(fd: %addr(line): %size(line))>=0
     c                   eval      Msg = line
     c     Msg           dsply
     c                   enddo

     c                   callp     close(fd)

     c                   eval      Msg = 'Press ENTER to continue'
     c                   dsply                   Msg
     C*------------------------
     CSR                 endsr


      /DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /COPY QIFSSRC,ERRNO_H
