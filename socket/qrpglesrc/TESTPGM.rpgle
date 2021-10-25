     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

      *** header files for calling service programs & APIs

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h

     D sock            S             10I 0
     D user            S             10A

     c     *entry        plist
     c                   parm                    sock
     c                   parm                    user

     c                   callp     WrLine(sock: 'Hello ' + %trim(user))
     c                   callp     WrLine(sock: 'Goodbye ' + %trim(user))

     c                   eval      *inlr = *on
