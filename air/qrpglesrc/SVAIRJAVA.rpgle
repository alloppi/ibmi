     H THREAD(*SERIALIZE) OPTION(*NODEBUGIO: *SRCSTMT: *SHOWCPY)
     D**********************************************************************
     D* Generic Java Service Program
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
     D* Thank you for purchasing my Book! Happy Coding! Tom Snyder
     D**********************************************************************
     D* February 4, 2010: Version 2.0
     D* - Created New getJNIEnv2 for intended use with V5R2
     D* - Added Air_getSystemProperty procedure to determine version
     D*   and classpath of JVM.
     D* - Added getClassPath procedure
     D**********************************************************************
     D* V5R2 Notes (Not Neccessary for V5R3 or Better):
     D* - You may need to rename "getJNIEnv" -> "getJNIEnvOriginal"
     D*   AND rename "getJNIEnv2" -> "getJNIEnv"
     D*   Don't forget to do this in both SPAIRJAVA and SVAIRJAVA
     D*   This will use getJNIEnv2 to replace getJNIEnv
     D* - When you use getJNIEnv2, it specifies JNI_VERSION_1_6
     D*   which forces the use of the
     D*   /QIBM/UserData/Java400/SystemDefault.properties file
     D*   to determine the version of Java to use.  A sample is provided
     D*   with the zip file.  You may need to change to match your desired
     D*   version.  The open source technologies used require
     D*   1.4.2 or better.
     D* - The intended ADDENVVAR ENVVAR(CLASSPATH) command may not work
     D*   to add the class path.  You have two alternatives:
     D*      ~ Put the jar files in the /QIBM/UserData/Java400/ext folder.
     D*      ~ Put the classpath in the SystemDefault.properties file
     D*        An example SystemDefaultPOI.properties file is also included
     D*        in the zip file.  Rename to SystemDefault.properties if you
     D*        intend to use it.
     D**********************************************************************
     D* Some common Methods can be found in
     D*  IBM ILE RPG Programmer's Guide SC09-2507-06
     D**********************************************************************
     D* The logic used can be found in the JNI Specifications
     D*  on the Sun Microsystems  Website
     D* http://java.sun.com/j2se/1.4.2/docs/guide/jni/spec/jniTOC.html
     D**********************************************************************
     D*   HOW TO COMPILE: (Make Sure SVAIRFUNC is Created First)
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(YourLib/SVAIRJAVA) SRCFILE(YourLib/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE SERVICE PROGRAM)
     D*   CRTSRVPGM SRVPGM(YourLib/SVAIRJAVA) EXPORT(*ALL)
     D*     BNDSRVPGM(SVAIRFUNC) ACTGRP(SVAIRJAVA)
     D**********************************************************************
     D localPath       S           2048A   varying
     D commandString   S           2048A   varying
     D displayBytes    S             52A
     D*** PROTOTYPES ***
     D/COPY AIRSRC,SPAIRFUNC
     D/COPY AIRSRC,SPAIRJAVA
     D/COPY QSYSINC/QRPGLESRC,JNI
     C**********************************************************************
     C* THE MAIN PROCEDURE IS USED TO SET UP THE JAVA ENVIRONMENT.
     C**********************************************************************
      /free
       //----------------------------------
       //---      POI for Excel         ---
       //----------------------------------
       localPath = '/javaapps/poi-3.14'
                 + '/poi-3.14-20160307.jar';
       //----------------------------------
       //---      iText for PDF         ---
       //----------------------------------
       localPath = %TRIM(localPath)
                 + ':/javaapps/itext-2.1.7/lib'
                 + '/itext-2.1.7.jar';
       //----------------------------------------
       // JAF - JavaBeans Activation Framework
       // JAF and JavaMail for Email
       //----------------------------------------
       localPath = %TRIM(localPath)
                 + ':/javaapps/JavaMail'
                 + '/activation.jar';
       localPath = %trim(localPath)
                 + ':/javaapps/JavaMail'
                 + '/mail.jar';
       //------------------------------------------------------
       // Put the entire classpath together and implement.
       //------------------------------------------------------
       commandString = 'ADDENVVAR ENVVAR(CLASSPATH) '
                     + 'VALUE(''.:'
                     + %TRIM(localPath)
                     + ''') REPLACE(*YES)';
       monitor;
         ExecuteCommand(%trim(commandString):%len(%trim(commandString)));
       on-error;
         displayBytes = 'ERROR occurred on Class Path!';
         DSPLY displayBytes;
       endmon;
       // Call getJNIEnv() to:
       // - Ensure First Three File Descriptors are open
       // - Start JVM, if not started
       // - Attach to JVM, if already started
       getJNIEnv();
       // Java Version
       displayBytes = 'Java Version: '
                    + Air_getSystemProperty('java.version');
       DSPLY displayBytes;
       // Java Class Path
       commandString = Air_getSystemProperty('java.class.path');
       displayBytes = 'Java ClassPath: '
                    + %trim(commandString);
       DSPLY displayBytes;
       return;
      /end-free
     P******************************************************************
     P*  getJNIEnv2
     P******************************************************************
     P* February 4, 2010: Version 2.0
     P* Derived from: Websphere Development Studio
     P*               ILE RPG Programmer's Guide
     P*               Version 5, SC09-2507-06
     P* Specifying JNI_VERSION_1_6 forces V5R2 to use
     P* /QIBM/UserData/Java400/SystemDefault.properties file to
     P* determine the java version.
     P* Create the file to contain the following line
     P* "java.version=1.4.2" (Without the quotes)
     P* Change to match desired java version
     P* A sample SystemDefault.properties file is included with the zip.
     P******************************************************************
     P getJNIEnv2...
     P                 B                   EXPORT
     D getJNIEnv2...
     D                 PI              *
     D  argOptions                65535A   const varying options(*nopass)
     D svOptions       s          65535A   varying
     D svDelimit       s              1A
     D svPos           s             10I 0
     D svNextPos       s             10I 0
     D inputOpts       s          65535A   varying
     D rc              s                   LIKE(jint)
     D jvm             s                   like(JavaVM_p) dim(1)
     D env             s                   like(JNIENV_p) inz(*null)
     D bufLen          s                   like(jsize) INZ(%elem(jvm))
     D nVMs            s                   like(jsize)
     D attachArgs      DS                  likeDs(JavaVMAttachArgs)
     D initArgs        DS                  likeDs(JavaVMInitArgs)
     D options         DS                  likeDs(JavaVMOption) occurs(10)
     D fd              s             10I 0
     D pOptions        s               *   inz(%addr(options))
     D inputOptsPtr    s               *
     D classPath       s          65535A   varying
     D cd              DS                  likeDs(iconv_t)
     D toCCSID         S             10I 0
     D prefix          S           1000A   varying
     D len             S             10I 0
      /free
        //-----------------------------------------------------------
        // First, ensure STDIN, STDOUT, and STDERR are open
        //-----------------------------------------------------------
        fd = IFSOpen('/dev/null': O_RDWR);
        if (fd = -1);
           // '/dev/null' does not exist in your IFS
           // Create it, or use another known good file.
        else;
          dow ( fd < 2 );
            fd = IFSOpen('/dev/null': O_RDWR);
          enddo;
        endif;

        //-----------------------------------------------------------
        // Second, Attach to existing JVM; if possible.
        //-----------------------------------------------------------
        rc = JNI_GetCreatedJavaVMs(jvm:bufLen:nVMs);
        if (rc = 0 and nVMs > 0);
           JavaVM_P = jvm(1);
           attachArgs = *ALLX'00';
           attachArgs.version = JNI_VERSION_1_6;
           rc = AttachCurrentThread(jvm(1):env:%addr(attachArgs));
        else;
        //-----------------------------------------------------------
        // First Time, Create new JVM
        //-----------------------------------------------------------
           // Create Conversion Descriptor for CCSID conversions
           toCCSID = 1208;
           cd = Air_openConverter(toCCSID);
           initArgs = *ALLX'00';
           rc = JNI_GetDefaultJavaVMInitArgs(%addr(initArgs));
           initArgs.version = JNI_VERSION_1_6;
           classPath = getClasspath();
           if (%len(classPath) > 0);
             initArgs.nOptions = initArgs.nOptions + 1;
             %occur(options) = initArgs.nOptions;
             options = *allX'00';
             prefix = '-Djava.class.path=:';
             len = %len(prefix) + %len(classPath) + 1;
             options.optionString = %alloc(len);
             %str(options.optionString: len) =
                         Air_convert(cd: %trim(prefix));
           endif;
           if %parms > 0;
             svOptions = %trim(argOptions);
           else;
             svOptions = *BLANKS;
           endif;
        //-----------------------------------------------------------
        // If JVM options have been specified, then tokenize and
        // pass them in the initArgs when starting the JVM
        //-----------------------------------------------------------
           if %len(%trim(svOptions)) > 0;
             // Last Character WILL contain the delimiter.
             inputOpts = *allX'00';
             inputOpts = Air_convert(cd: %trim(svOptions));
             svDelimit = %subst(inputOpts:%len(inputOpts):1);
             inputOptsPtr = %addr(inputOpts) + 2;
             svPos = 1;
             dow svPos <= %len(inputOpts);
               svNextPos = %scan(svDelimit: inputOpts: svPos);
               %subst(inputOpts: svNextPos: 1) = X'00';
               initArgs.nOptions = initArgs.nOptions + 1;
               %occur(options) = initArgs.nOptions;
               options = *allX'00';
               options.optionString = inputOptsPtr + svPos - 1;
               svPos = svNextPos + 1;
             enddo;
           else;
           endif;
           Air_closeConverter(cd);
           if initArgs.nOptions > 0;
             initArgs.options = pOptions;
           endif;
           rc = JNI_CreateJavaVM(jvm(1):env:%addr(initArgs));
        endif;
        if (rc = 0);
          return env;
        else;
          return *NULL;
        endif;
      /end-free
     P                 E
     P******************************************************************
     P*  getJNIEnv (Original).  Simple JVM start in book
     P******************************************************************
     P* February 4, 2010: Version 2.0
     P* Derived from: Websphere Development Studio
     P*               ILE RPG Programmer's Guide
     P*               Version 5, SC09-2507-03
     P* Changed JNI_GetDefaultJavaVMInitArgs(%addr(initArgs));
     P* - originally contained attachArgs in parameter.
     P* - Simpler version that works on V5R3 and better.
     P* - May not work with V5R2
     P* - Originally used to keep the code simpler, but needed to be
     P*   changed to accomodate usage on V5R2.
     P******************************************************************
     P getJNIEnv...
     P                 B                   EXPORT
     D getJNIEnv...
     D                 PI              *
     D rc              s                   LIKE(jint)
     D jvm             s               *   DIM(1)
     D env             s               *
     D bufLen          s                   LIKE(jsize) INZ(%elem(jvm))
     D nVMs            s                   LIKE(jsize)
     D initArgs        DS                  LIKEDS(JDK1_1InitArgs)
     D attachArgs      DS                  LIKEDS(JDK1_1AttachArgs)
     D fd              s             10I 0
      /free
        // First, ensure STDIN, STDOUT, and STDERR are open
        fd = IFSOpen('/dev/null': O_RDWR);
        if (fd = -1);
           // '/dev/null' does not exist in your IFS
           // Create it, or use another known good file.
        else;
          dow ( fd < 2 );
            fd = IFSOpen('/dev/null': O_RDWR);
          enddo;
        endif;

        // Second, Attach to existing JVM
        //      OR Create new JVM if not already running
        rc = JNI_GetCreatedJavaVMs(jvm:bufLen:nVMs);
        if (rc = 0 and nVMs > 0);
           attachArgs = *ALLX'00';
           JavaVM_P = jvm(1);
           rc = AttachCurrentThread(jvm(1):env:%addr(attachArgs));
        else;
           initArgs = *ALLX'00';
           rc = JNI_GetDefaultJavaVMInitArgs(%addr(initArgs));
           if (rc = 0);
             rc = JNI_CreateJavaVM(jvm(1):env:%addr(initArgs));
           else;
           endif;
        endif;
        if (rc = 0);
          return env;
        else;
          return *NULL;
        endif;
      /end-free
     P                 E
     P******************************************************************
     P* destroyJVM
     P******************************************************************
     P destroyJVM      B                   EXPORT
     D destroyJVM      PI              N
     D jvm             s                   like(JavaVM_p) dim(1)
     D nVMs            s                   like(jSize)
     D rc              s             10I 0
      /free
        monitor;
          rc = JNI_GetCreatedJavaVMs(jvm:1:nVMs);
          if (rc = 0 AND nVMs > 0);
            JavaVM_P = jvm(1);
            rc = DestroyJavaVM(jvm(1));
            if (rc = 0);
              return *ON;
            else;
            endif;
          else;
          endif;
        on-error;
        endmon;
        return *OFF;
      /end-free
     P                 E
     P******************************************************************
     P*  freeLocalRef(Ref)
     P******************************************************************
     P freeLocalRef...
     P                 B                   EXPORT
     D freeLocalRef...
     D                 PI
     D    inRefObject                      like(jobject)
     D env             s               *   static inz(*null)
      /free
          if (env = *NULL);
              env = getJNIEnv();
          else;
          endif;

          JNIENV_P = env;
          DeleteLocalRef(env: inRefObject);
      /end-free
     P                 E
     P*******************************************************************
     P* beginObjectGroup creates a new group of object references
     P*    on the stack that can be released all at once
     P*******************************************************************
     P beginObjectGroup...
     P                 B                   EXPORT
     D beginObjectGroup...
     D                 PI            10I 0
     D inCapacity                    10I 0 value options(*nopass)
     D*
     D env             s               *
     D rc              s             10I 0
     D capacity        s             10I 0 inz(100)
      /free
       if (%parms >= 1);
         capacity = inCapacity;
       else;
       endif;
       env = getJNIEnv();
       if (env = *NULL);
           return JNI_ERR;
       else;
       endif;

       JNIENV_p = env;
       rc = PushLocalFrame(JNIENV_p : capacity);
       if  (rc <> 0);
           return JNI_ERR;
       else;
       endif;
       return JNI_OK;
      /end-free
     P                 E
     P*******************************************************************
     P* endObjectGroup   releases a group of object references
     P*******************************************************************
     P endObjectGroup...
     P                 B                   EXPORT
     D endObjectGroup...
     D                 PI            10I 0
     D   inRefObject                       like(jObject) const
     D                                     options(*nopass)
     D   outNewObject                      like(jObject)
     D                                     options(*nopass)
     D refObject       s                   like(jObject) inz(*NULL)
     D newObject       s                   like(jObject)
      /free
          JNIENV_p = getJNIEnv();
          if (JNIENV_p = *NULL);
              return JNI_ERR;
          endif;

          if %parms >= 1;
              refObject = inRefObject;
          else;
          endif;

          newObject = PopLocalFrame (JNIENV_p: refObject);

          if %parms >= 2;
              outNewObject = newObject;
          else;
          endif;

          return JNI_OK;
      /end-free
     P                 E
     P*******************************************************************
     P*  getClassPath
     P*******************************************************************
     P getClassPath    B                   EXPORT
     D getClassPath    PI         65535A   varying
     D Qp0zGetEnvNoInit...
     D                 PR              *   extproc('Qp0zGetEnvNoInit')
     D   name                          *   value options(*string)
     D envVarP         s               *
      /free
        envvarP = Qp0zGetEnvNoInit('CLASSPATH');
        if (envvarP = *NULL);
          return '';
        else;
          return %str(envvarP: 65535);
        endif;
      /end-free
     P                 E
     P******************************************************************
     P* Float_toAlpha converts a Float number to a String
     P******************************************************************
     P Float_toAlpha...
     P                 B                   EXPORT
     D Float_toAlpha...
     D                 PI          1024A   varying
     D  argFloat                           like(Float)
     D*
     D outWS           DS
     D  outText                    1024A
     D  tempString     S                   like(jstring)
      /free
          outText = *ZEROS;
          if (argFloat = *NULL);
          else;
            tempString = Float_toString(argFloat);
            outText = String_getBytes(tempString);
            outText = %Trim(outText);
          endif;
      /end-free
     C                   RETURN    outText
     P                 E
     P******************************************************************
     P* Air_isJVMError(): Indicates Throwable Exception Found
     P******************************************************************
     P Air_isJVMError  B                   EXPORT
     D Air_isJVMError  PI             1N
     D svReturn        S              1N
     D svThrowable     S                   like(jthrowable)
     D svString        S                   like(jstring)
     D svMessage       S             52A
      /free
         svReturn = *OFF;
         if (JNIEnv_P = *NULL);
           JNIEnv_P = getJNIEnv();
         else;
         endif;
         svThrowable = ExceptionOccurred(JNIEnv_P);
         if (svThrowable = *NULL);
         else;
           svReturn = *ON;
           svString = Exception_toString(svThrowable);
           svMessage = String_getBytes(svString);
           dsply svMessage;
           ExceptionClear(JNIEnv_P);
         endif;
         freeLocalRef(svThrowable);
         freeLocalRef(svString);
         return svReturn;
      /end-free
     P                 E
      ******************************************************************
      * Air_getDateBytes(): Gets a user friendly string of bytes
      * for displaying the date and time.
      ******************************************************************
     P Air_getDateBytes...
     P                 B                   EXPORT
     D Air_getDateBytes...
     D                 PI           512A   varying
     D  argDate                            like(JavaDate)
     D  argDateFormat                      like(jInt) value
     D  argTimeFormat                      like(jInt) value
     D svDateFormat    S                   like(DateFormat)
     D svString        S                   like(jString)
     D svBytes         S            512A   varying
      /free
       svDateFormat = DateFormat_getDateTimeInstance(
                        argDateFormat: argTimeFormat);
       svString = DateFormat_format(svDateFormat: argDate);
       svBytes = String_getBytes(svString);
       freeLocalRef(svDateFormat);
       freeLocalRef(svString);
       return svBytes;
      /end-free
     P                 E
     P******************************************************************
     P* Air_getHashMapIterator(): Gets the Iterator object from the
     P* specified HashMap
     P******************************************************************
     P Air_getHashMapIterator...
     P                 B                   EXPORT
     D Air_getHashMapIterator...
     D                 PI                  like(Iterator)
     D  argHashMap                         like(HashMap)
     D svIterator      S                   like(Iterator)
     D                                     inz(*NULL)
      /free
       return Set_iterator(HashMap_keySet(argHashMap));
      /end-free
     P                 E
     P******************************************************************
     P* Air_getIteratorNextBytes(): Casts the Iterator.next to Bytes
     P******************************************************************
     P Air_getIteratorNextBytes...
     P                 B                   EXPORT
     D Air_getIteratorNextBytes...
     D                 PI         65535A   varying
     D  argIterator                        like(Iterator)
     D svBytes         S          65535A   varying
     D svResult        S                   like(jString)
      /free
       svResult = Iterator_next(argIterator);
       svBytes = String_getBytes(svResult);
       return svBytes;
      /end-free
     P                 E
     P******************************************************************
     P* Air_getHashMapBytes(): Casts the HashMap.get(key) to Bytes
     P******************************************************************
     P Air_getHashMapBytes...
     P                 B                   EXPORT
     D Air_getHashMapBytes...
     D                 PI         65535A   varying
     D  argHashMap                         like(HashMap)
     D  argBytes                  65535A   const varying options(*varsize)
     D svString        S                   like(jString)
     D svResult        S                   like(jString)
     D svBytes         S          65535A   varying
      /free
       svString = new_String(%trim(argBytes));
       svResult = HashMap_get(argHashMap: svString);
       svBytes = String_getBytes(svResult);
       return svBytes;
      /end-free
     P                 E
      ******************************************************************
      * Air_getColorFromHex(): Gets a Color using the HTML Hex Colors
      * Uses 6 character HTML Hex Codes, refer to CONSTANTS
      ******************************************************************
     P Air_getColorFromHex...
     P                 B                   EXPORT
     D Air_getColorFromHex...
     D                 PI                  like(JavaColor)
     D  argHexColor                   6A   const
     D svString        S                   like(jString)
     D svColor         S                   like(JavaColor)
     D                                     inz(*NULL)
     D svRadix         S                   like(jInt) inz(16)
      /free
       svString = new_String(%trim(argHexColor));
         svColor = new_Color(Integer_parseIntWithRadix(svString: svRadix));
       freeLocalRef(svString);
       return svColor;
      /end-free
     P                 E
     P******************************************************************
     P* Air_getSystemProperty(): Gets the System.getProperty
     P******************************************************************
     P Air_getSystemProperty...
     P                 B                   EXPORT
     D Air_getSystemProperty...
     D                 PI         65535A   varying
     D  argBytes                  65535A   const varying options(*varsize)
     D svString        S                   like(jString)
     D svResult        S                   like(jString)
     D svBytes         S          65535A   varying
      /free
       svString = new_String(%trim(argBytes));
       svResult = System_getProperty(svString);
       svBytes = String_getBytes(svResult);
       return svBytes;
      /end-free
     P                 E
