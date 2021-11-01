      //--------------------------------------------------------------------------------------------
      // Author     : Alan Chan
      // Description: Program to interface with QRCodeGenerator.java so QR codes can be created.
      //--------------------------------------------------------------------------------------------
     H dftactgrp(*no)

      //------------------------
      // Program Entry
      //------------------------
     D GenQRCodeR      pr                  extpgm('GENQRCODER')
     D  P_Txt                      4296a   const
     D  P_Width                      10i 0 const
     D  P_Height                     10i 0 const
     D  P_File                      128a   const
     D  P_Result                           likeds(gResult)

     D GenQRCodeR      pi
     D  P_Txt                      4296a   const
     D  P_Width                      10i 0 const
     D  P_Height                     10i 0 const
     D  P_File                      128a   const
     D  P_Result                           likeds(gResult)

      //------------------------
      // Prototypes
      //------------------------
     D newStr          pr              o   class(*java: jStrConst)
     D  pStr                      32767a   const

     D trimStr         pr              o   extproc(*java: jStrConst: 'trim')
     D                                     class(*java: jStrConst)

     D QCMDEXC         pr                  extpgm('QCMDEXC')
     D  pCmd                       1024a   const
     D  pLen                         15  5 const

     D GenQRCode_gen   pr              o   class(*java: jStrConst) static
     D                                     extproc(
     D                                      *java:
     D                                      'hk.com.promise.qrcode.QRCodeGenera-
     D                                     tor':
     D                                      'generate')
     D  pTxt                           o   class(*java: jStrConst) const
     D  pWidth                       10i 0 value
     D  pHeight                      10i 0 value
     D  pFile                          o   class(*java: jStrConst) const

     DgetBytes         pr         65535a   varying
     D                                     extproc(*java:jStrConst:'getBytes')

     D Error_throw     pr
     D  pCode                        10a   value
     D  pText                      5000a   value

      //------------------------
      // Global variables
      //------------------------
     D jStrConst       c                   'java.lang.String'

     D qte             s              1a   inz('''')
     D cmd             s           1024a
     D jStr            s               o   class(*java: jStrConst)

     D gResult         ds                  qualified
     D  code                         10a
     D  text                       5000a
      /free

       *inlr = *on;

       //
       // Setup the Java environment.
       //
       monitor;
         cmd = 'ADDENVVAR ENVVAR(CLASSPATH) REPLACE(*YES) VALUE(' +
            qte +
            '/javaapps/QRCode/bin' +
            ':/javaapps/QRCode/bin/core-2.2.jar' +
            ':/javaapps/QRCode/bin/javase-2.2.jar' +
            qte + ')';

         QCMDEXC(%trimr(cmd): %len(%trimr(cmd)) );

         cmd = 'ADDENVVAR ENVVAR(QIBM_RPG_JAVA_PROPERTIES) ' +
           'REPLACE(*YES) VALUE(' + qte +
           '-Djava.version=1.8;' +
           '-Djava.awt.headless=true;' +
           qte + ')';

         QCMDEXC(%trimr(cmd): %len(%trimr(cmd)) );
       on-error;
       endmon;

       //
       // Invoke the generate Java method within the QRCodeGenerator Class
       //
       monitor;
         jStr =
           GenQRCode_gen(
             newStr(P_Txt): P_Width: P_Height: newStr(P_File));
         gResult = getBytes(jStr);
       on-error ;
         gResult.code = 'ERROR';
         gResult.text =
           'An error occurred during the call to GENQRCODER_gen.' +
           'Check the joblog for more information.';
       endmon;

       select;
       when %parms = 4 and gResult.code <> 'SUCCESS';
         Error_throw(gResult.code: gResult.text);
       when %parms = 5;
         P_Result = gResult;
       endsl;

      /end-free


      //--------------------------------------------------------------------------------------------
      // Description: Misc function that will create a Java String object from the passed in chars
      //--------------------------------------------------------------------------------------------
     P newStr          b
     D newStr          pi              o   class(*java: jStrConst)
     D  pString                   32767a   const

     D string          s               o   class(*java: jStrConst)

     D newJavaStr      pr              o   extproc(*java: jStrConst:
     D                                     *constructor)
     D                                     class(*java: jStrConst)
     D parm                       32767a   const
      /free

       monitor;
         string = newJavaStr(%trim(pString));
         return trimStr(string);
       on-error;
         return newJavaStr('');
       endmon;

      /end-free
     P                 e

      //--------------------------------------------------------------------------------------------
      // Description: Throw an error onto the call stack.
      //--------------------------------------------------------------------------------------------
     P Error_throw     b
     D Error_throw     pi
     D  pCode                        10a   value
     D  pText                      5000a   value

     D errDS           ds                  qualified
     D  provided                     10i 0
     D  available                    10i 0
     D  msgid                         7a
     D  rsvd                          1a
     D  msgdta                       80

     D sndpgmmsg       pr                  extpgm('QMHSNDPM')
     D  msgid                         7a   const
     D  msgf                         20a   const
     D  msgdta                    32767a   const options(*varsize)
     D  msgdtalen                    10i 0 const
     D  msgtype                      10a   const
     D  callstkent                   10a   const
     D  callstkcnt                   10i 0 const
     D  msgkey                        4a   const
     D  error                              likeds(errDS)
      /free

       sndpgmmsg(
         'CPF9897':
         'QCPFMSG   *LIBL     ':
         %trimr(pCode + pText):
         %len(%trimr(pCode + pText)):
         '*INFO':
         '*':
         0:
         '    ':
         errDS);

      /end-free
     P                 e

