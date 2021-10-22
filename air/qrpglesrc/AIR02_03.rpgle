     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D**********************************************************************
     D/define ALPHA_MODE
     D/if defined(ALPHA_MODE)
     D a               S              5A   inz('Hello')
     D b               S              5A   inz(' RPG')
     D c               S             10A
     D/else
     D a               S             10I 0 inz(1)
     D b               S             10I 0 inz(2)
     D c               S             10I 0
     D/endif
     D d               S             10A
     D*
     D displayBytes    S             52A
     C*
     C                   EVAL      c = a + b
     C                   MOVE      c             d
      /free
                         displayBytes = 'Results: ' + %trim(d);
                         DSPLY     displayBytes;
      /end-free
      /if defined(*ILERPG)
     C     'RPG ILE'     DSPLY
      /else
      /endif
     C/if defined(*CRTBNDRPG)
     C     'CRTBNDRPG'   DSPLY
     C/else
     C/endif
     C/if defined(*CRTRPGMOD)
     C     'CRTRPGMOD'   DSPLY
     C/else
     C/endif
     C/if defined(*V5R1M0)
     C     '>= V5R1M0'   DSPLY
     C/else
     C/endif
     C                   EVAL      *inlr = *ON
