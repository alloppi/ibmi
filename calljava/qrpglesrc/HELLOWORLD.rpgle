     H DFTACTGRP(*NO)

     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D command         s            200a
     D sayhello        PR                  EXTPROC(*JAVA
     D                                     :'HelloWorld'
     D                                     :'Hello')
     D                                     Static
      /free
          command = 'ADDENVVAR ENVVAR(CLASSPATH) VALUE(''/java'')';
          Exc_Cmd(command: 200);
          command = 'ADDENVVAR QIBM_RPG_JAVA_PROPERTIES ' +
                    'VALUE(''-Dos400.stdout=file:/java/out.txt;' +
                    '-Dos400.stderr=file:/java.err.txt;'')';
          Exc_Cmd(command: 200);
          command = 'ADDENVVAR ENVVAR(QIBM_USE_DESCRIPTOR_STDIO) VALUE(''Y'')';
          Exc_Cmd(command: 200);
          Exc_Cmd('CD (''/java'')': 200);
      /end-free
     C                   callp     sayhello
     C                   eval      *INLR = *ON
