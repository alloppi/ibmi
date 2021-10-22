      * http://iprodeveloper.com/rpg-programming/rpg-vs-blob
      *
     D item            s              5P 0
     D short           s                   SQLTYPE(BLOB:32766)
     * the following DS will be created by SQL precompiler
     D* short          DS
     D* short_len                    10U 0
     D* short_data                32766A
      *
     D pic             s                   SQLTYPE(BLOB_FILE)
     * the following DS will be created by SQL precompiler
     D*PIC             DS
     * Name Length. You place the length of the name in the PIC_NAME field here.
     D*PIC_NL                        10U 0
     * Data Length. SQL places the length of data that it writes to the IFS into this field.
     D*PIC_DL                        10U 0
     * File Options. You use this field to tell SQL whether to create, replace, or add to your IFS
     D*PIC_FO                        10U 0
     * File Name. You place the path name to the IFS file that you want SQL to read from or write t
     D*PIC_NAME                     255A
      *
     D out             s                   SQLTYPE(BLOB_FILE)
      *
      * Create Table shall be done before compile
      *
     C*/EXEC SQL   Create Table ALAN/ITEMPIC
     C*+            (
     C*+              ItemNo Dec(5,0) Not Null,
     C*+              Picture BLOB(2M) With Default Null,
     C*+              Primary Key( ItemNo )
     C*+            )
     C*/END-EXEC
      * Write 7 byte of binary data to the BLOB field of the file
     C                   eval      item       = 10000
     C                   eval      short_len  = 7
     C                   eval      short_data = x'01240905906788'
     C/EXEC SQL   Insert Into ALAN/ITEMPIC Values (:item,:short)
     C/END-EXEC
      * Read Data
     C/EXEC SQL   Select ItemNo,Picture
     C+             into :item,:short
     C+             from ALAN/ITEMPIC
     C+             Where ItemNo = 10000
     C/END-EXEC
     C                   eval      item     = 10001
     * SQFRD  = Read Only. This is used when you want to write data to the database from a stream f
     *          doesn't exist, the statement fails, and SQLCOD is set appropriately.
     * SQFCRT = Create File. This is used when you want SQL to create the stream file in the IFS an
     *          from the database in it. If the file already exists, the statement fails and, SQLCO
     *          appropriately
     * SQFOVR = Overwrite File. This is used when you want SQL to create the stream file in the IFS
     *         data from the database in it. If the file already exists, it is overwritten
     * SQFAPP = Append To File. This is used when you want SQL to create the stream file in the IFS
     *          data from the database in it. If the file already exists, the BLOB data is appended
     *          end of the file.
     * The SQFCRT, SQFOVR, and SQFAPP file options create the file if it doesn't exist. The only di
     * these options is what happens while the file does exist. When the file exists, SQFCRT produc
     * overwrites the file, and SQFAPP adds to file.
     *
     c                   eval      pic_fo   = SQFRD
     c                   eval      pic_name = '/tmp/test.jpg'
     c                   eval      pic_nl   = %len(%trimr(pic_name))
     C/EXEC SQL   Insert Into ALAN/ITEMPIC Values (:item,:pic)
     C/END-EXEC
      * Out to IFS
    * SQFOVR = Overwrite File. This is used when you want SQL to create the stream file in
    *          the IFS and store the data from the database in it. If the file already exists,
      *          it is overwritten
     C                   eval      out_fo   = SQFOVR
     c                   eval      out_name = '/tmp/test_out.jpg'
     c                   eval      out_nl   = %len(%trimr(out_name))
      *
     C/EXEC SQL   Select picture
     C+             Into :out
     C+             From ALAN/ITEMPIC
     C+             Where itemno = :item
     C/END-EXEC
      *
     C*  OUT_DL now contains the length of the data that
     C*         was written to the IFS.
      *
     C                   Eval      *INLR = *On
     C                   Return
