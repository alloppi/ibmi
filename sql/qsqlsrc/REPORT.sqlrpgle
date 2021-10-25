      * Refer:
      * https://www.mcpressonline.com/programming/rpg/techtip-blobs-keep-pdf-xls-and-other-reports-s
      * afe-in-db2-part-1
      *
      * CREATE TABLE RPTARCHIVE/REPORTS
      *   (RPT_ID DECIMAL (7, 0)
      *  , RPT_TYPE CHAR (10 )
      *  , RPT_TIME TIMESTAMP
      *  , RPT_RMK CHAR (200 )
      *  , RPT_FILE1 BLOB (500K )
      *  , CONSTRAINT PK_RPT_ID UNIQUE (RPT_ID))

     D Rpt_ID          S              7  0 Inz(*Zeros)
     D Rpt_Type        S             10    Inz(*Blanks)
     D Rpt_Rmk         S            255    Inz(*Blanks)








