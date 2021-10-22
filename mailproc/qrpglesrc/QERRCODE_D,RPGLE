      ***********************************************************
    XX*QERRCODE_D
    3X*A. NAME:       IBM API Error Code Data Structures
     X*
     X*B. PROGRAM:    qerrcode_d
     X*
     X*C. PURPOSE:    This member contains the data structure definitions
     X*               for the Error Code Parameter used by OS/400 APIs.
     X*               Only format 100 has been provided at this time as
     X*               convertible character support (CCHAR) is not required.
      *****************************************************************
      *                       PROGRAM HISTORY
      *                       ---------------
      *
      * 01/26/07 - SJW
      * 1. New - Data structure for OS/400 V5R2M0.
      *****************************************************************
      * Error Code format 100 - No CCHAR support
      *****************************************************************
     d qerrcode_100    ds                  qualified
     d  bytes_rtnd             1      4B 0                                      Bytes Returned
     d  bytes_avail            5      8B 0                                      Bytes Available
     d  err_id                 9     15                                         Exception ID
     d                        16     16                                         Reserved
     d  excp_data             17    528                                         Exception Data (512)
