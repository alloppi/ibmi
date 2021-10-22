      * CH7RECURSE: Just in case that last example wasn't complicated
      *   enough!
      *  (From Chap 7)
      *
      * To compile:
      *   CRTBNDRPG CH7RECURSE SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE') BNDDIR('IFSTEXT')

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy IFSEBOOK/QRPGLESRC,IFSTEXT_H

     D show_dir        PR            10I 0
     D   curdir                    1024A   varying const

     D STDIN           C                   CONST(0)
     D STDOUT          C                   CONST(1)
     D STDERR          C                   CONST(2)

     D S_ISDIR         PR             1N
     D   mode                        10U 0 value

     D curr            s           1024A
     D curdir          s           1024A   varying
     D line            S           1024A
     D len             S             10I 0

     D cmd             PR                  ExtPgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     c                   eval      *inlr = *on

     c                   callp     cmd('DLYJOB DLY(10)': 20)

     C*******************************************
     C* Use the getcwd() API to find out the
     C* name of the current directory:
     C*******************************************
     c                   if        getcwd(%addr(curr): %size(curr)) = *NULL
     c                   eval      line = 'getcwd(): ' +
     c                                     %str(strerror(errno))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDERR: %addr(line): len)
     c                   return
     c                   endif

     c                   eval      curdir = %str(%addr(curr))

     C*******************************************
     C*  Call our show_dir proc to show all
     C*  of the files (and subdirectories) in
     C*  the current directory.
     C*******************************************
     c                   callp     show_dir(curdir)
     c                   return


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  prints all of the files in the directory to STDOUT.
      *
      *  if a subdirectory is found, this procedure will call
      *  itself (recursively) to process that directory.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P show_dir        B
     D show_dir        PI            10I 0
     D   curdir                    1024A   varying const

     D mystat          S                   like(statds)
     D dir             S               *
     D line            S           1024A
     D len             S             10I 0
     D filename        S           1024A   varying
     D fnwithdir       S           1024A   varying
     D err             S             10I 0

     C*******************************************
     C* open the current directory:
     C*******************************************
     c                   eval      dir = opendir(curdir)
     c                   if        dir = *NULL
     c                   eval      err = errno
     c                   eval      line = 'opendir(): ' +
     c                                     %str(strerror(err)) +
     c                              ', errno=' + %trim(%editc(err:'L'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDERR: %addr(line): len)
     c                   if        err = EACCES
     c                   return    0
     c                   else
     c                   return    -1
     c                   endif
     c                   endif

     c                   eval      p_dirent = readdir(dir)

     c                   dow       p_dirent <> *NULL

     c                   eval      filename = %subst(d_name:1:d_namelen)
     c                   eval      fnwithdir = curdir + '/' + filename

     c                   if        filename<>'.' and filename<>'..'

     c                   if        stat(fnwithdir: %addr(mystat))<0
     c                   eval      line = 'stat(): ' +
     c                                     %str(strerror(errno))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDERR: %addr(line): len)
     c                   return    -1
     c                   endif

     c                   eval      line = fnwithdir
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDOUT: %addr(line): len)

     c                   eval      p_statds = %addr(mystat)
     c                   if        S_ISDIR(st_mode)
     c                   if        show_dir(fnwithdir) < 0
     c                   return    -1
     c                   endif
     c                   endif

     c                   endif

     c                   eval      p_dirent = readdir(dir)
     c                   enddo

     c                   callp     closedir(dir)

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This tests a file mode to see if a file is a directory.
      *
      * Here is the C code we're trying to duplicate:
      *      #define _S_IFDIR    0040000                                       */
      *      #define S_ISDIR(mode) (((mode) & 0370000) == _S_IFDIR)
      *
      * 1) ((mode) & 0370000) takes the file's mode and performs a
      *      bitwise AND with the octal constant 0370000.  In binary,
      *      that constant looks like: 00000000000000011111000000000000
      *      The effect of this code is to turn off all bits in the
      *      mode, except those marked with a '1' in the binary bitmask.
      *
      * 2) ((result of #1) == _S_IFDIR)  What this does is compare
      *      the result of step 1, above with the _S_IFDIR, which
      *      is defined to be the octal constant 0040000.  In decimal,
      *      that octal constant is 16384.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P S_ISDIR         B
     D S_ISDIR         PI             1N
     D   mode                        10U 0 value

     D                 DS
     D  dirmode                1      4U 0
     D  byte1                  1      1A
     D  byte2                  2      2A
     D  byte3                  3      3A
     D  byte4                  4      4A

     C* Turn off bits in the mode, as in step (1) above.
     c                   eval      dirmode = mode

     c                   bitoff    x'FF'         byte1
     c                   bitoff    x'FE'         byte2
     c                   bitoff    x'0F'         byte3
     c                   bitoff    x'FF'         byte4

     C* Compare the result to 0040000, and return true or false.
     c                   if        dirmode = 16384
     c                   return    *On
     c                   else
     c                   return    *Off
     c                   endif
     P                 E

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
