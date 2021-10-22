      * Purpose : Load binary data and save to DB2 BLOB
      * Refer   :
      * https://www.mcpressonline.com/programming/rpg/techtip-blobs-dont-run-embrace-them-with-rpg
      * http://www.ibmsystemsmag.com/ibmi/developer/rpg/rpg_stored_procedures2/
      *
      * DB2 Table  : CREATE TABLE ALAN/aa_files (
      *                  id INT NOT NULL GENERATED ALWAYS AS IDENTITY
      *                    (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
      *                  filename CHAR(20) NOT NULL,
      *                  savedtime TIMESTAMP NOT NULL,
      *                  bytes BLOB(5M) NOT NULL,
      *                  link DATALINK(100) NOT NULL
      *              )
      *
      *              CHGAUT OBJ('/QSYS.LIB/ALAN.LIB/AA_FILES.FILE')
      *                USER(USRGRP) DTAAUT(*RWX) OBJAUT(*ALL)
      *              CHGOWN OBJ('/QSYS.LIB/ALAN.LIB/AA_FILES.FILE')
      *                NEWOWN(USRGRP)
      *
      * Stored     : DROP PROCEDURE ALAN/GETBLOB
      * Procedures :
      *
      *              CREATE PROCEDURE ALAN/GETBLOB
      *                      ( IN  I_FILENAME CHAR (20),
      *                        OUT O_PICT BLOB (5M) )
      *                      LANGUAGE SQL READS SQL DATA
      *                      P1: BEGIN
      *                        DECLARE C1 CURSOR FOR
      *                          SELECT BYTES FROM ALAN.AA_FILES
      *                          WHERE FILENAME = I_FILENAME;
      *                        DECLARE EXIT HANDLER FOR SQLEXCEPTION
      *                          SET O_PICT = NULL;
      *                        OPEN C1;
      *                        FETCH C1 INTO O_PICT;
      *                        CLOSE C1;
      *                      END P1
      *
      *
     D EntryPara       PR                  ExtPgm('IFS2BLOB')
     D  p_filename                   20A
     D* r_bytes                            Like(Image)

     D EntryPara       PI
     D  p_filename                   20A
     D* r_bytes                            Like(Image)

     D*AASetLibl       PR                  ExtPgm('AASETLIBL')

      * BLOB Size 1024*1024*5M=5242880
     D Image           S                   SQLTYPE(BLOB:5242880)

     D myfile          S                   SQLTYPE(BLOB_FILE)
     D SQL_FILE_READ...
     D                 C                   CONST(2)
     D SQL_FILE_OVERWRITE...
     D                 C                   CONST(16)

     D mySavedTime     S               Z
     D myfilelink      S            100A
      /free

        // Set Library List according to Machine
        // AASetLibl();

        // Set SQL without file locking and commitment
        exec SQL
          SET OPTION COMMIT = *NONE,
                     CLOSQLCSR = *ENDMOD;

        // Setup path name to read IFS file to DB2
        myfile_fo   = SQL_FILE_READ;
        myfile_name = '/home/alan/' + p_filename;
        myfile_nl   = %len(%trimr(myfile_name));

        myfilelink = 'FILE://AS400SYSNAME' + myfile_name;

        // Get saved time from current timestamp
        mySavedTime = %TimeStamp();

        // Delete record in DB2 first
        exec SQL
           DELETE FROM ALAN/aa_files
           WHERE filename = :p_filename;

        // Insert IFS file data to DB2 BLOB record
        exec SQL
          INSERT INTO ALAN/aa_files
            (filename, savedtime, bytes, link)
          VALUES(:p_filename, :mySavedTime,
            :myfile, DLVALUE(:myfilelink));

        // Host variable declarations
        // Read DB2 BLOB data and copy to output parameter
        // exec SQL
        //  SELECT bytes
        //  INTO :r_bytes
        //  FROM ALAN/aa_files
        //  WHERE filename = :p_filename;

        *InLr = *On;

        return;
      /end-free
