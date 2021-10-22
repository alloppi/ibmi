     H NOMAIN THREAD(*SERIALIZE) OPTION(*SRCSTMT)
     D**********************************************************************
     D* JavaMail Service Program
     D**********************************************************************
     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D*
     D* Source code/material located at http://www.mc-store.com/5105.html
     D* On the books page, click the reviews, errata, downloads icon to go
     D* to the books forum.  This source code may not be hosted on any
     D* other site without my express, prior, written permission.
     D*
     D* I disclaim any and all responsibility for any loss, damage or
     D* destruction of data or any other property which may arise using
     D* this code. I will in no case be liable for any monetary damages
     D* arising from such loss, damage or destruction.
     D*
     D* This code is intended for educational purposes, which includes
     D* minimal exception handling to focus on the topic being discussed.
     D* You may want to implement additional exception handling to prepare
     D* for a production environment.
     D*
     D* Happy Coding!
     D**********************************************************************
     D* Official JavaMail Website:
     D* http://java.sun.com/products/javamail/
     D**********************************************************************
     D*   HOW TO COMPILE:
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(AIRLIB/SVAIREMAIL) SRCFILE(AIRLIB/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE SERVICE PROGRAM)
     D*   CRTSRVPGM SRVPGM(AIRLIB/SVAIREMAIL) EXPORT(*ALL)
     D*   BNDSRVPGM(SVAIRFUNC SVAIRJAVA) ACTGRP(SVAIREMAIL)
     D**********************************************************************
     D*** PROTOTYPES ***
     D* OS400_JVM_12 IDENTIFIES JVM >= 1.2
     D/DEFINE OS400_JVM_12
     D/DEFINE JNI_COPY_ALL
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREMAIL
     D                SDS
     D  QPGM                   1     10
     D  MSGTXT                91    170
     D  QUSER                254    263
     D  QDATE                276    281
     D  QTIME                282    287  0
     D  QCUSER               358    367
     D**********************************************************************
     D*  AirEmail_newMessage(): Creates a New MimeMessage Object.
     D**********************************************************************
     P AirEmail_newMessage...
     P                 B                   EXPORT
     D AirEmail_newMessage...
     D                 PI                  like(MimeMessage)
     D  argUser                    1024A   const varying options(*NoPass:*omit)
     D  argPassword                1024A   const varying options(*NoPass:*omit)
     D  argHost                    1024A   const varying options(*NoPass:*omit)
     D  argProtocol                1024A   const varying options(*NoPass:*omit)
     D*
     D svDefaultHost   C                   CONST('smtp.example.com')
     D svDefaultProto  C                   CONST('smtp')
     D svSession       S                   like(Session)
     D                                     inz(*NULL)
     D svProp          S                   like(Properties)
     D                                     inz(*NULL)
     D svAuth          S                   like(Authenticator)
     D                                     inz(*NULL)
     D svMsg           S                   like(MimeMessage)
     D                                     inz(*NULL)
     D svPropKey       S                   like(jString)
     D svPropValue     S                   like(jString)
     D                                     inz(*NULL)
     D svDebug         S              1N
     D svHost          S           1024A
     D svUser          S           1024A
     D svPassword      S           1024A
     D svProtocol      S           1024A
      /free
         if %parms < 4;
           svProtocol = svDefaultProto;
         else;
           svProtocol = argProtocol;
         endif;
         if %parms < 3;
           svHost = svDefaultHost;
         else;
           svHost = argHost;
         endif;
         if %parms < 2;
           svPassword = *BLANKS;
         else;
           svPassword = argPassword;
         endif;
         if %parms < 1;
           svUser = *BLANKS;
         else;
           svUser = argUser;
         endif;
         svDebug = *ON;
         svProp = new_Properties();
         //----------------------------------------------------------------
         // User
         if (svUser = *BLANKS);
         else;
           svPropKey = new_String('mail.user');
           svPropValue = new_String(%Trim(svUser));
           Properties_setProperty(svProp: svPropKey: svPropValue);
         endif;
         // Password
         if (svPassword = *BLANKS);
         else;
           svPropKey = new_String('mail.password');
           svPropValue = new_String(%Trim(svPassword));
           Properties_setProperty(svProp: svPropKey: svPropValue);
         endif;
         // Transport Protocol
         svPropKey = new_String('mail.transport.protocol');
         svPropValue = new_String(%trim(svProtocol));
         Properties_setProperty(svProp: svPropKey: svPropValue);
         // Host: URL Location of the SMTP server
         svPropKey = new_String('mail.host');
         svPropValue = new_String(%trim(svHost));
         Properties_setProperty(svProp: svPropKey: svPropValue);
         // LocalHost: Required or HELO will fail
         svPropKey = new_String('mail.smtp.localhost');
         svPropValue = new_String('mail.example.com');
         Properties_setProperty(svProp: svPropKey: svPropValue);
         // Create the Session with the Properties
         // svAuth = *Null;
         svSession = Session_getDefaultInstance(svProp);
         Session_setDebug(svSession:svDebug);
         // Create the Message with the Session
         svMsg = new_MimeMessage(svSession);
         AirEmail_setFrom(svMsg:'TomSnyder@example.com');
         // Clean up
         freeLocalRef(svPropKey);
         freeLocalRef(svPropValue);
         freeLocalRef(svProp);
         //
         return svMsg;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_newInternetAddress(): Creates a New InternetAddress
     D**********************************************************************
     P AirEmail_newInternetAddress...
     P                 B                   EXPORT
     D AirEmail_newInternetAddress...
     D                 PI                  like(InternetAddress)
     D argAddress                 65535A   const varying
     D*
     D svAddress       S                   like(InternetAddress)
     D                                     inz(*NULL)
     D svString        S                   like(jString)
     D                                     inz(*NULL)
      /free
         svString = new_String(%trim(argAddress));
         svAddress = new_InternetAddress(svString);
         freeLocalRef(svString);
         return svAddress;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_newInternetAddressArray: Creates Object Array
     D**********************************************************************
     P AirEmail_newInternetAddressArray...
     P                 B                   EXPORT
     D AirEmail_newInternetAddressArray...
     D                 PI                  like(jobjectArray)
     D argSize                             like(jsize) VALUE
     D                                     options(*nopass)
     D*
     D size            S                   like(jsize)
     D addressClass    S                   like(jclass)
     D                                     inz(*NULL)
     D addressArray    S                   like(jobjectArray)
     D                                     inz(*NULL)
     D cd              DS                  likeDs(iconv_t)
     D ebcdicString    S           1024A
     D asciiAddress    S           1024A
     D toCCSID         S             10I 0
      /free
         if %parms < 1;
           size = 100;
         else;
           size = argSize;
         endif;
         if (JNIEnv_P = *NULL);
           JNIEnv_P = getJNIEnv();
         else;
         endif;
         // Create Conversion Descriptor for CCSID conversions
         toCCSID = 1208;
         cd = Air_openConverter(toCCSID);
         ebcdicString = 'javax/mail/internet/InternetAddress';
         asciiAddress = Air_convert(cd: %trim(ebcdicString));
         addressClass = FindClass(JNIEnv_P:
                             %trim(asciiAddress));
         if (Air_isJVMError());
           freeLocalRef(addressClass);
           Air_closeConverter(cd);
           return *NULL;
         else;
         endif;
         addressArray = NewObjectArray(JNIEnv_P:
                                   size:
                                   addressClass:
                                   *NULL);
         if (Air_isJVMError());
           freeLocalRef(addressClass);
           Air_closeConverter(cd);
           return *NULL;
         else;
         endif;
         // Clean Up
         Air_closeConverter(cd);
         freeLocalRef(addressClass);
         return addressArray;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_addInternetAddress: Adds an Object Array Element
     D*  Return: *ON = Success, *OFF = Failure
     D**********************************************************************
     P AirEmail_addInternetAddress...
     P                 B                   EXPORT
     D AirEmail_addInternetAddress...
     D                 PI             1N
     D argObjectArray                      like(jobjectArray)
     D argAddress                  1024A   varying value
     D*
     D svReturn        S              1N
     D size            S                   like(jsize)
     D index           S                   like(jsize)
     D i               S                   like(jsize)
     D cd              DS                  likeDs(iconv_t)
     D displayString   S             52A
     D ebcdicString    S           1024A
     D asciiAddress    S           1024A
     D toCCSID         S             10I 0
     D javaString      S                   like(jstring)
     D newElement      S                   like(InternetAddress)
     D arrayObject     S                   like(jobject)
      /free
         svReturn = *ON;
         if (JNIEnv_P = *NULL);
           JNIEnv_P = getJNIEnv();
         else;
         endif;
         if (argObjectArray = *NULL);
           return *OFF;
         else;
         endif;
         size = GetArrayLength(JNIEnv_P: argObjectArray);
         //displayString = 'Array Length: ' + %trim(%editc(index:'3'));
         //DSPLY displayString;
         // Look for next available index
         index = size;
         for i = 0 to size;
           arrayObject = GetObjectArrayElement(JNIEnv_P
                                               :argObjectArray:i);
           if (Air_isJVMError());
             leave;
           else;
             if (arrayObject = *NULL);
               index = i;
               leave;
             else;
             endif;
           endif;
         endfor;
         if (index >= size);
           svReturn = *OFF;
         else;
           javaString = new_String(%trim(argAddress));
           newElement = new_InternetAddress(javaString);
           SetObjectArrayElement(JNIEnv_P:
                               argObjectArray:
                               index:
                               newElement);
           if (Air_isJVMError());
             svReturn = *OFF;
           else;
           endif;
         endif;
         return svReturn;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_send()
     D**********************************************************************
     P AirEmail_send...
     P                 B                   EXPORT
     D AirEmail_send...
     D                 PI
     D  argMsg                             like(MimeMessage)
     D  argRecipients              1024A   dim(100) const
     D                                     varying
     D*
     D sendClass       S                   like(jclass)
     D sendId          S                   like(jMethodId)
     D cd              DS                  likeDs(iconv_t)
     D string          S           1024A
     D ebcdicString    S           1024A
     D asciiTransport  S           1024A
     D asciiSend       S           1024A
     D asciiSignature  S           1024A
     D displayString   S             52A
     D toCCSID         S             10I 0
     D i               S             10I 0
     D size            S             10I 0
     D elementCount    S             10I 0
     D recipients      S                   like(InternetAddressArray)
      /free
         if (JNIEnv_P = *NULL);
           JNIEnv_P = getJNIEnv();
         else;
         endif;
         // Before sending the email, push the addresses into
         // an InternetAddress Array that is the same size as the number
         // of elements.  Otherwise you will be sending NULL elements
         // which will cause an error.
         elementCount = %elem(argRecipients);
         size = *ZEROS;
         for i = 1 to elementCount;
           if (argRecipients(i) = *BLANKS);
           else;
             size = size + 1;
           endif;
         endfor;
         if (size = *ZEROS);
           return;
         else;
           recipients = AirEmail_newInternetAddressArray(size);
           for i = 1 to elementCount;
             if (argRecipients(i) = *BLANKS);
             else;
               AirEmail_addInternetAddress(recipients:argRecipients(i));
             endif;
           endfor;
         endif;
         // Create Conversion Descriptor for CCSID conversions
         // EBCDIC->ASCII conversion
         toCCSID = 1208;
         cd = Air_openConverter(toCCSID);
         ebcdicString = 'javax/mail/Transport';
         asciiTransport = Air_convert(cd: %trim(ebcdicString));
         ebcdicString = 'send';
         asciiSend = Air_convert(cd: %trim(ebcdicString));
         ebcdicString = '(Ljavax/mail/Message;'
                      + '[Ljavax/mail/Address;)V';
         asciiSignature = Air_convert(cd: %trim(ebcdicString));
         // Get the Transport_send Method and call it.
         sendClass = FindClass(JNIEnv_P:%trim(asciiTransport));
         if (Air_isJVMError());
           displayString = 'FindClass Error';
           DSPLY displayString;
         else;
         endif;
         // Get the STATIC send Method ID using the CLASS
         sendID = GetStaticMethodID(JNIENV_p:sendClass
                                   :%trim(asciiSend)
                                   :%trim(asciiSignature));
         if (Air_isJVMError());
           displayString = 'GetStaticMethodID Error';
           DSPLY displayString;
         else;
         endif;
         //----------------------------------------------------------------
         // SEND THE EMAIL!
         //----------------------------------------------------------------
         CallTransportSendMethod(JNIEnv_P:sendClass:
                                 sendID:argMsg:recipients);
         if (Air_isJVMError());
           displayString = 'TransportSend Error';
           DSPLY displayString;
         else;
         endif;
         // Clean Up
         Air_closeConverter(cd);
         freeLocalRef(sendClass);
         freeLocalRef(sendID);
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_setFrom()
     D**********************************************************************
     P AirEmail_setFrom...
     P                 B                   EXPORT
     D AirEmail_setFrom...
     D                 PI
     D   argMsg                            like(MimeMessage)
     D   argFromEmail              1024A   const varying
     D                                     options(*varsize)
     D*
     D svString        S                   like(jString)
     D svAddress       S                   like(InternetAddress)
      /free
         svAddress = AirEmail_newInternetAddress(%trim(argFromEmail));
         MimeMessage_setFrom(argMsg:svAddress);
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_setSubject()
     D**********************************************************************
     P AirEmail_setSubject...
     P                 B                   EXPORT
     D AirEmail_setSubject...
     D                 PI
     D   argMsg                            like(MimeMessage)
     D   argSubject                1024A   const varying
     D                                     options(*varsize)
     D*
     D svString        s                   like(jString)
      /free
         svString = new_String(%trim(argSubject));
         MimeMessage_setSubject(argMsg:svString);
         freeLocalRef(svString);
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_setText()
     D**********************************************************************
     P AirEmail_setText...
     P                 B                   EXPORT
     D AirEmail_setText...
     D                 PI
     D   argMsg                            like(MimeMessage)
     D   argText                  65535A   const varying
     D                                     options(*varsize)
     D*
     D svString        S                   like(jString)
     D svDate          S              8S 0
     D svTime          S              6S 0
      /free
        // Create a standard footer to identify user sending email
        // and concatenate it onto the end of the message automatically.
         svDate = %Dec(%Date():*ISO);
         svTime = %Dec(%Time():*ISO);
         svString = new_String(%trim(argText)
                             + X'0D25'
                             + 'This Email may contain confidential '
                             + ' information. '
                             + X'0D25'
                             + 'Yadda, Yadda, Yadda...'
                             + X'0D25'
                             + 'Please do not reply to this email. '
                             + X'0D25'
                             + 'Email sent by: '
                             + %trim(QCUSER)
                             + ' on ' + %editw(svDate:'    /  /  ')
                             + ' ' + %editw(svTime:'  :  :  '));
         MimeMessage_setText(argMsg:svString);
         freeLocalRef(svString);
      /end-free
     P                 E
     D**********************************************************************
     D* AirEmail_addAttachment()
     D**********************************************************************
     P AirEmail_addAttachment...
     P                 B                   EXPORT
     D AirEmail_addAttachment...
     D                 PI
     D  argMultipart                       like(MimeMultipart)
     D  argFileName               65535A   const varying
     D                                     options(*varsize)
     D  argType                     512A   const varying
     D                                     options(*varsize)
     D*
     D svBodyPart      S                   like(MimeBodyPart)
     D svDataSource    S                   like(FileDataSource)
     D svDataHandler   S                   like(DataHandler)
     D svDate          S              8S 0
     D svTime          S              6S 0
      /free
         svBodyPart = new_MimeBodyPart();
         svDataSource = new_FileDataSource(new_String(%trim(argFileName)));
         svDataHandler = new_DataHandler(svDataSource);
         MimeBodyPart_setDataHandler(svBodyPart: svDataHandler);
         MimeBodyPart_setHeader(svBodyPart
                           :new_String('Content-Type')
                           :new_String(%trim(argType)));
         MimeBodyPart_setDisposition(svBodyPart: new_String('attachment'));
         MimeBodyPart_setHeader(svBodyPart
                           :new_String('Content-ID')
                           :new_String('<attach1>'));
         MimeBodyPart_setFileName(svBodyPart
                           :new_String(%trim(argFileName)));
         MimeMultiPart_addBodyPart(argMultiPart: svBodyPart);
         freeLocalRef(svBodyPart);
         freeLocalRef(svDataHandler);
         freeLocalRef(svDataSource);
      /end-free
     P                 E
     D**********************************************************************
     D*  AirEmail_addHTML()
     D**********************************************************************
     P AirEmail_addHTML...
     P                 B                   EXPORT
     D AirEmail_addHTML...
     D                 PI
     D  argMultipart                       like(MimeMultipart)
     D  argHTML                   65535A   const varying
     D                                     options(*varsize)
     D  argFooter                     1N   const options(*nopass)
     D*
     D svString        S                   like(jString)
     D svDate          S              8S 0
     D svTime          S              6S 0
     D svFooter        S              1N
     D svBodyPart      S                   like(MimeBodyPart)
      /free
        // Create a standard footer to identify user sending email
        // and concatenate it onto the end of the message automatically.
        if %parms > 2;
          eval svFooter = argFooter;
        else;
          eval svFooter = *OFF;
        endif;
        if svFooter;
          svDate = %Dec(%Date():*ISO);
          svTime = %Dec(%Time():*ISO);
          svString = new_String(%trim(argHTML)
                             + '<br>'
                             + 'This Email may contain confidential '
                             + ' information.<br>'
                             + 'Yadda, Yadda, Yadda...<br>'
                             + 'Please do not reply to this email.<br>'
                             + 'Email sent by: '
                             + %trim(QCUSER)
                             + ' on ' + %editw(svDate:'    /  /  ')
                             + ' ' + %editw(svTime:'  :  :  '));
        else;
          svString = new_String(%trim(argHTML));
        endif;
        svBodyPart = new_MimeBodyPart();
        MimeBodyPart_setContent(svBodyPart: svString:
                                new_String('text/html'));
        MimeMultiPart_addBodyPart(argMultipart: svBodyPart);
        freeLocalRef(svBodyPart);
        freeLocalRef(svString);
      /end-free
     P                 E
