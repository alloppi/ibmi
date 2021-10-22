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
     D*   CRTRPGMOD MODULE(YourLib/AIR05_01) SRCFILE(YourLib/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE PROGRAM)
     D*   CRTPGM PGM(YourLib/AIR05_01)
     D*   MODULE(YourLib/AIR05_01)
     D*   BNDSRVPGM(YourLib/SVAIRFUNC YourLib/SVAIRJAVA)
     D*             ACTGRP(AIR05_01)
     D**********************************************************************
     D*** PROTOTYPES ***
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRSRC,SPAIRJAVA
     D airString       S                   like(jString)
     D displayBytes    S             52A
      /free
        JNIEnv_p = getJNIEnv();
        airString = new_String('Hello World');
        displayBytes = String_getBytes(airString);
        DSPLY displayBytes;
        freeLocalRef(airString);
        *inlr = *ON;
      /end-free
