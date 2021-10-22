     H THREAD(*SERIALIZE)
     F* ====================================================================
     F* ============== Advanced Integrated RPG by Tom Snyder ===============
     F* ====================================================================
     F* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     F* All rights reserved.
     F*
     F* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     F* Author URL:    http://www.2WolvesOut.com
     F**********************************************************************
     F*  How to Compile:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/AIR06_04) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR06_04)
     F*   MODULE(AIRLIB/AIR06_04)
     F*   BNDSRVPGM(AIRLIB/SVAIRFUNC AIRLIB/SVAIRJAVA)
     F*             ACTGRP(AIR06_04)
     F*****************************************************************
     D*
     D cd              DS                  likeDs(iconv_t)
     D toCCSID         S             10I 0
     D displayString   S             52A
     D ebcdicString    S           1024A
     D errorString     S           1024A
     D correctString   S           1024A
     D stringClass     S                   LIKE(jclass)
     D********************************************************************
     D/DEFINE OS400_JVM_12
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
         // Force an exception by using '.' instead of '/'
         ebcdicString = 'java.lang.String';
         errorString = Air_convert(cd: %trim(ebcdicString));
         // This is the correct way, replacing the '.' with '/'
         ebcdicString = 'java/lang/String';
         correctString = Air_convert(cd: %trim(ebcdicString));
         // This will cause an exception
         stringClass = FindClass(JNIEnv_P:
                                %trim(errorString));
         if (Air_isJVMError());
         else;
           displayString = 'First Attempt Success!';
           dsply displayString;
         endif;
         // This will Succeed
         stringClass = FindClass(JNIEnv_P:
                                %trim(correctString));
         if (Air_isJVMError());
         else;
           displayString = 'Second Attempt Success!';
           dsply displayString;
         endif;
         // Clean Up
         Air_closeConverter(cd);
         freeLocalRef(stringClass);
         *inlr = *ON;
      /end-free
