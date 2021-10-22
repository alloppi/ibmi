     H THREAD(*SERIALIZE)
     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D**********************************************************************
     D*  How to Compile:
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(AIRLIB/AIR06_02) SRCFILE(AIRLIB/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE PROGRAM)
     D*   CRTPGM PGM(AIRLIB/AIR06_02)
     D*   MODULE(AIRLIB/AIR06_02)
     D*   BNDSRVPGM(AIRLIB/SVAIRFUNC AIRLIB/SVAIRJAVA)
     D*             ACTGRP(AIR06_02)
     D*****************************************************************
     D*
     D new_Dimension...
     D                 PR              O   EXTPROC(*JAVA
     D                                     :'java.awt.Dimension'
     D                                     :*CONSTRUCTOR)
     D*
     D dim             S               O   CLASS(*JAVA
     D                                     :'java.awt.Dimension')
     D dimClass        S                   Like(jclass)
     D displayString   S             52A
     D cd              DS                  likeDs(iconv_t)
     D ebcdicString    S           1024A
     D asciiDimension  S           1024A
     D asciiWidth      S           1024A
     D asciiHeight     S           1024A
     D asciiSignature  S           1024A
     D toCCSID         S             10I 0
     D widthBefore     S             10I 0
     D heightBefore    S             10I 0
     D widthAfter      S             10I 0
     D heightAfter     S             10I 0
     D widthId         S                   Like(jfieldID)
     D heightId        S                   Like(jfieldID)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/DEFINE JNI_COPY_FIELD_FUNCTIONS
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     C/EJECT
      /free
         // Create/Attach to JVM
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         // Create Conversion Descriptor for CCSID conversions
         toCCSID = 1208;
         cd = Air_openConverter(toCCSID);
         // Java classes are typically identified with period separators
         // But, when using JNI you must change the '.' to '/'
         // ASCII java.awt.Dimension
         ebcdicString = 'java/awt/Dimension';
         asciiDimension = Air_convert(cd: %trim(ebcdicString));
         // The JNI type signature for int = 'I'
         ebcdicString = 'I';
         asciiSignature = Air_convert(cd: %trim(ebcdicString));
         // ASCII width
         ebcdicString = 'width';
         asciiWidth = Air_convert(cd: %trim(ebcdicString));
         // ASCII height
         ebcdicString = 'height';
         asciiHeight = Air_convert(cd: %trim(ebcdicString));
         // Get an instance of the Dimension Class
         dim = new_Dimension();
         // Get the Class reference using JNI
         dimClass = FindClass(JNIEnv_P:%trim(asciiDimension));
         if (dimClass = *null);
           displayString = 'Dimension FindClass Error';
           dsply displayString;
         else;
         endif;
         // Get the Field references within the Class
         widthId = GetFieldID(JNIEnv_P:dimClass:
                              %trim(asciiWidth):
                              %trim(asciiSignature));
         heightId = GetFieldID(JNIEnv_P:dimClass:
                              %trim(asciiHeight):
                              %trim(asciiSignature));
         // Retrieve the publicly accessible field values
         // of the Dimension instance on Initialization
         widthBefore = getIntField(JNIEnv_P:dim:widthId);
         heightBefore = getIntField(JNIEnv_P:dim:heightId);
         // Set the publicly accessible field values
         // using JNI, then retrieve them.
         setIntField(JNIEnv_P:dim:widthId:1);
         setIntField(JNIEnv_P:dim:heightId:2);
         widthAfter = getIntField(JNIEnv_P:dim:widthId);
         heightAfter = getIntField(JNIEnv_P:dim:heightId);
         // Display the results
         displayString = 'Before: '
                + 'Width = '
                + %trim(%editc(widthBefore:'3'))
                + ' Height = '
                + %trim(%editc(heightBefore:'3'));
         dsply displayString;
         displayString = 'After: '
                + 'Width = '
                + %trim(%editc(widthAfter:'3'))
                + ' Height = '
                + %trim(%editc(heightAfter:'3'));
         dsply displayString;
         // Clean Up
         Air_closeConverter(cd);
         freeLocalRef(dim);
         freeLocalRef(dimClass);
         *inlr = *ON;
      /end-free
