      *===================================================================*
      * Program name: BLOBSRV                                             *
      * Purpose.....: External RPG program for UDF                        *
      *                                                                   *
      * Date written: 2019/07/05                                          *
      *                                                                   *
      * CRTSQLRPGI OBJ(ALAN/BLOBSRV) SRCFILE(ALAN/BLOB) SRCMBR(BLOBSRV) OBJTYPE(*MODULE) *
      * CRTSRVPGM SRVPGM(ALAN/BLOBSRV) MODULE(ALAN/BLOBSRV) EXPORT(*ALL)  *
      *                                                                   *
      * Create Function ALAN/BLOBSRV                                      *
      * (parmIFSFile VarChar(255))                                        *
      * Returns Blob(5M) As Locator                                       *
      * Language RPGLE                                                    *
      * Parameter Style SQL                                               *
      * External Name ALAN/BLOBSRV(BLOBSRV)                               *
      * Reads SQL Data                                                    *
      * Deterministic                                                     *
      * Returns Null on Null Input                                        *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2019/06/28 Alan       AC              Develop                     *
      *===================================================================*
     HDFTACTGRP(*NO)

     d BlobData        s                   SQLTYPE(BLOB_LOCATOR)
     d BlobFile        s                   SQLTYPE(BLOB_FILE)

      * Locator Variable BLOB Data is replaced with:
     D*BlobData        S             10U 0

      * Blob_File Variable BLOBFILE is replaced with:
     D*BlobFile        DS
     D*BlobFile_NL                   10U 0
     D*BlobFile_DL                   10U 0
     D*BlobFile_FO                   10U 0
     D*BlobFile_Name                255A

     D BLOBSRV         PR                  Like(Image) Export
     D  p_filename                  255a   const

     d p_filename      S            255a
      * BLOB Size 1024*1024*5M=5242880
     D Image           S                   SQLTYPE(BLOB:5242880)

     c                   move      *on           *inlr
     c                   return

     c                   eval      BlobFile_FO = sqfrd
     c                   eval      BlobFile_Name = p_filename
     c                   eval      blobfile_nl = %len(p_filename)

      * Convert IFS File to BLOB and return BLOB Locator Handle
     c/exec sql
     c+ values :blobfile into :blobdata
     c/end-exec

