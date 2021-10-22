      *===================================================================*
      * Program name: SPBLOB                                              *
      * Purpose.....: To run SP GetBlob in AS/400                         *
      *                                                                   *
      * Date written: 2019/06/22                                          *
      *                                                                   *
      * Create Function ALAN/FileToBLOB                                   *
      * (parmIFSFile VarChar(50))                                         *
      * Returns Blob(5M) As Locator                                       *
      * Language RPGLE                                                    *
      * Parameter Style SQL                                               *
      * External Name ALAN/SPBLOB                                         *
      * Reads SQL Data                                                    *
      * Deterministic                                                     *
      * Returns Null on Null Input                                        *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2019/06/28 Alan       AC              Develop                     *
      *===================================================================*
     HDEBUG(*YES)
     D BlobData        S                   SQLTYPE(BLOB_LOCATOR)
     D BlobFile        S                   SQLTYPE(BLOB_FILE)

      * Locator Variable BLOB Data is replaced with:
     D*BlobData        S             10U 0

      * Blob_File Variable BLOBFILE is replaced with:
     D*BlobFile         DS
     D*BlobFile_NL                    10U 0
     D*BlobFile_DL                    10U 0
     D*BlobFile_FO                    10U 0
     D*BlobFile_Name                 255A

     D p_filename      S             20A
     D r_bytes         S                   Like(Image)
      *
     D Image           S                   SQLTYPE(BLOB:5242880)
      *
     C     *Entry        Plist
     C                   Parm                    p_filename
     C                   Parm                    r_bytes
      *
     c                   eval      BlobFile_FO = sqfrd
     c                   eval      BlobFile_Name = '/home/alan/' + p_filename
     c                   eval      blobfile_nl = %len(BlobFile_Name)

      * Convert IFS File to BLOB and return BLOB Locator Handle
      *
     c/exec sql
     c+ values :blobfile into :blobdata
     c/end-exec
      *
     c/exec sql
     c+ Select FileToBlob(link)
     c+ into :blobfile
     c+ from ALAN/aa_files
     c+ where filename = :p_filename
     c/end-exec
     C     $EndPgm       Tag
     C                   Eval      *InLr = *On
     C                   Return
