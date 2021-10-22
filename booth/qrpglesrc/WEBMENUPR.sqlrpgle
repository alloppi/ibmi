      //  ______________________________________________________________________
      //  Create WEBMENUP file with SQL.
      //
      //   WEBMENUPR   (.sqlrpgle)
      //  ______________________________________________________________________
     h option(*nodebugio) dftactgrp(*no) actgrp(*new)

      /free
        *inlr = *on;
        // The immediately following /EXEC SQL is SQL's version of RPG's H Spec
        // It is never executed.  Just used at compile time.
        exec sql
          Set Option
            Commit = *None;

        // Create WEBMENUP File
        exec sql
          // Create Table DVABRMD/WEBMENUP (
          Create Table ALAN/WEBMENUP (
            MENUCAT char(30) not null,       // Category
            MENUSEQ decimal(2) not null,     // Seq.# within category
            MENUITEM char(30) not null,      // Label to be displayed on menu
            MENUCMD char(120) not null,      // Command to execute, if chosen.
            primary key(MENUCAT,MENUSEQ) ) RCDFMT WEBMENUPR;
      /end-free
