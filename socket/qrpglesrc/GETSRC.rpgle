     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

     FSOURCE    IF   F  252        DISK    USROPN INFDS(dsSrc)

      *** header files for calling service programs & APIs

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D dsSrc           DS
     D   dsSrcRLen           125    126I 0

     D lower           C                   'abcdefghijklmnopqrstuvwxyz'
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     D sock            S             10I 0
     D user            S             10A
     D file            S             21A
     D mbr             S             10A
     D reclen          S              5I 0

     ISOURCE    NS
     I                                 13  252  SrcDta

     c     *entry        plist
     c                   parm                    sock
     c                   parm                    user

     c                   eval      *inlr = *on

     c                   callp     WrLine(sock: '110 Name of source file?')
     c                   if        RdLine(sock: %addr(file): 21: *On) < 0
     c                   return
     c                   endif

     c                   callp     WrLine(sock: '111 Name of member?')
     c                   if        RdLine(sock: %addr(mbr): 21: *On) < 0
     c                   return
     c                   endif

     c     lower:upper   xlate     file          file
     c     lower:upper   xlate     mbr           mbr

     c                   callp(e)  cmd('OVRDBF FILE(SOURCE) ' +
     c                                        'TOFILE('+%trim(file)+') ' +
     c                                        'MBR(' +%trim(mbr)+ ')': 200)
     c                   if        %error
     c                   callp     WrLine(sock: '910 Error calling OVRDBF')
     c                   return
     c                   endif

     c                   open(e)   SOURCE
     c                   if        %error
     c                   callp     WrLine(sock: '911 Unable to open file!')
     c                   callp     Cmd('DLTOVR FILE(SOURCE)': 200)
     c                   return
     c                   endif

     c                   eval      reclen = dsSrcRLen - 12

     c                   read      SOURCE
     c                   dow       not %eof(SOURCE)
     c                   if        WrLine(sock:
     c                                    '.' + %subst(SrcDta:1:reclen)) < 0
     c                   leave
     c                   endif
     c                   read      SOURCE
     c                   enddo

     c                   callp     WrLine(sock: '112 Download successful!')

     c                   close     SOURCE
     c                   callp     Cmd('DLTOVR FILE(SOURCE)': 200)
     c                   return
