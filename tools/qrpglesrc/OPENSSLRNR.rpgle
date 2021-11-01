     H Option(*SrcStmt : *NoDebugIO) bnddir('QC2LE')
     h dftactgrp(*no)

     fAAPASSWDF IF A E             Disk

      /copy QCPYSRC,IFSIO_H

     d readline        pr            10i 0
     d   fd                          10i 0 value
     d   text                          *   value
     d   maxlen                      10i 0 value

     d cmd             pr                  extpgm('QCMDEXC')
     d  command                     200A   const
     d  length                       15P 5 const

     d filepath        c                   const('/home/cya012/passwd.bin')
     d fd              s             10i 0
     d line            s            100a
     d msg             s             50a
     d Len             s             10i 0
     d genrand         s            100a
     d data            s                   like(PASSWORD)

      /free
        // call openssl to generate password
        genrand = 'strqsh cmd(''openssl rand -base64 2048 > ' +
                  filepath + ''')';

        cmd(genrand : %Len(%Trim(genrand)));

        fd = open(filepath
             : O_RDONLY+O_TEXTDATA+O_CCSID
             : S_IRGRP: 37);

      /end-free

      * Read password file
     c                   if        fd < 0
     c                   eval      msg = 'open(): failed for reading'
     c                   dsply                   msg
     c                   eval      *inlr = *on
     c                   return
     c                   endif

     c                   dow       readline(fd: %addr(line):
     c                                          %size(line))>=0
     c                   eval      msg = line
     c                   eval      data = %Trim(data) + line
     c*    msg           dsply
     c                   enddo

     c                   callp     close(fd)

     c                   eval      PASSWORD = data
     c                   write     AAPASSWDFR                           99
     c                   If        *In99
     c                   eval      msg = 'error in write AAPASSWDF record'
     c                   dsply                   msg
     c                   endif

     c                   eval      *inlr = *on
     c                   return

     P readline        B
     D readline        PI            10i 0
     D   fd                          10i 0 value
     D   text                          *   value
     D   maxlen                      10i 0 value

     D rdbuf           S           1024a   static
     D rdpos           S             10i 0 static
     D rdlen           S             10i 0 static

     D p_retstr        S               *
     D RetStr          S          32766a   based(p_retstr)
     D len             S             10i 0

     c                   eval      len = 0
     c                   eval      p_retstr = text
     c                   eval      %subst(RetStr:1:MaxLen) = *blanks

     c                   dow       1 = 1

     C* Load the buffer
     c                   if        rdpos>=rdlen
     c                   eval      rdpos = 0
     c                   eval      rdlen=read(fd:%addr(rdbuf):%size(rdbuf))

     c                   if        rdlen < 1
     c                   return    -1
     c                   endif
     c                   endif

     C* Is this the end of the line?
     c                   eval      rdpos = rdpos + 1
     c                   if        %subst(rdbuf:rdpos:1) = x'25'
     c                   return    len
     c                   endif

     C* Otherwise, add it to the text string.
     c                   if        %subst(rdbuf:rdpos:1) <> x'0d'
     c                               and len<>maxlen
     c                   eval      len = len + 1
     c                   eval      %subst(retstr:len:1) =
     c                               %subst(rdbuf:rdpos:1)
     c                   endif

     c                   enddo
     c                   return    len
     P                 E
