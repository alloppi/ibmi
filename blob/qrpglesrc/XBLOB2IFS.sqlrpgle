      * Purpose : Load binary data and save to DB2 BLOB
      * Refer   : 1. http://www.mcpressonline.com/rpg/techtip-blobs-don-t-
      *              run-embrace-them-with-rpg.html
      *           2. http://iprodeveloper.com/rpg-programming/rpg-vs-blob
      *
      * DB2 Table  : CREATE TABLE ALAN/aa_files (
      *                  id INT NOT NULL GENERATED ALWAYS AS IDENTITY
      *                    (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
      *                  filename CHAR(20) NOT NULL,
      *                  savedtime TIMESTAMP NOT NULL,
      *                  bytes BLOB(5M) NOT NULL
      *              )
      *
      *              CHGAUT OBJ('/QSYS.LIB/ALAN.LIB/AA_FILES.FILE')
      *                USER(USRGRP) DTAAUT(*RWX) OBJAUT(*ALL)
      *              CHGOWN OBJ('/QSYS.LIB/ALAN.LIB/AA_FILES.FILE')
      *                NEWOWN(USRGRP)
      *
      * Stored     : DROP PROCEDURE ALAN/InsFile
      * Procedures :
      *
      *              CREATE PROCEDURE ALAN/InsFile (
      *                p_filename CHAR (20),
      *                p_savedTime TIMESTAMP,
      *                p_bytes BLOB (5M) )
      *              LANGUAGE RPGLE
      *              EXTERNAL NAME AABLOB2IFS
      *              PARAMETER STYLE SQL
      *
     D EntryPara       PR                  ExtPgm('AABLOB2IFS')
     D  p_filename                   20A
     D  p_savedtime                    Z
     D  p_bytes                            Like(Image)

     D EntryPara       PI
     D  p_filename                   20A
     D  p_savedtime                    Z
     D  p_bytes                            Like(Image)

     D AASetLibl       PR                  ExtPgm('AASETLIBL')

      * BLOB Size 1024*1024*5M=5242880
     D Image           S                   SQLTYPE(BLOB:5242880)
     D myfile          S                   SQLTYPE(BLOB_FILE)

     D myID            S             10I 0

     D SQL_FILE_OVERWRITE...
     D                 c                   const(16)
      /free

        // Set Library List according to Machine
        AASetLibl();

        // Set SQL without file locking and commitment
        exec SQL
          SET OPTION COMMIT = *NONE,
                     CLOSQLCSR = *ENDMOD;

        // Insert BLOB to DB2 record
        exec SQL
          INSERT INTO aa_files(filename, savedtime, bytes)
          VALUES(:p_filename, :p_savedtime, :p_bytes);

        // Setup path name and prepare write file to IFS
        myfile_fo   = SQL_FILE_OVERWRITE;
        myfile_name = '/home/alan/' + p_filename;
        myfile_nl   = %len(%trimr(myfile_name));

        // Save BLOB file to IFS
        exec SQL
          SELECT id, bytes
          INTO :myID, :myfile
          FROM aa_files
          WHERE filename = :p_filename;

        // Delete record in DB2
        exec SQL
          DELETE FROM aa_files
          WHERE ID = :myID;

        *InLr = *On;

        return;
      /end-free
