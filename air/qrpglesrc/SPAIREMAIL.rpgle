      /if not defined(SPAIREMAIL)
     D**********************************************************************
     D* JavaMail Prototypes
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
     D* THE CRTSQLRPGI COMMAND DOES NOT ALLOW A COPY INSIDE OF A COPY
     D* IT WILL GIVE YOU A NEST COPY NOT ALLOWED ERROR
     D*/copy QSYSINC/QRPGLESRC,JNI
     D**********************************************************************
     D* JavaMail Objects
     D**********************************************************************
     D Session...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail-
     D                                     .Session')
     D Message...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail-
     D                                     .Message')
     D MimeMessage...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.internet-
     D                                     .MimeMessage')
     D Multipart...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.Multipart')
     D MimeMultipart...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.internet-
     D                                     .MimeMultipart')
     D BodyPart...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.BodyPart')
     D MimeBodyPart...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.internet-
     D                                     .MimeBodyPart')
     D Transport...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail-
     D                                     .Transport')
     D Address...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail-
     D                                     .Address')
     D AddressArray...
     D                 S               O   CLASS(*JAVA
     D                                     :'[javax.mail-
     D                                     .Address')
     D InternetAddress...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.internet-
     D                                     .InternetAddress')
     D InternetAddressArray...
     D                 S               O   CLASS(*JAVA
     D                                     :'[javax.mail.internet-
     D                                     .InternetAddress')
     D Authenticator...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail-
     D                                     .Authenticator')
     D RecipientType...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.mail.Message-
     D                                     .RecipientType')
     D**********************************************************************
     D* Prototype Wrappers for Constructors
     D**********************************************************************
     D new_MimeMessage...
     D                 PR                  Like(MimeMessage)
     D                                     ExtProc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     *CONSTRUCTOR)
     D  argSession                         Like(Session)
     D*
     D new_MimeMultipart...
     D                 PR                  Like(MimeMultipart)
     D                                     ExtProc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMultipart':
     D                                     *CONSTRUCTOR)
     D  argSubType                         Like(jString) const
     D* Default Constructor
     D new_MimeBodyPart...
     D                 PR                  Like(MimeBodyPart)
     D                                     ExtProc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     *CONSTRUCTOR)
     D*
     D new_InternetAddress...
     D                 PR                  Like(InternetAddress)
     D                                     ExtProc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .InternetAddress':
     D                                     *CONSTRUCTOR)
     D  argString                          Like(jstring) Const
     D**********************************************************************
     D* Prototype Wrappers for Methods
     D**********************************************************************
     D Session_getDefaultInstance...
     D                 PR                  Like(Session)
     D                                     extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Session':
     D                                     'getDefaultInstance')
     D                                     static
     D  argProps                           Like(Properties)
     D*
     D Session_setDebug...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Session':
     D                                     'setDebug')
     D  argBool                       1N   VALUE
     D*
     D Session_getTransport...
     D                 PR                  like(Transport)
     D                                     extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Session':
     D                                     'getTransport')
     D*
     D Transport_connect...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Transport':
     D                                     'connect')
     D  argUser                            Like(jstring)
     D  argPassword                        Like(jstring)
     D*
     D Transport_send...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Transport':
     D                                     'send')
     D                                     static
     D  argMsg                             like(Message)
     D  argRecipients                      like(AddressArray)
     D*
     D Transport_sendMessage...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Transport':
     D                                     'sendMessage')
     D  argMsg                             like(Message)
     D  argRecipients                      like(InternetAddressArray)
     D*
     D Transport_close...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail-
     D                                     .Transport':
     D                                     'close')
     D*
     D MimeMessage_setFrom...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     'setFrom')
     D  argAddress                         Like(Address)
     D*
     D MimeMessage_setSubject...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     'setSubject')
     D  argString                          Like(jstring)
     D*
     D MimeMessage_getSubject...
     D                 PR                  Like(jString)
     D                                     extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     'getSubject')
     D*
     D MimeMessage_setText...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     'setText')
     D  argString                          Like(jstring)
     D*
     D MimeMessage_setContent...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMessage':
     D                                     'setContent')
     D  argMultiPart                       Like(Multipart)
     D*
     D MimeBodyPart_setContent...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     'setContent')
     D  argObject                          Like(jObject) const
     D  argType                            Like(jString) const
     D*
     D MimeBodyPart_setDataHandler...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     'setDataHandler')
     D  argHandler                         like(DataHandler)
     D*
     D MimeBodyPart_setHeader...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     'setHeader')
     D  argName                            like(jString) const
     D  argValue                           like(jString) const
     D*
     D MimeBodyPart_setDisposition...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     'setDisposition')
     D  argDisp                            like(jString) const
     D*
     D MimeBodyPart_setFileName...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeBodyPart':
     D                                     'setFileName')
     D  argFileName                        like(jString) const
     D*
     D MimeMultiPart_addBodyPart...
     D                 PR                  extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .MimeMultipart':
     D                                     'addBodyPart')
     D  argBodyPart                        Like(BodyPart)
     D*
     D InternetAddress_getAddress...
     D                 PR                  like(jString)
     D                                     extproc(*JAVA:
     D                                     'javax.mail.internet-
     D                                     .InternetAddress':
     D                                     'getAddress')
     D*
     D* USE JNI to call Transport.send
     D CallTransportSendMethod...
     D                 PR                  ExtProc(*CWIDEN:
     D                                      JNINativeInterface.
     D                                      CallStaticVoidMethod_P)
     D  argEnv                             Like(JNIEnv_P) value
     D  argClass                           Like(jclass) value
     D  argMethodId                        Like(jmethodID) value
     D  argMsg                             Like(MimeMessage) value
     D  argRecipients                      Like(InternetAddressArray) value
     D  argDummy                      1A   Options(*NoPass)
     D**********************************************************************
     D* Internal Prototype Wrappers
     D* These are customized RPG code wrappers.
     D* These procedures do more than just provide the interface.
     D* Additional objectives include:
     D* - Providing RPG style arguments for easy implementation
     D* - Validation and Exception Handling
     D* - Assigning default values to reduce code complexity
     D**********************************************************************
     D AirEmail_newMessage...
     D                 PR                  like(MimeMessage)
     D   argUser                   1024A   const varying options(*NoPass:*omit)
     D   argPassword               1024A   const varying options(*NoPass:*omit)
     D   argHost                   1024A   const varying options(*NoPass:*omit)
     D   argProtocol               1024A   const varying options(*NoPass:*omit)
     D*
     D AirEmail_newInternetAddress...
     D                 PR                  like(InternetAddress)
     D   argAddress               65535A   const varying
     D*
     D AirEmail_newInternetAddressArray...
     D                 PR                  like(jobjectArray)
     D argSize                             like(jsize) value
     D                                     options(*nopass)
     D*
     D AirEmail_addInternetAddress...
     D                 PR             1N
     D argObjectArray                      like(jobjectArray)
     D argAddress                  1024A   varying value
     D*
     D AirEmail_send...
     D                 PR
     D  argMsg                             like(MimeMessage)
     D  argRecipients              1024A   dim(100) const
     D                                     varying
     D*
     D AirEmail_setFrom...
     D                 PR
     D  argMsg                             like(MimeMessage)
     D  argFromEmail               1024A   const varying
     D                                     options(*varsize)
     D*
     D AirEmail_setSubject...
     D                 PR
     D   argMsg                            like(MimeMessage)
     D   argSubject                1024A   const varying
     D                                     options(*varsize)
     D*
     D AirEmail_setText...
     D                 PR
     D   argMsg                            like(MimeMessage)
     D   argText                  65535A   const varying
     D                                     options(*varsize)
     D*
     D AirEmail_addHTML...
     D                 PR
     D  argMultipart                       like(MimeMultipart)
     D  argHTML                   65535A   const varying
     D                                     options(*varsize)
     D  argFooter                     1N   const options(*nopass)
     D*
     D AirEmail_addAttachment...
     D                 PR
     D  argMultipart                       like(MimeMultipart)
     D  argFileName               65535A   const varying
     D                                     options(*varsize)
     D  argType                     512A   const varying
     D                                     options(*varsize)
     D*
      /define SPAIREMAIL
      /endif
