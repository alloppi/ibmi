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
     D*   CRTRPGMOD MODULE(AIRLIB/AIR06_03) SRCFILE(AIRLIB/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE PROGRAM)
     D*   CRTPGM PGM(AIRLIB/AIR06_03)
     D*   MODULE(AIRLIB/AIR06_03)
     D*   BNDSRVPGM(AIRLIB/SVAIRFUNC AIRLIB/SVAIRJAVA)
     D*             ACTGRP(AIR06_03)
     D*****************************************************************
     D cd              DS                  likeDs(iconv_t)
     D toCCSID         S             10I 0
     D size            S             10I 0
     D i               S             10I 0
     D displayString   S             52A
     D ebcdicString    S           1024A
     D asciiStrArray   S           1024A
     D stringClass     S                   LIKE(jclass)
     D stringObject    S                   LIKE(jstring)
     D stringArray     S                   LIKE(jobjectArray)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/DEFINE JNI_COPY_ARRAY_FUNCTIONS
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
         size = 10;
         cd = Air_openConverter(toCCSID);
         ebcdicString = 'java/lang/String';
         asciiStrArray = Air_convert(cd: %trim(ebcdicString));
         // Get the Class
         stringClass = FindClass(JNIEnv_P:
                                %trim(asciiStrArray));
         if (stringClass = *null);
           displayString = 'FindClass Error';
           dsply displayString;
         else;
         endif;
         // Get the Object Array
         stringArray = NewObjectArray(JNIEnv_P:
                                   size:
                                   stringClass:
                                   *null);
         if (stringArray = *null);
           displayString = 'NewObjectArray Error';
           dsply displayString;
         else;
         endif;
         // Initialize Ten String Array Objects
         for i = 0 to 9;
           stringObject = new_String('String ' + %trim(%editc(i:'3')));
           SetObjectArrayElement(JNIEnv_P:stringArray
                                :i:stringObject);
           if (Air_isJVMError());
             leave;
           else;
           endif;
         endFor;
         // Loop and Display results
         for i = 0 to 9;
           stringObject = GetObjectArrayElement(JNIEnv_P
                                               :stringArray:i);
           if (Air_isJVMError());
             leave;
           else;
             displayString = String_getBytes(stringObject);
             dsply displayString;
           endif;
         endFor;
         // Clean Up
         Air_closeConverter(cd);
         freeLocalRef(stringClass);
         freeLocalRef(stringObject);
         freeLocalRef(stringArray);
         *inlr = *ON;
      /end-free
