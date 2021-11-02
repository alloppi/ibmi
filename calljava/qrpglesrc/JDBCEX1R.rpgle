      *=========================================================================================*
      * Program name: JDBCEX1R                                                                  *
      * Purpose.....: MySQL md_kpi_value Insertion or Updating                                  *
      *                                                                                         *
      * Spec........:                                                                           *
      *  Demonstration of using the JDBCR4 service program to interact                          *
      *  with a MySQL database -- using Unicode fields.                                         *
      *                               Scott Klement, May 7, 2009                                *
      *                                                                                         *
      *  MySQL Server:                                                                          *
      *     ** First, give access right to remote access from SysName                           *
      *        using user 'root' and password 'pwd' **                                          *
      *     - mysql -h localhost -u root -p                                                     *
      *     - GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.18.101.16'                             *
      *       IDENTIFIED BY 'user' WITH GRANT OPTION;                                           *
      *     - FLUSH PRIVILEGES;                                                                 *
      *     - use mysql;                                                                        *
      *     - // check host=172.18.101.16, user=root in user table                              *
      *       select host, user from user;                                                      *
      *                                                                                         *
      *  AS400 Client:                                                                          *
      *     - put MySQL JDBC Type 4 driver to IFS '/javaapps'                                   *
      *     - add CLASSPATH for this driver                                                     *
      *     ADDENVVAR  ENVVAR(CLASSPATH) +                                                      *
      *                  VALUE('/javaapps/mysql-connector-java-5.1.39-bin.jar') +               *
      *                  REPLACE(*YES)                                                          *
      *                                                                                         *
      *  To Compile:                                                                            *
      *     ** First, you need the JDBCR4 service program. See that                             *
      *        source member for instructions. **                                               *
      *     CRTBNDRPG JDBCEX1R SRCFILE(xxx/xxx) DBGVIEW(*LIST)                                  *
      *                                                                                         *
      *  To Run:                                                                                *
      *     ADDLIBLE JDBCRPG                                                                    *
      *     CALL JDBCEX1R PARM('user' 'password')                                               *
      *                                                                                         *
      *     Replace 'root' with your userid on the MySQL server                                 *
      *     and 'user' with your password.                                                      *
      *                                                                                         *
      *  Check program result using MySQL command                                               *
      *     - use system_intranet                                                               *
      *     - show tables;                                                                      *
      *     - select * from md_kpi_value;                                                       *
      *                                                                                         *
      * Modification:                                                                           *
      * Date       Name       Pre  Ver  Mod#  Remarks                                           *
      * ---------- ---------- --- ----- ----- ------------------------------------------------- *
      * 2018/03/29 Alan       AC              New Development                                   *
      *=========================================================================================*
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H OPTION(*NODEBUGIO:*SRCSTMT)
     H BNDDIR('JDBC')

     FJDBCEX1F  IF   E           K Disk

     D JDBCEX1R          PR                  extpgm('JDBCEX1R')
     D    mdip                       15A   const
     D    userid                     45A   const
     D    passwrd                    16A   const
     D    P_SPD                        D   const
     D    P_SN                        4P 0 const
     D    R_LoginCde                  1a
     D    R_UpdateFlg                 1a
     D    R_SQLErrCde                10a
     D    R_SQLErrMsg               100a
     D JDBCEX1R          PI
     D    mdip                       15A   const
     D    userid                     45A   const
     D    passwrd                    16A   const
     D    P_SPD                        D   const
     D    P_SN                        4P 0 const
     D    R_LoginCde                  1a
     D    R_UpdateFlg                 1a
     D    R_SQLErrCde                10a
     D    R_SQLErrMsg               100a

      /copy qcpysrc,jdbc_h

     D conn            s                   like(Connection)
     D ErrMsg          s             50A
     D wait            s              1A
     D rs              s                   like(ResultSet)
     D success         s              1N
     D W1LTBUT         S               Z
     D W1LRTUT         S               Z
     D W1fld           S             26A
     D W1String        S            100A

      /free
       *inlr = *on;
       // Init return value
       R_LoginCde    = *Blank ;
       R_UpdateFlg   = *Blank ;
       R_SQLErrCde   = *Blank ;
       R_SQLErrMsg   = *Blank ;

       // Connect to MySQL database
       //  change the jdbc:mysql string to reference your IP address
       //  and the database name!
       //  'jdbc:mysql://172.18.101.01:3306/system_intranet?useSSL=true'
         W1String = 'jdbc:mysql://' + %Trim(mdip)
                    + ':3306/system_intranet?useSSL=true';
       conn = JDBC_Connect( 'com.mysql.jdbc.Driver'
         : %trim(W1String)
         : %trim(userid)
         : %trim(passwrd) );

       if (conn = *NULL);
           R_loginCde = '2';
           R_UpdateFlg = '1';
           *inlr = *on;
           return;
           else;
           R_loginCde = '1';
       endif;

       // Set AutoCommit=false to control commitment in MYSQL manually
       jdbc_setCommit(conn: *OFF);

       // Update or Insert record
       setll (P_SPD : P_SN) JDBCEX1FR ;
       readE (P_SPD : P_SN) JDBCEX1FR ;
       dow not %eof(JDBCEX1FR) ;
       // if MDSSSPD = P_SPD and MDSSSN = P_SN;
       // Convert MDSSLRTUT to Timestamp format
                  W1FLD = MDSSLRTUT + '.000000';
                  %subst(w1fld:11:1) = '-';
                  %subst(w1fld:14:1) = '.';
                  %subst(w1fld:17:1) = '.';
                  W1LRTUT = %TIMESTAMP(W1FLD);

       // Convert MDSSLTBUT to Timestamp format
                  W1FLD = MDSSLTBUT + '.000000';
                  %subst(w1fld:11:1) = '-';
                  %subst(w1fld:14:1) = '.';
                  %subst(w1fld:17:1) = '.';
                  W1LTBUT = %TIMESTAMP(W1FLD);
       success = upd_md_kpi(MDSSAC :
                            MDSSBC :
                            MDSSDNLN :
                            MDSSMNLN :
                            MDSSMNLNT :
                            MDSSMNLP :
                            MDSSDLA :
                            MDSSMLA :
                            MDSSMLAT :
                            MDSSMLAP :
                            MDSSDAIN :
                            MDSSMAIN :
                            MDSSMAINT :
                            MDSSMAINP :
                            MDSSDBIA :
                            MDSSMBIA :
                            MDSSMBIAT :
                            MDSSMBIAP :
                            W1LRTUT :
                            MDSSDTB :
                            MDSSMTB :
                            MDSSMTBT :
                            MDSSMTBP :
                            W1LTBUT);
       if not success ;
           R_UpdateFlg = '1';
          leave ;
       endif;
       // endif;
       readE (P_SPD : P_SN) JDBCEX1FR ;
       enddo;

       // Commit or RollBack Transaction
       if success;
           jdbc_commit(conn);
       else;
           jdbc_rollback(conn);
       endif;

       // Close Connection
       jdbc_close(conn);

       *inlr = *on;
       return;
      /end-free

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * upd_md_kpi(): insert or update record in table md_kpi_value
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P upd_md_kpi      b
     D upd_md_kpi      PI             1N
     D  area                         20    const
     D  branch                       20    const
     D  n_loan_daily                 16P 2 const
     D  n_loan_month                 16P 2 const
     D  n_loan_target                16P 2 const
     D  n_loan_percen                16P 2 const
     D  ln_amt_daily                 16P 2 const
     D  ln_amt_month                 16P 2 const
     D  ln_amt_target                16P 2 const
     D  ln_amt_percen                16P 2 const
     D  f_acc_daily                  16P 2 const
     D  f_acc_month                  16P 2 const
     D  f_acc_target                 16P 2 const
     D  f_acc_percen                 16P 2 const
     D  f_bal_daily                  16P 2 const
     D  f_bal_month                  16P 2 const
     D  f_bal_target                 16P 2 const
     D  f_bal_percen                 16P 2 const
     D  real_upd_dat                   Z   const
     D  tfr_daily                    16P 2 const
     D  tfr_month                    16P 2 const
     D  tfr_target                   16P 2 const
     D  tfr_percen                   16P 2 const
     D  daily_upd_dat                  Z   const

     D qry_rs          s                   like(ResultSet)
     D upd_rc          s             10I 0
     D qry_stmt        s                   like(PreparedStatement)
     D upd_stmt        s                   like(PreparedStatement)
     D count           s             10I 0

      /free

       // Chain records and check record exists
       //   if not exists, insert record, otherwise update record
       qry_stmt = JDBC_PrepStmt(conn :
              'Select count(*) as count from md_kpi_value where ' +
              'area_code = ? and branch_code = ?');
       if (qry_stmt = *NULL);
        R_SQLErrMsg = 'Prepare statement for query md_kpi_value failed!';
        R_SQLErrCde = 'UME0001';
           return *OFF;
       endif;

       // Set SQL parameter values
       JDBC_setString (qry_stmt: 1: area  );
       JDBC_setString (qry_stmt: 2: branch);

       // Query the database
       qry_rs = jdbc_ExecPrepQry(qry_stmt);

       // Get the chain result
       jdbc_nextRow( qry_rs );
       count = %int(jdbc_getCol( qry_rs: 1 ));

       JDBC_FreeResult( qry_rs );
       JDBC_FreePrepStmt( qry_stmt );

       // Record not exists, insert record
       if (count = 0);

           upd_stmt = JDBC_PrepStmt(conn : 'Insert Into md_kpi_value ('
             + 'area_code, '
             + 'branch_code, '
             + 'new_loan_daily, '
             + 'new_loan_monthly, '
             + 'new_loan_target, '
             + 'new_loan_percentage, '
             + 'loan_amount_daily, '
             + 'loan_amount_monthly, '
             + 'loan_amount_target, '
             + 'loan_amount_percentage, '
             + 'f_account_daily, '
             + 'f_account_monthly, '
             + 'f_account_target, '
             + 'f_account_percentage, '
             + 'f_balance_daily, '
             + 'f_balance_monthly, '
             + 'f_balance_target, '
             + 'f_balance_percentage, '
             + 'real_time_last_update_date, '
             + 'transfer_daily, '
             + 'transfer_monthly, '
             + 'transfer_target, '
             + 'transfer_percentage, '
             + 'daily_last_update_date)'
             + ' values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)' );

           if (upd_stmt = *NULL);
               R_SQLErrMsg = 'Prepare statement for insert to md_kpi_value' +
                              ' failed!';
               R_SQLErrCde = 'UME0001';
               return *OFF;
           endif;

           JDBC_setString    (upd_stmt:  1: area         );
           JDBC_setString    (upd_stmt:  2: branch       );
           JDBC_SetDecimal   (upd_stmt:  3: n_loan_daily );
           JDBC_setDecimal   (upd_stmt:  4: n_loan_month );
           JDBC_setDecimal   (upd_stmt:  5: n_loan_target);
           JDBC_setDecimal   (upd_stmt:  6: n_loan_percen);
           JDBC_setDecimal   (upd_stmt:  7: ln_amt_daily );
           JDBC_setDecimal   (upd_stmt:  8: ln_amt_month );
           JDBC_setDecimal   (upd_stmt:  9: ln_amt_target);
           JDBC_setDecimal   (upd_stmt: 10: ln_amt_percen);
           JDBC_setDecimal   (upd_stmt: 11: f_acc_daily  );
           JDBC_setDecimal   (upd_stmt: 12: f_acc_month  );
           JDBC_setDecimal   (upd_stmt: 13: f_acc_target );
           JDBC_setDecimal   (upd_stmt: 14: f_acc_percen );
           JDBC_setDecimal   (upd_stmt: 15: f_bal_daily  );
           JDBC_setDecimal   (upd_stmt: 16: f_bal_month  );
           JDBC_setDecimal   (upd_stmt: 17: f_bal_target );
           JDBC_setDecimal   (upd_stmt: 18: f_bal_percen );
           JDBC_SetTimestamp (upd_stmt: 19: real_upd_dat );
           JDBC_setDecimal   (upd_stmt: 20: tfr_daily    );
           JDBC_setDecimal   (upd_stmt: 21: tfr_month    );
           JDBC_setDecimal   (upd_stmt: 22: tfr_target   );
           JDBC_setDecimal   (upd_stmt: 23: tfr_percen   );
           JDBC_SetTimestamp (upd_stmt: 24: daily_upd_dat);
       endif;

       // Record exists, update record
       if (count <> 0);

           upd_stmt = JDBC_PrepStmt(conn : 'update md_kpi_value set '
             + 'new_loan_daily = ?, '
             + 'new_loan_monthly = ?, '
             + 'new_loan_target = ?, '
             + 'new_loan_percentage = ?, '
             + 'loan_amount_daily = ?, '
             + 'loan_amount_monthly = ?, '
             + 'loan_amount_target = ?, '
             + 'loan_amount_percentage = ?, '
             + 'f_account_daily = ?, '
             + 'f_account_monthly = ?, '
             + 'f_account_target = ?, '
             + 'f_account_percentage = ?, '
             + 'f_balance_daily = ?, '
             + 'f_balance_monthly = ?, '
             + 'f_balance_target = ?, '
             + 'f_balance_percentage = ?, '
             + 'real_time_last_update_date = ?, '
             + 'transfer_daily = ?, '
             + 'transfer_monthly = ?, '
             + 'transfer_target = ?, '
             + 'transfer_percentage = ?, '
             + 'daily_last_update_date = ? '
             + 'where area_code = ? '
             + 'and branch_code = ?');

           if (upd_stmt = *NULL);
               R_SQLErrMsg = 'Prepare statement for update to md_kpi_value' +
                             ' failed!';
               R_SQLErrCde = 'UME0001';
               return *OFF;
           endif;

           JDBC_SetDecimal   (upd_stmt:  1: n_loan_daily );
           JDBC_setDecimal   (upd_stmt:  2: n_loan_month );
           JDBC_setDecimal   (upd_stmt:  3: n_loan_target);
           JDBC_setDecimal   (upd_stmt:  4: n_loan_percen);
           JDBC_setDecimal   (upd_stmt:  5: ln_amt_daily );
           JDBC_setDecimal   (upd_stmt:  6: ln_amt_month );
           JDBC_setDecimal   (upd_stmt:  7: ln_amt_target);
           JDBC_setDecimal   (upd_stmt:  8: ln_amt_percen);
           JDBC_setDecimal   (upd_stmt:  9: f_acc_daily  );
           JDBC_setDecimal   (upd_stmt: 10: f_acc_month  );
           JDBC_setDecimal   (upd_stmt: 11: f_acc_target );
           JDBC_setDecimal   (upd_stmt: 12: f_acc_percen );
           JDBC_setDecimal   (upd_stmt: 13: f_bal_daily  );
           JDBC_setDecimal   (upd_stmt: 14: f_bal_month  );
           JDBC_setDecimal   (upd_stmt: 15: f_bal_target );
           JDBC_setDecimal   (upd_stmt: 16: f_bal_percen );
           JDBC_SetTimestamp (upd_stmt: 17: real_upd_dat );
           JDBC_setDecimal   (upd_stmt: 18: tfr_daily    );
           JDBC_setDecimal   (upd_stmt: 19: tfr_month    );
           JDBC_setDecimal   (upd_stmt: 20: tfr_target   );
           JDBC_setDecimal   (upd_stmt: 21: tfr_percen   );
           JDBC_SetTimestamp (upd_stmt: 22: daily_upd_dat);
           JDBC_setString    (upd_stmt: 23: area         );
           JDBC_setString    (upd_stmt: 24: branch       );
       endif;

       upd_rc = JDBC_ExecPrepUpd( upd_stmt );
       if (upd_rc < 0);
           R_SQLErrMsg = 'Execute updating to table md_kpi_value failed!';
           R_SQLErrCde = 'UME0001';
           return *OFF;
       endif;

       JDBC_FreePrepStmt( upd_stmt );

       return *ON;
      /end-free
     P                 E

