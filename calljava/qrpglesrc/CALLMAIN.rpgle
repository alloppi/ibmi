     h DftActgrp(*NO) ActGrp(*Caller)

     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

      * Prototype for SimpleJava Main() function
     d SimpleMain      PR                  EXTPROC(*JAVA:
     d                                     'SimpleJava':
     d                                     'main')
     d                                     STATIC
     d String                          O   CLASS(*JAVA:'java.lang.String')
     d                                     dim(3)
     d                                     Const

      * Prototype for Java String Object
     d crtString       PR              o   EXTPROC(*JAVA:
     d                                             'java.lang.String':
     d                                             *CONSTRUCTOR)
     d RPGBytes                      50A   Const Varying

      * Input/Output object
     d args            s               o   Class(*JAVA:'java.lang.String')
     d                                     dim(3)

      /free

          Exc_Cmd('CD (''/java'')': 200);

          args(1) = crtString('AS400');
          args(2) = crtString('Programmer');
          args(3) = crtString('31');
          SimpleMain(args);

          *inlr = *on;
          return;

      /end-free
