      *===================================================================*
      * Program name: IFS2BLOB_T                                          *
      * Purpose.....: To run SP GetBlob in AS/400                         *
      *                                                                   *
      * Date written: 2019/06/22                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2019/06/28 Alan       AC              Develop                     *
      *===================================================================*
     HDEBUG(*YES)
     D I_filename      S             20A
     D O_Bytes         S                   Like(Image)
      *
     D Image           S                   SQLTYPE(BLOB:5242880)
      *
     C     *Entry        Plist
     C                   Parm                    I_filename
     C                   Parm                    O_Bytes
      *
     C*---------------------------------------------------------------
     C/EXEC SQL WHENEVER SQLERROR GOTO ERR
     C/END-EXEC
      *
     C/EXEC SQL
     C+ CALL GETBLOB (:I_filename, :O_Bytes)
     C/END-EXEC
      *
     C                   GOTO      $EndPgm
      *
     C     ERR           TAG
      *
     C     $EndPgm       Tag
     C                   Eval      *InLr = *On
     C                   Return
