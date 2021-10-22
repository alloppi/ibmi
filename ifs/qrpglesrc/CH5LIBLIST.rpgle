      * CH5LIBLIST: Example of a report in ASCII text format
      *  (From Chap 5)
      *
      * To compile:
      *   CRTBNDRPG CH5LIBLIST SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE') BNDDIR('IFSTEXT')

     FQADSPOBJ  IF   E           K DISK    USROPN

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy IFSEBOOK/QRPGLESRC,IFSTEXT_H

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   len                         15P 5 const

     D FmtDate         PR            10A
     D   mmddyy                       6A   const

     D fd              S             10I 0
     D line            S            100A
     D len             S             10I 0
     D LineNo          S             10I 0

     c     *entry        plist
     c                   parm                    MyLib            10

     C*********************************************************
     C* Create a file containing the objects we wish to report
     C*********************************************************
     C                   callp     cmd('DSPOBJD OBJ('+%trim(MyLib)+'/*ALL)'+
     C                               ' OBJTYPE(*ALL) OUTPUT(*OUTFILE) ' +
     C                               ' OUTFILE(QTEMP/QADSPOBJ) ' +
     C                               ' OUTMBR(*FIRST *REPLACE)': 200)

     C*********************************************************
     C* Open the list of objects:
     C*********************************************************
     c                   callp     cmd('OVRDBF FILE(QADSPOBJ) TOFILE(' +
     c                                  'QTEMP/QADSPOBJ)': 200)
     c                   open      QADSPOBJ

     C*********************************************************
     C* Open a stream file to write report to:
     C*********************************************************
     c                   eval      fd = open('/ifstest/object_report.txt':
     c                                 O_CREAT+O_TRUNC+O_CODEPAGE+O_WRONLY:
     c                                 S_IRWXU+S_IRWXG+S_IROTH: 819)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     close(fd)

     c                   eval      fd = open('/ifstest/object_report.txt':
     c                                       O_TEXTDATA+O_WRONLY)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     C*********************************************************
     C* Create the report
     C*********************************************************
     c                   exsr      Heading
     c                   read      QADSPOBJ

     c                   dow       not %eof(QADSPOBJ)
     c                   exsr      WriteObj
     c                   read      QADSPOBJ
     c                   enddo


     C*********************************************************
     c* Clean up and exit
     C*********************************************************
     c                   callp     close(fd)
     c                   close     QADSPOBJ
     c                   callp     cmd('DLTOVR FILE(QADSPOBJ)': 50)
     c                   callp     cmd('DLTF QTEMP/QADSPOBJ': 50)

     c                   eval      *inlr = *on


     C*===============================================================
     C* Write a heading on the report
     C*===============================================================
     CSR   Heading       begsr
     C*------------------------
     C* x'0C' = Form Feed
     C                   eval      line = x'0c'
     c                   eval      len = 1
     c                   callp     writeline(fd: %addr(line): len)

     C                   eval      line = 'Listing of objects in ' +
     c                               %trim(MyLib) + ' library'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     c                   eval      line = *blanks
     c                   eval      len = 0
     c                   callp     writeline(fd: %addr(line): len)

     c                   eval      line = 'Object Name'
     c                   eval      %subst(line: 15) = 'Object Type'
     c                   eval      %subst(line: 30) = 'Object Size'
     c                   eval      %subst(line: 45) = 'Last Modified'
     c                   eval      %subst(line: 60) = 'Last Used'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     c                   eval      line = '-----------'
     c                   eval      %subst(line: 15) = '-----------'
     c                   eval      %subst(line: 30) = '-----------'
     c                   eval      %subst(line: 45) = '-------------'
     c                   eval      %subst(line: 60) = '---------'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     c                   eval      LineNo = 5
     C*------------------------
     csr                 endsr


     C*===============================================================
     C* Add an object to the report
     C*===============================================================
     CSR   WriteObj      begsr
     C*------------------------
     c                   if        LineNo > 60
     c                   exsr      Heading
     c                   endif

     c                   eval      Line = odObNm
     c                   eval      %subst(line: 15) = odobtp
     c                   eval      %subst(line: 30) = %editc(odobsz:'L')
     c                   eval      %subst(line: 45) = FmtDate(odldat)
     c                   eval      %subst(line: 60) = FmtDate(odudat)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)

     c                   eval      LineNo = LineNo + 1
     C*------------------------
     csr                 endsr


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Format a date into human-readable YYYY-MM-DD format:
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P FmtDate         B
     D FmtDate         PI            10A
     D   mmddyy                       6A   const

     D Temp6           S              6  0
     D TempDate        S               D
     D Temp10          S             10A

     C* If date isn't a valid number, return *blanks
     c                   testn                   mmddyy               99
     c                   if        *in99 = *off
     c                   return    *blanks
     c                   endif

     C* If date isn't a valid MMDDYY date, return *blanks
     c                   move      mmddyy        Temp6
     c     *mdy          test(de)                Temp6
     c                   if        %error
     c                   return    *blanks
     c                   endif

     C* Convert date to ISO format, and return it.
     c     *mdy          move      Temp6         TempDate
     c     *iso          move      TempDate      Temp10
     c                   return    Temp10

     P                 E

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
