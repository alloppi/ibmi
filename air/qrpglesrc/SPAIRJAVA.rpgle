      /if not defined(SPAIRJAVA)
      /define OS400_JVM_12
     D**********************************************************************
     D* Generic Java Prototypes and Constants
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
     D* THE CRTSQLRPGI COMMAND DOES NOT ALLOW A COPY INSIDE OF A COPY
     D* IT WILL GIVE YOU A NEST COPY NOT ALLOWED ERROR
     D* BUT IT WORKS JUST FINE FOR CRTRPGMOD.........
     D* SO, YOU HAVE TO PUT THIS INTO EVERY PROGRAM THAT USES IT.
     D*/copy QSYSINC/QRPGLESRC,JNI
     D**********************************************************************
     D JavaServiceProgram...
     D                 PR                  extProc('SVAIRJAVA')
     D**********************************************************************
     D* Common Java Classes NOT defined in QSYSINC/QRPGLESRC,JNI
     D**********************************************************************
     D*
     D Float...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.lang.Float')
     D FileInputStream...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.io.FileInputStream')
     D FileOutputStream...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.io.FileOutputStream')
     D InputStream...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.io.InputStream')
     D OutputStream...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.io.OutputStream')
     D List...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.List')
     D ArrayList...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.ArrayList')
     D HashMap...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.HashMap')
     D Iterator...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.Iterator')
     D Rectangle       S               O   CLASS(*JAVA
     D                                     :'java.awt.Rectangle')
     D BigDecimal      S               O   CLASS(*JAVA:
     D                                     'java.math.BigDecimal')
     D JavaInteger...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.lang.Integer')
     D JavaColor...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.awt.Color')
     D JavaSet...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.Set')
     D JavaDate...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.util.Date')
     D*
     D HashMap_keySet...
     D                 PR                  like(JavaSet)
     D                                     ExtProc(*JAVA
     D                                     :'java.util.HashMap'
     D                                     :'keySet')
     D*
     D HashMap_get...
     D                 PR                  like(jObject)
     D                                     ExtProc(*JAVA
     D                                     :'java.util.HashMap'
     D                                     :'get')
     D  argObject                          like(jObject) const
     D*
     D Set_iterator...
     D                 PR                  like(Iterator)
     D                                     ExtProc(*JAVA
     D                                     :'java.util.Set'
     D                                     :'iterator')
     D*
     D Iterator_hasNext...
     D                 PR             1N
     D                                     ExtProc(*JAVA
     D                                     :'java.util.Iterator'
     D                                     :'hasNext')
     D*
     D Iterator_next...
     D                 PR                  like(jObject)
     D                                     ExtProc(*JAVA
     D                                     :'java.util.Iterator'
     D                                     :'next')
     D*
     D DateFormat...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.text.DateFormat')
     D Properties      S               O   CLASS(*JAVA:
     D                                     'java.util.Properties')
     D**********************************************************************
     D* javax.activation JavaBeans Activation Framework API
     D**********************************************************************
     D DataSource...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.activation.DataSource')
     D FileDataSource...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.activation.FileDataSource')
     D DataHandler...
     D                 S               O   CLASS(*JAVA
     D                                     :'javax.activation.DataHandler')
     D**********************************************************************
     D* Local Prototypes for...
     D* SVAIRJAVA Service Program
     D**********************************************************************
     D getJNIEnv2...
     D                 PR              *
     D  argOptions                65535A   const varying options(*nopass)
     D* Original Simple getJNIEnv...
     D getJNIEnv...
     D                 PR              *
     D*
     D freeLocalRef...
     D                 PR
     D    peRef                            like(jobject)
     D*
     D beginObjectGroup...
     D                 PR            10I 0
     D argCapacity                   10I 0 value options(*nopass)
     D*
     D endObjectGroup...
     D                 PR            10I 0
     D argRefObject                        like(jObject) const
     D                                     options(*nopass)
     D argNewObject                        like(jObject)
     D                                     options(*nopass)
     D*
     D destroyJVM      PR              N
     D*
     D getClassPath    PR         65535A   varying
     D**********************************************************************
     D* External Prototype Wrappers for...
     D* Common Java Constructors
     D**********************************************************************
     D new_String      PR                  like(jstring)
     D                                     EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D argBytes                   65535A   VARYING const
     D* 65,535 is the maximum RPG field length.
     D new_Properties  PR                  ExtProc(*JAVA
     D                                     :'java.util.Properties'
     D                                     :*CONSTRUCTOR)
     D                                     like(Properties)
     D*
     D new_BigDecimal  PR                  ExtProc(*JAVA
     D                                     :'java.math.BigDecimal'
     D                                     :*CONSTRUCTOR)
     D                                     like(BigDecimal)
     D  argString                          like(jstring) const
     D*
     D new_BigDecimalFromDouble...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.math.BigDecimal'
     D                                     :*CONSTRUCTOR)
     D                                     like(BigDecimal)
     D  argDouble                          like(jdouble) value
     D*
     D new_Color...
     D                 PR                  like(JavaColor)
     D                                     ExtProc(*JAVA
     D                                     :'java.awt.Color'
     D                                     :*CONSTRUCTOR)
     D  argInt                             like(jInt) value
     D*
     D new_Date...
     D                 PR                  like(JavaDate)
     D                                     ExtProc(*JAVA
     D                                     :'java.util.Date'
     D                                     :*CONSTRUCTOR)
     D*
     D new_FileInputStream...
     D                 PR                  like(FileInputStream)
     D                                     EXTPROC(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :*CONSTRUCTOR)
     D  argString                          like(jstring) const
     D*
     D new_FileOutputStream...
     D                 PR                  like(FileOutputStream)
     D                                     EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :*CONSTRUCTOR)
     D  argString                          like(jstring)
     D*
     D new_FileDataSource...
     D                 PR              O   EXTPROC(*JAVA
     D                                     :'javax.activation.FileDataSource'
     D                                     :*CONSTRUCTOR)
     D  argFileName                        like(jstring) const
     D*
     D new_DataHandler...
     D                 PR              O   EXTPROC(*JAVA
     D                                     :'javax.activation.DataHandler'
     D                                     :*CONSTRUCTOR)
     D  argDataSource                      like(DataSource)
     D**********************************************************************
     D* External Prototype Wrappers for...
     D* Common Java Methods
     D**********************************************************************
     D String_getBytes...
     D                 PR         65535A   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'getBytes')
     D*
     D Object_equals...
     D                 PR             1N   ExtProc(*JAVA:
     D                                     'java.lang.Object':
     D                                     'equals')
     D   argObject                     O   CLASS(*JAVA:'java.lang.Object')
     D                                     const
     D*
     D FileInputStream_close...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :'close')
     D*
     D FileOutputStream_close...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :'close')
     D*
     D Float_toString...
     D                 PR                  like(jString)
     D                                     extproc(*JAVA:
     D                                     'java.lang.Float':
     D                                     'toString')
     D*
     D Float_toAlpha...
     D                 PR          1024A   varying
     D    argFloat                         like(Float)
     D*
     D Integer_parseInt...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'java.lang.Integer'
     D                                     :'parseInt')
     D                                     static
     D   argString                         like(jString)
     D*
     D Integer_parseIntWithRadix...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'java.lang.Integer'
     D                                     :'parseInt')
     D                                     static
     D   argString                         like(jString)
     D   argRadix                          like(jInt) value
     D*
     D Properties_setProperty...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.util.Properties'
     D                                     :'setProperty')
     D                                     like(jObject)
     D   key                               like(jstring) const
     D   value                             like(jstring) const
     D*
     D Exception_getMessage...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.lang.Throwable'
     D                                     :'getMessage')
     D                                     like(jstring)
     D*
     D Exception_toString...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.lang.Throwable'
     D                                     :'toString')
     D                                     like(jstring)
     D*
     D DateFormat_getDateTimeInstance...
     D                 PR                  like(DateFormat)
     D                                     ExtProc(*JAVA
     D                                     :'java.text.DateFormat'
     D                                     :'getDateTimeInstance')
     D                                     static
     D  argDateCode                        like(jInt) value
     D  argTimeCode                        like(jInt) value
     D*
     D DateFormat_format...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'java.text.DateFormat'
     D                                     :'format')
     D  argDate                            like(JavaDate)
     D*
     D System_getProperty...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'java.lang.System'
     D                                     :'getProperty')
     D                                     static
     D   argString                         like(jString)
     D**********************************************************************
     D* CONSTANTS
     D**********************************************************************
     D* HTML HEX COLORS
     D**********************************************************************
     D COLOR_BLACK...
     D                 C                   '000000'
     D COLOR_RED...
     D                 C                   'FF0000'
     D COLOR_CRIMSON...
     D                 C                   'DC143C'
     D COLOR_ORANGE...
     D                 C                   'FFA500'
     D COLOR_GREEN...
     D                 C                   '00FF00'
     D COLOR_LIME_GREEN...
     D                 C                   '32CD32'
     D COLOR_SEA_GREEN...
     D                 C                   '2E8B57'
     D COLOR_OLIVE...
     D                 C                   '808000'
     D COLOR_BLUE...
     D                 C                   '0000FF'
     D COLOR_DARK_BLUE...
     D                 C                   '00008B'
     D COLOR_CORNFLOWER_BLUE...
     D                 C                   '6495ED'
     D COLOR_ROYAL_BLUE...
     D                 C                   '4169E1'
     D COLOR_INDIGO...
     D                 C                   '4B0082'
     D COLOR_YELLOW...
     D                 C                   'FFFF00'
     D COLOR_AQUA...
     D                 C                   '00FFFF'
     D COLOR_AQUAMARINE...
     D                 C                   '7FFFD4'
     D COLOR_MAGENTA...
     D                 C                   'FF00FF'
     D COLOR_SILVER...
     D                 C                   'C0C0C0'
     D COLOR_LIGHT_SLATE_GRAY...
     D                 C                   '778899'
     D COLOR_BROWN...
     D                 C                   'A52A2A'
     D COLOR_CHOCOLATE...
     D                 C                   'D2691E'
     D COLOR_SIENNA...
     D                 C                   'A0522D'
     D COLOR_WHEAT...
     D                 C                   'F5DEB3'
     D COLOR_KHAKI...
     D                 C                   'FOE68C'
     D COLOR_MOCCASIN...
     D                 C                   'FFE4B5'
     D COLOR_NAVAJO_WHITE...
     D                 C                   'FFDEAD'
     D COLOR_IVORY...
     D                 C                   'FFFFF0'
     D COLOR_WHITE...
     D                 C                   'FFFFFF'
     D**********************************************************************
     D* java.text.DateFormat Constant Field Values
     D**********************************************************************
     D DATE_FORMAT_AM_PM...
     D                 C                   14
     D DATE_FORMAT_DATE...
     D                 C                   3
     D DATE_FORMAT_DAY_OF_WEEK...
     D                 C                   9
     D DATE_FORMAT_DAY_OF_WEEK_IN_MONTH...
     D                 C                   11
     D DATE_FORMAT_DAY_OF_YEAR...
     D                 C                   10
     D DATE_FORMAT_DEFAULT...
     D                 C                   2
     D DATE_FORMAT_ERA...
     D                 C                   0
     D DATE_FORMAT_FULL...
     D                 C                   0
     D DATE_FORMAT_HOUR_OF_DAY0...
     D                 C                   5
     D DATE_FORMAT_HOUR_OF_DAY1...
     D                 C                   4
     D DATE_FORMAT_HOUR0...
     D                 C                   16
     D DATE_FORMAT_HOUR1...
     D                 C                   15
     D DATE_FORMAT_LONG...
     D                 C                   1
     D DATE_FORMAT_MEDIUM...
     D                 C                   2
     D DATE_FORMAT_MILLISECOND...
     D                 C                   8
     D DATE_FORMAT_MINUTE...
     D                 C                   6
     D DATE_FORMAT_MONTH...
     D                 C                   2
     D DATE_FORMAT_SECOND...
     D                 C                   7
     D DATE_FORMAT_SHORT...
     D                 C                   3
     D DATE_FORMAT_TIMEZONE...
     D                 C                   17
     D DATE_FORMAT_WEEK_OF_MONTH...
     D                 C                   13
     D DATE_FORMAT_WEEK_OF_YEAR...
     D                 C                   12
     D DATE_FORMAT_YEAR...
     D                 C                   1
     D**********************************************************************
     D* JNI Constants
     D**********************************************************************
      * Alerady defined QSYSINC/QRPGLESRC,JNI
     D*JNI_VERSION_1_4...
     D*                C                    x'00010004'
     D JNI_VERSION_1_6...
     D                 C                    x'00010006'
     D**********************************************************************
     D* Custom Air Prototypes
     D**********************************************************************
     D* Air_isJVMError(): Indicates Throwable Exception Found
     D Air_isJVMError  PR             1N
     D*
     D Air_getColorFromHex...
     D                 PR                  like(JavaColor)
     D  argHexColor                   6A   const
     D*
     D Air_getDateBytes...
     D                 PR           512A   varying
     D  argDate                            like(JavaDate)
     D  argDateFormat                      like(jInt) value
     D  argTimeFormat                      like(jInt) value
     D*
     D Air_getHashMapIterator...
     D                 PR                  like(Iterator)
     D  argHashMap                         like(HashMap)
     D*
     D Air_getIteratorNextBytes...
     D                 PR         65535A   varying
     D  argIterator                        like(Iterator)
     D*
     D Air_getHashMapBytes...
     D                 PR         65535A   varying
     D  argHashMap                         like(HashMap)
     D  argBytes                  65535A   const varying options(*varsize)
     D* Air_getSystemProperty
     D* - java.version
     D* - java.class.path
     D* - os.name
     D Air_getSystemProperty...
     D                 PR         65535A   varying
     D  argBytes                  65535A   const varying options(*varsize)
     D**********************************************************************
      /define SPAIRJAVA
      /endif
