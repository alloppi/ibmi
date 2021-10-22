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
     F*   CRTBNDRPG PGM(AIRLIB/AIR06_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.') DFTACTGRP(*NO)
     F*****************************************************************
     D Dimension       DS                  qualified
     D  field1                 1      3A
     D  field2                 4      6A
     D  field3                 7      9A
     D  field4                10     12A
     D  width_I                       3S 0 overlay(field2)
     D  width_B                       3A   overlay(field2)
     D  height_I                      3S 0 overlay(field4)
     D  height_B                      3A   overlay(field4)
     D*
     D DimensionRaw    DS
     D  dimRaw                 1     12A
     D*
     D  displayBytes   S             52A
     C*
      /free
       dimRaw = 'xxx001xxx002';
       displayBytes = 'Raw: ' + %trim(dimRaw);
       dsply displayBytes;
       // Push Raw Dimension into Structured Dimension
       Dimension = DimensionRaw;
       displayBytes = 'fieldId(width_I) '
                    + %trim(%editc(Dimension.width_I:'Z'));
       dsply displayBytes;
       displayBytes = 'fieldId(width_B) '
                    + %trim(Dimension.width_B);
       dsply displayBytes;
       displayBytes = 'fieldId(height_I) '
                    + %trim(%editc(Dimension.height_I:'Z'));
       dsply displayBytes;
       displayBytes = 'fieldId(height_B) '
                    + %trim(Dimension.height_B);
       dsply displayBytes;
       *inlr = *ON;
      /end-free
