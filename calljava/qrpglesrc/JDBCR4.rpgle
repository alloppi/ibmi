     /*-                                                                            +
      * Copyright (c) 2006-2010 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABL      +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      * Service program to simplify the user of JDBC drivers from ILE RPG.
      *                                    Scott Klement, April 18, 2006
      *
      *   Before Compiling:
      *
      *   - You need the JDBC drivers (use pure Java ones) for your
      *     database to be installed on the iSeries.
      *
      *   - This was originally written for, and most testing has been
      *     done with the MySQL drivers.  But, other drivers should
      *     work as well.  For a MySQL slanted article, see the following:
      *        http://www.iseriesnetwork.com/article.cfm?id=52433
      *
      *   - You need the System Openness Includes (5722-SS1 opt 13)
      *       licensed program installed.
      *
      *   - You need JDK 1.3 or later (JDK 1.4 recommended!)
      *
      *
      *   To Compile:
      *>    CRTRPGMOD JDBCR4 SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *        ( Note: this is the JDBCR4.rpgle source member. )
      *
      *>    CRTSRVPGM SRVPGM(JDBCR4) -
      *>              EXPORT(*SRCFILE) SRCFILE(QSRVSRC)
      *        ( Note: this is the JDBCR4.bnd source member. )
      *
      *     CRTBNDDIR BNDDIR(mylib/JDBC)
      *     ADDBNDDIRE BNDDIR(mylib/JDBC) OBJ((JDBCR4 *SRVPGM))
     H NOMAIN

      /define OS400_JVM_12
      /define JNI_COPY_CALL_METHOD_FUNCTIONS
      /copy qsysinc/qrpglesrc,jni
      /copy qcpysrc,jdbc_h

     D new_Driver      PR                  like(Driver)
     D   driver_name                256A   varying const
     D jni_checkError  PR             1N
     D    errString                 256A   varying options(*omit)
     D jdbc_get_jni_env...
     D                 PR              *
     D jdbc_begin_object_group...
     D                 PR            10I 0
     D    peCapacity                 10I 0 value
     D jdbc_end_object_group...
     D                 PR            10I 0
     D   peOldObj                          like(jObject) const
     D                                     options(*nopass)
     D   peNewObj                          like(jObject)
     D                                     options(*nopass)
     D attach_jvm      PR              *
     D start_jvm       PR              *
     D JniVersion      PR            10P 5
     D Timezone        PR            10I 0

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                     80A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32767A   options(*varsize)
     D status          PR             1N
     D   peMsgTxt                   256A   const
     D MsgKey          s              4A
     D ErrCode         s              8A   inz(x'0000000000000000')

     D Object          s               O   CLASS(*JAVA:
     D                                     'java.lang.Object')
     D Driver          s               O   CLASS(*JAVA:
     D                                     'java.sql.Driver')
     D BigDecimal      s               O   CLASS(*JAVA:
     D                                     'java.math.BigDecimal')
     D jSqlDate        s               O   CLASS(*JAVA:
     D                                     'java.sql.Date')
     D jSqlTime        s               O   CLASS(*JAVA:
     D                                     'java.sql.Time')
     D jSqlTimestamp   s               O   CLASS(*JAVA:
     D                                     'java.sql.Timestamp')

     D createStatement...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'createStatement')
     D                                     like(Statement)

     D PrepareStatement...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'prepareStatement')
     D                                     like(PreparedStatement)
     D    sql                              like(jString) const

     D PrepareCall...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'prepareCall')
     D                                     like(CallableStatement)
     D    sql                              like(jString) const

     D executeQuery...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.Statement':
     D                                     'executeQuery')
     D                                     like(ResultSet)
     D   query                             like(jString) const

     D executeUpdate...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.Statement':
     D                                     'executeUpdate')
     D                                     like(jInt)
     D   query                             like(jString) const

     D getMetaData...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSet':
     D                                     'getMetaData')
     D                                     like(ResultSetMetaData)

     D getColumnCount...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSetMetaData':
     D                                     'getColumnCount')
     D                                     like(jInt)

     D getColumnName...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSetMetaData':
     D                                     'getColumnName')
     D                                     like(jString)
     D    colIndex                         like(jInt) value

     D getColumnDisplaySize...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSetMetaData':
     D                                     'getColumnDisplaySize')
     D                                     like(jInt)
     D    colIndex                         like(jInt) value

     D getColumnTypeName...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSetMetaData':
     D                                     'getColumnTypeName')
     D                                     like(jString)
     D    colIndex                         like(jInt) value

     D nextRec...
     D                 PR             1N   ExtProc(*JAVA:
     D                                     'java.sql.ResultSet':
     D                                     'next')

     D prevRec...
     D                 PR             1N   ExtProc(*JAVA:
     D                                     'java.sql.ResultSet':
     D                                     'last')

     D getColString...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.ResultSet':
     D                                     'getString')
     D                                     like(jString)
     D    colIndex                         like(jInt) value

     D getColStrByName...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.ResultSet'
     D                                     :'getString')
     D                                     like(jString)
     D    colName                          like(jString)

     D closeConn       PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'close')

     D setCommit       PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'setAutoCommit')
     D flag                           1N   value

     D commitTrn       PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'commit')

     D rollbackTrn     PR                  ExtProc(*JAVA:
     D                                     'java.sql.Connection':
     D                                     'rollback')

     D s               PR                  like(jString)
     D                                     EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D create_from                32767A   VARYING const

     D new_StringC     PR                  like(jString)
     D                                     EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D create_from                16383c   VARYING const

     D r               pr         32767A   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'getBytes')

     D c               pr         16383C   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'toCharArray')

     D new_Properties  PR                  ExtProc(*JAVA
     D                                     :'java.util.Properties'
     D                                     :*CONSTRUCTOR)
     D                                     like(Properties)

     D setProperty     PR                  ExtProc(*JAVA
     D                                     :'java.util.Properties'
     D                                     :'setProperty')
     D                                     like(Object)
     D   key                               like(jString) const
     D   value                             like(jString) const

     D registerDriver  PR                  ExtProc(*JAVA
     D                                     :'java.sql.DriverManager'
     D                                     :'registerDriver')
     D                                     static
     D   drv                               like(Driver)

     D Driver_ConnProp...
     D                 PR                  like(Connection)
     D   drv                               like(Driver) value
     D   url                        256A   varying const options(*varsize)
     D   prop                              like(Properties) value
     D Driver_connect  PR                  like(Connection)
     D   drv                               like(Driver) value
     D   url                        256A   varying const options(*varsize)
     D   user                        50a   varying const options(*varsize)
     D   pass                        50a   varying const options(*varsize)

     D new_BigDecimal  PR                  ExtProc(*JAVA
     D                                     :'java.math.BigDecimal'
     D                                     :*CONSTRUCTOR)
     D                                     like(BigDecimal)
     D   str                               like(jString) const

     D new_Date        PR                  ExtProc(*JAVA
     D                                     :'java.sql.Date'
     D                                     :*CONSTRUCTOR)
     D                                     like(jSqlDate)
     D   milli                             like(jLong) value

     D new_Time        PR                  ExtProc(*JAVA
     D                                     :'java.sql.Time'
     D                                     :*CONSTRUCTOR)
     D                                     like(jSqlTime)
     D   milli                             like(jLong) value

     D new_Timestamp   PR                  ExtProc(*JAVA
     D                                     :'java.sql.Timestamp'
     D                                     :*CONSTRUCTOR)
     D                                     like(jSqlTimestamp)
     D   milli                             like(jLong) value

     D setBigDecimal...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setBigDecimal')
     D   idx                               like(jInt) value
     D   dec                               like(BigDecimal) const

     D setDate...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setDate')
     D   idx                               like(jInt) value
     D   date                              like(jSqlDate) const

     D setTime...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setTime')
     D   idx                               like(jInt) value
     D   time                              like(jSqlTime) const

     D setTimestamp...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setTimestamp')
     D   idx                               like(jInt) value
     D   ts                                like(jSqlTimestamp) const

     D setDouble...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setDouble')
     D   idx                               like(jInt) value
     D   dubba                             like(jDouble) value

     D setInt...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setInt')
     D   idx                               like(jInt) value
     D   int                               like(jInt) value

     D setString...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setString')
     D   idx                               like(jInt) value
     D   str                               like(jString) const

     D setByte...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'setByte')
     D   idx                               like(jInt) value
     D   byte                              like(jByte) value

     D registerOutParameter...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.CallableStatement'
     D                                     :'registerOutParameter')
     D   idx                               like(jInt) value
     D   type                              like(jInt) value

     D getString...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getString')
     D                                     like(jString)
     D    idx                              like(jInt) value

     D getInt...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getInt')
     D                                     like(jInt)
     D    idx                              like(jInt) value

     D getShort...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getShort')
     D                                     like(jShort)
     D    idx                              like(jInt) value

     D getDouble...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getDouble')
     D                                     like(jDouble)
     D   idx                               like(jInt) value

     D getBigDecimal...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getBigDecimal')
     D                                     like(BigDecimal)
     D   idx                               like(jInt) value

     D getLong...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getLong')
     D                                     like(jLong)
     D   idx                               like(jInt) value

     D getTimestamp...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getTimestamp')
     D                                     like(jSqlTimestamp)
     D   idx                               like(jInt) value

     D getTime...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getTime')
     D                                     like(jSqlTime)
     D   idx                               like(jInt) value

     D getDate...
     D                 PR                  ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getDate')
     D                                     like(jSqlDate)
     D   idx                               like(jInt) value

     D getBoolean...
     D                 PR             1N   ExtProc(*JAVA:
     D                                     'java.sql.CallableStatement':
     D                                     'getBoolean')
     D   idx                               like(jInt) value

     D prepExecuteQuery...
     D                 PR                  ExtPRoc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'executeQuery')
     D                                     like(ResultSet)

     D prepExecuteUpdate...
     D                 PR                  ExtPRoc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'executeUpdate')
     D                                     like(jInt)

     D callExecute...
     D                 PR             1N   ExtProc(*JAVA
     D                                     :'java.sql.CallableStatement'
     D                                     :'execute')

     D prepExecute...
     D                 PR             1N   ExtProc(*JAVA
     D                                     :'java.sql.PreparedStatement'
     D                                     :'execute')

     D Exception_getMessage...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.lang.Throwable'
     D                                     :'getMessage')
     D                                     like(jstring)

     D rs_getStatement...
     D                 PR                  ExtProc(*JAVA
     D                                     :'java.sql.ResultSet'
     D                                     :'getStatement')
     D                                     like(Statement)

     D stmt_Close      PR                  ExtProc(*JAVA
     D                                     :'java.sql.Statement'
     D                                     :'close')

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * MySQL_Connect(): Create a connection to a MYSQL server
      *
      *    server = (input) mysql server to connect to
      *  database = (input) database to use on server
      *    userid = (input) userid to log in with
      *  password = (input) password to log in with
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P MySQL_Connect   B                   export
     D MySQL_Connect   PI                  like(Connection)
     D   server                     256A   varying const options(*varsize)
     D   database                   256A   varying const options(*varsize)
     D   userid                      50A   varying const options(*varsize)
     D   password                    50A   varying const options(*varsize)

     D url             s            256A   varying
     D conn            s                   like(Connection)

      /free
         url = 'jdbc:mysql://' + %trim(server) + '/'
             + %trim(database);

         conn = JDBC_connect('com.mysql.jdbc.Driver'
                            : url
                            : userid
                            : password );

         return conn;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_Connect(): Create a connection using JDBC driver
      *
      *    driver = (input) Java class name of JDBC driver to use
      *       url = (input) JDBC URL of database to connect to
      *    userid = (input) userid to log in with
      *  password = (input) password to log in with
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Connect    B                   export
     D JDBC_Connect    PI                  like(Connection)
     D   drivname                   256A   varying const options(*varsize)
     D   url                        256A   varying const options(*varsize)
     D   userid                      50A   varying const options(*varsize)
     D   password                    50A   varying const options(*varsize)

     D drv             s                   like(Driver)
     D temp            s                   like(Connection)
     D conn            s                   like(Connection)
     D prop            s                   like(Properties)

      /free
          prop = JDBC_Properties();
          JDBC_setProp(prop: 'user': userid);
          JDBC_setProp(prop: 'password': password);
          conn = JDBC_ConnProp(drivname: url: prop);
          JDBC_freeProp(prop);
          return conn;

          // ----------------------------------------------
          //  The following code currently does not work
          //  because there is no 'connect(url,user,pass)'
          //  method in java.sql.Driver.
          // ----------------------------------------------

          jdbc_begin_object_group(50);

          monitor;
          // Find & Instantiate Driver

             drv = new_Driver(drivname);
             if (drv = *NULL);
                jdbc_end_object_group();
                return *NULL;
             endif;

          // Register with DriverManager
          //   and connect.

             registerDriver(drv);
             temp = Driver_Connect( drv : url: userid: password);
             if (temp = *NULL);
                jdbc_end_object_group();
                return *NULL;
             endif;

             jdbc_end_object_group(temp: conn);
             return conn;
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ConnProp(): Connect to database w/properties object
      *
      *    driver = (input) Java class name of JDBC driver to use
      *       url = (input) JDBC URL to connect to
      *      prop = (input) properties to use when connecting
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ConnProp   B                   export
     D JDBC_ConnProp   PI                  like(Connection)
     D   drivname                   256A   varying const options(*varsize)
     D   url                        256A   varying const options(*varsize)
     D   prop                              like(Properties)
     D drv             s                   like(Driver)
     D temp            s                   like(Connection)
     D conn            s                   like(Connection)
      /free
          jdbc_begin_object_group(50);

          monitor;
          // Find & Instantiate Driver

             drv = new_Driver(drivname);
             if (drv = *NULL);
                jdbc_end_object_group();
                return *NULL;
             endif;

          // Register with DriverManager
          //   and connect.

             registerDriver(drv);
             temp = Driver_ConnProp( drv : url: prop );
             if (temp = *NULL);
                jdbc_end_object_group();
                return *NULL;
             endif;

             jdbc_end_object_group(temp: conn);
             return conn;
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Properties():  Create new properties object
      *
      *  returns the object.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Properties...
     P                 B                   export
     D JDBC_Properties...
     D                 PI                  like(Properties)
     D prop            s                   like(Properties)
      /free
         jdbc_get_jni_env();
         prop = new_Properties();
         return prop;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_setProp():  Set one property in Properties object
      *
      *     prop = (i/o) Properties object to set property in
      *      key = (input) property to set
      *    value = (input) value to assign to property
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_setProp    B                   export
     D JDBC_setProp    PI
     D   prop                              like(Properties)
     D   key                        256A   varying const options(*varsize)
     D   value                      256A   varying const options(*varsize)
     D keystr          s                   like(jString)
     D valstr          s                   like(jString)
      /free
         keystr = s(key);
         valstr = s(value);
         setProperty(prop: keystr: valstr);
         DeleteLocalRef(JNIENV_P: keystr);
         DeleteLocalRef(JNIENV_P: valstr);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_freeProp():  Release properties object
      *
      *     prop = (i/o) Properties object to release
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_freeProp   B                   export
     D JDBC_freeProp   PI
     D   prop                              like(Properties)
      /free
         DeleteLocalRef(JNIENV_P: prop);
         prop = *NULL;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This calls the JNI functions to retrieve a JDBC driver
      * object based on the class name.
      *
      *    driver_name = (input) Java class name of JDBC driver
      *
      * returns new java.sql.Driver object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P new_Driver      B
     D new_Driver      PI                  like(Driver)
     D   driver_name                256A   varying const

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   len                          5P 0 const
     D   data                     32702A   options(*varsize)
     D   table                       10A   const

     D                 ds
     D   drv_name                   256A   varying
     D   drv_fixed                  256A   overlay(drv_name:3)

     D CONSTRUCTOR     C                   x'3c696e69743e'
     D NPARMVOID       C                   x'282956'

     D env             s               *   static inz(*NULL)
     D msg             s            256A   varying
     D cls             s                   like(jclass)
     D mid             s                   like(jmethodid)
     D obj             s                   like(Driver)
      /free
          if (env = *NULL);
              env = jdbc_get_jni_env();
          endif;

          drv_name = %xlate('.': '/': driver_name);
          QDCXLATE(%len(drv_name): drv_fixed: 'QTCPASC');

          cls = FindClass(env: drv_name);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( cls = *NULL );
             msg = 'Class ' + driver_name + ' not found!';
             exsr DiagMsg;
             return *NULL;
          endif;

          mid = GetMethodID(env: cls: CONSTRUCTOR: NPARMVOID);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( mid = *NULL );
             msg = 'Constructor method for ' + driver_name
                 + ' not found!';
             exsr DiagMsg;
             return *NULL;
          endif;

          obj = NewObject(env: cls: mid);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( obj = *NULL );
               msg = 'Null returned when attempting to create '
                   + driver_name + ' object';
               exsr DiagMsg;
               return *NULL;
          endif;

          return obj;

          begsr DiagMsg;
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : msg
                      : %len(msg)
                      : '*DIAG'
                      : '*'
                      : 0
                      : MsgKey
                      : ErrCode );
          endsr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Driver_ConnProp(): This calls the JNI routines (directly)
      *   to connect a driver to a data source.
      *
      * NOTE: I used the JNI routines instead of RPG's SQL support
      *       because I have more control over the error checking.
      *
      *      drv = (input) driver object to connect with
      *      url = (input) JDBC url to server
      *     prop = (input) connection properties
      *
      * Returns a Connection object, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Driver_ConnProp...
     P                 B
     D Driver_ConnProp...
     D                 PI                  like(Connection)
     D   drv                               like(Driver) value
     D   url                        256A   varying const options(*varsize)
     D   prop                              like(Properties) value

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   len                          5P 0 const
     D   data                     32702A   options(*varsize)
     D   table                       10A   const

     D clsDriver       s             15A   inz('java/sql/Driver')
     D methConn        s              7A   inz('connect')
     D sigConn         s             63A   inz('(Ljava/lang/String;-
     D                                     Ljava/util/Properties;)-
     D                                     Ljava/sql/Connection;')
     D CallConnectMethod...
     D                 PR                  LIKE(jobject)
     D                                     EXTPROC(*CWIDEN
     D                                     : JNINativeInterface.
     D                                       CallObjectMethod_P)
     D env                                 LIKE(JNIEnv_P) VALUE
     D obj                                 LIKE(jobject) VALUE
     D methodID                            LIKE(jmethodID) VALUE
     D drv                                 LIKE(Driver) VALUE
     D                                     options(*nopass)
     D url                                 LIKE(jString) VALUE
     D                                     options(*nopass)
     D prop                                LIKE(Properties) VALUE
     D                                     options(*nopass)

     D msg             s            256A   varying
     D cls             s                   like(jclass)
     D mid             s                   like(jmethodid)
     D conn            s                   like(Connection)
     D str             s                   like(jString)

      /free

          QDCXLATE( %size(clsDriver)
                  : clsDriver
                  : 'QTCPASC');
          QDCXLATE( %size(methConn)
                  : methConn
                  : 'QTCPASC');
          QDCXLATE( %size(sigConn)
                  : sigConn
                  : 'QTCPASC');

          cls = FindClass(JNIENV_P: clsDriver);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( cls = *NULL );
               msg = 'Class java.sql.Driver not found!';
               exsr DiagMsg;
               return *NULL;
          endif;

          mid = GetMethodID(JNIENV_P: cls: methConn: sigConn);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( mid = *NULL );
               msg = 'Connect method not found in java.sql.Driver'
                   + ' class!';
               exsr DiagMsg;
               return *NULL;
          endif;

          status('Connecting to database...');

          str = s(url);
          conn = CallConnectMethod(JNIENV_P: drv: mid: str: prop);
          status('.');
          if (jni_CheckError(*omit));
             return *NULL;
          endif;
          DeleteLocalRef(JNIENV_P: str);

          if ( conn = *NULL );
               msg = 'Unable to connect.';
               exsr DiagMsg;
               return *NULL;
          endif;

          return conn;

          begsr DiagMsg;
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : msg
                      : %len(msg)
                      : '*DIAG'
                      : '*'
                      : 0
                      : MsgKey
                      : ErrCode );
          endsr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Driver_connect(): This calls the JNI routines (directly)
      *   to connect a driver to a data source.
      *
      * NOTE: I used the JNI routines instead of RPG's SQL support
      *       because I have more control over the error checking.
      *
      *      drv = (input) driver object to connect with
      *      url = (input) JDBC url to server
      *     user = (input) userid to connect with
      *     pass = (input) password to connect with
      *
      * Returns a Connection object, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Driver_connect  B
     D Driver_connect  PI                  like(Connection)
     D   drv                               like(Driver) value
     D   url                        256A   varying const options(*varsize)
     D   user                        50a   varying const options(*varsize)
     D   pass                        50a   varying const options(*varsize)

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   len                          5P 0 const
     D   data                     32702A   options(*varsize)
     D   table                       10A   const

     D clsDriver       s             15A   inz('java/sql/Driver')
     D methConn        s              7A   inz('connect')
     D sigConn         s             77A   inz('(Ljava/lang/String;-
     D                                     Ljava/lang/String;-
     D                                     Ljava/lang/String;)-
     D                                     Ljava/sql/Connection;')
     D CallConnectMethod...
     D                 PR                  LIKE(jobject)
     D                                     EXTPROC(*CWIDEN
     D                                     : JNINativeInterface.
     D                                       CallObjectMethod_P)
     D env                                 LIKE(JNIEnv_P) VALUE
     D obj                                 LIKE(jobject) VALUE
     D methodID                            LIKE(jmethodID) VALUE
     D drv                                 LIKE(Driver) VALUE
     D                                     options(*nopass)
     D url                                 LIKE(jString) VALUE
     D                                     options(*nopass)
     D userid                              LIKE(jString) VALUE
     D                                     options(*nopass)
     D passwd                              LIKE(jString) VALUE
     D                                     options(*nopass)

     D msg             s            256A   varying
     D cls             s                   like(jclass)
     D mid             s                   like(jmethodid)
     D conn            s                   like(Connection)
     D urlstr          s                   like(jString)
     D userstr         s                   like(jString)
     D passstr         s                   like(jString)

      /free

          QDCXLATE( %size(clsDriver)
                  : clsDriver
                  : 'QTCPASC');
          QDCXLATE( %size(methConn)
                  : methConn
                  : 'QTCPASC');
          QDCXLATE( %size(sigConn)
                  : sigConn
                  : 'QTCPASC');

          cls = FindClass(JNIENV_P: clsDriver);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( cls = *NULL );
               msg = 'Class java.sql.Driver not found!';
               exsr DiagMsg;
               return *NULL;
          endif;

          mid = GetMethodID(JNIENV_P: cls: methConn: sigConn);
          if (jni_CheckError(*omit));
             return *NULL;
          endif;

          if ( mid = *NULL );
               msg = 'Connect method not found in java.sql.Driver'
                   + ' class!';
               exsr DiagMsg;
               return *NULL;
          endif;

          status('Connecting to database...');

          urlstr  = s(url);
          userstr = s(url);
          passstr = s(url);

          conn = CallConnectMethod( JNIENV_P
                                  : drv
                                  : mid
                                  : urlstr
                                  : userstr
                                  : passstr );
          status('.');
          if (jni_CheckError(*omit));
             return *NULL;
          endif;
          DeleteLocalRef(JNIENV_P: urlstr);
          DeleteLocalRef(JNIENV_P: userstr);
          DeleteLocalRef(JNIENV_P: passstr);

          if ( conn = *NULL );
               msg = 'Unable to connect.';
               exsr DiagMsg;
               return *NULL;
          endif;

          return conn;

          begsr DiagMsg;
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : msg
                      : %len(msg)
                      : '*DIAG'
                      : '*'
                      : 0
                      : MsgKey
                      : ErrCode );
          endsr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_ExecUpd():  Execute a Query that doesn't return results
      *
      *     conn = (input) database connection
      *      sql = (input) SQL Code to execute
      *
      *  returns a row count, or 0 where a row count is not applicable
      *        or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ExecUpd    B                   export
     D JDBC_ExecUpd    PI            10I 0
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)
     D rc              s             10I 0
     D stmt            s                   like(Statement)
      /free
          jdbc_begin_object_group(50);

          monitor;
             stmt = createStatement( conn );
             rc = executeUpdate( stmt : s(sql));
             stmt_close(stmt);
             jdbc_end_object_group();
          on-error;
             jdbc_end_object_group();
             return -1;
          endmon;
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_ExecQry():  Execute a Query that returns a result
      *
      *     conn = (input) database connection
      *      sql = (input) SQL code to execute
      *
      *  Returns a result handle, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ExecQry    B                   export
     D JDBC_ExecQry    PI                  like(ResultSet)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)
     D stmt            s                   like(Statement)
     D temp            s                   like(ResultSet)
     D rs              s                   like(ResultSet)
      /free
          jdbc_begin_object_group(50);

          monitor;
             stmt = createStatement( conn );
             temp = executeQuery( stmt : s(sql));
             jdbc_end_object_group(temp: rs);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;

          return rs;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepStmt(): Create a Prepared Statement
      *
      *    conn = (input) Connection to prepare statement for
      *     sql = (input) SQL statement to prepare
      *
      * Returns a prepared statement object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_PrepStmt   B                   export
     D JDBC_PrepStmt   PI                  like(PreparedStatement)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)
     D temp            s                   like(PreparedStatement)
     D stmt            s                   like(PreparedStatement)
      /free
          jdbc_begin_object_group(50);

          monitor;
             temp = prepareStatement( conn : s(sql) );
             jdbc_end_object_group(temp: stmt);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;

          return stmt;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepStmtC(): Create a Prepared Statement
      *                   from a Unicode String
      *
      *    conn = (input) Connection to prepare statement for
      *     sql = (input) SQL statement to prepare
      *
      * Returns a prepared statement object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_PrepStmtC  B                   export
     D JDBC_PrepStmtC  PI                  like(PreparedStatement)
     D   conn                              like(Connection) const
     D   sql                      16383c   varying const options(*varsize)
     D temp            s                   like(PreparedStatement)
     D stmt            s                   like(PreparedStatement)
      /free
          jdbc_begin_object_group(50);

          monitor;
             temp = prepareStatement( conn : new_StringC(sql) );
             jdbc_end_object_group(temp: stmt);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;

          return stmt;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepCall(): Create a Prepared Call
      *
      *    conn = (input) Connection to prepare call for
      *     sql = (input) SQL call to prepare
      *
      * Returns a prepared call object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_PrepCall   B                   export
     D JDBC_PrepCall   PI                  like(CallableStatement)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)
     D temp            s                   like(CallableStatement)
     D stmt            s                   like(CallableStatement)
      /free
          jdbc_begin_object_group(50);

          monitor;
             temp = prepareCall( conn : s(sql) );
             jdbc_end_object_group(temp: stmt);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;
          return stmt;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepCallC(): Create a Prepared Call
      *                   using a Unicode string
      *
      *    conn = (input) Connection to prepare call for
      *     sql = (input) SQL call to prepare
      *
      * Returns a prepared call object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_PrepCallC  B                   export
     D JDBC_PrepCallC  PI                  like(CallableStatement)
     D   conn                              like(Connection) const
     D   sql                      16383C   varying const options(*varsize)
     D temp            s                   like(CallableStatement)
     D stmt            s                   like(CallableStatement)
      /free
          jdbc_begin_object_group(50);

          monitor;
             temp = prepareCall( conn : new_StringC(sql) );
             jdbc_end_object_group(temp: stmt);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;
          return stmt;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetMetaData():  Get ResultSet MetaData
      *
      *       rs = (input) ResultSet handle
      *
      *  Returns a ResultSet MetaData object, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetMetaData...
     P                 B                   export
     D JDBC_GetMetaData...
     D                 PI                  like(ResultSetMetaData)
     D   rs                                like(ResultSet)
     D temp            s                   like(ResultSetMetaData)
     D rsmd            s                   like(ResultSetMetaData)
      /free
          jdbc_begin_object_group(50);
          monitor;
             temp = getMetaData( rs );
             jdbc_end_object_group(temp: rsmd);
          on-error;
             jdbc_end_object_group();
             return *NULL;
          endmon;
          return rsmd;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColCount():  Get ResultSet Column Count
      *
      *       rsmd = (input) ResultSet MetaData handle
      *
      *  Returns column count
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColCount...
     P                 B                   export
     D JDBC_GetColCount...
     D                 PI            10I 0
     D   rsmd                              like(ResultSetMetaData)
     D colcnt          s                   like(jInt)
      /free
          jdbc_begin_object_group(50);
          monitor;
             colcnt = getColumnCount( rsmd );
          on-error;
             colcnt = 0;
          endmon;
          jdbc_end_object_group();
          return colcnt;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColName():  Get column name from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column name if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColName...
     P                 B                   export
     D JDBC_GetColName...
     D                 PI           256A   varying
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value
     D result          s            256A   varying
     D str             s                   like(jString)
      /free
          jdbc_begin_object_group(10);
          monitor;
             str = getColumnName(rsmd: col);
             if (str = *NULL);
                result = '';
             else;
                result = r(str);
             endif;
          on-error;
             result = '';
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColDspSize():  Get column display size from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column display size
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColDspSize...
     P                 B                   export
     D JDBC_GetColDspSize...
     D                 PI            10I 0
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value
     D colsize         s                   like(jInt)
      /free
          jdbc_begin_object_group(10);
          monitor;
             colsize = getColumnDisplaySize(rsmd: col);
          on-error;
             colsize = 0;
          endmon;
          jdbc_end_object_group();
          return colsize;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColTypeName():  Get column SQL type name from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column SQL type name if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColTypName...
     P                 B                   export
     D JDBC_GetColTypName...
     D                 PI           256A   varying
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value
     D result          s            256A   varying
     D str             s                   like(jString)
      /free
          jdbc_begin_object_group(10);
          monitor;
             str = getColumnTypeName(rsmd: col);
             if (str = *NULL);
                result = '';
             else;
                result = r(str);
             endif;
          on-error;
             result = '';
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetString(): Set a string in a prepared statement
      *
      *    prep = (input) Prepared statement to set string in
      *     idx = (input) Parameter index to set
      *     str = (input) String to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetString...
     P                 B                   export
     D JDBC_SetString...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   str                      32767A   varying const options(*varsize)
     D   null                         1N   const options(*nopass)
     D result          s              1n
      /free
          jdbc_begin_object_group(10);

          monitor;
             if (%parms>=4 and null=*ON);
                setString( prep: idx: *NULL);
             else;
                setString( prep: idx: s(str));
             endif;
             result = *ON;
          on-error;
             result = *OFF;
          endmon;

          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetStringC(): Set a string in a prepared statement
      *                    using Unicode input
      *
      *    prep = (input) Prepared statement to set string in
      *     idx = (input) Parameter index to set
      *     str = (input) String to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetStringC...
     P                 B                   export
     D JDBC_SetStringC...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   str                      16383C   varying const options(*varsize)
     D   null                         1N   const options(*nopass)
     D result          s              1n
      /free
          jdbc_begin_object_group(10);

          monitor;
             if (%parms>=4 and null=*ON);
                setString( prep: idx: *NULL);
             else;
                setString( prep: idx: new_StringC(str));
             endif;
             result = *ON;
          on-error;
             result = *OFF;
          endmon;

          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetInt(): Set an integer in a prepared statement
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *     int = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetInt     B                   export
     D JDBC_SetInt     PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   int                         10I 0 value
     D   null                         1N   const options(*nopass)
     D result          s              1n
      /free
          jdbc_begin_object_group(10);
          monitor;
             if (%parms>=4 and null=*ON);
                setString( prep: idx: *NULL);
             else;
                setInt( prep: idx: int);
             endif;
             result = *ON;
          on-error;
             result = *OFF;
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDouble(): Set a floating point value in a prepared
      *                    statement
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *  double = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetDouble...
     P                 B                   export
     D JDBC_SetDouble...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   double                       8F   value
     D   null                         1N   const options(*nopass)
     D result          s              1n
      /free
          jdbc_begin_object_group(10);
          monitor;
             if (%parms>=4 and null=*ON);
                setString( prep: idx: *NULL);
             else;
                setDouble( prep: idx: double);
             endif;
             result = *ON;
          on-error;
             result = *OFF;
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDecimal(): Set a decimal value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *     dec = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetDecimal...
     P                 B                   export
     D JDBC_SetDecimal...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   dec                         30P 9 value
     D   null                         1N   const options(*nopass)
     D result          s              1n
      /free
          jdbc_begin_object_group(10);
          monitor;
             if (%parms>=4 and null=*ON);
                setBigDecimal(prep: idx: *NULL);
             else;
                setBigDecimal(prep: idx: new_BigDecimal(s(%char(dec))));
             endif;
             result = *ON;
          on-error;
             result = *OFF;
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDate(): Set a date value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *    date = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetDate...
     P                 B                   export
     D JDBC_SetDate...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   date                          D   datfmt(*iso) const
     D   null                         1N   const options(*nopass)
     D jdt             s                   like(jSqlDate)
     D str             s                   like(jString)
     D rc              s              1N   inz(*ON)
     D Date_valueOf    PR                  like(jSqlDate)
     D                                     extproc(*java
     D                                     : 'java.sql.Date'
     D                                     : 'valueOf')
     D                                     static
     D   theDate                           like(jString)
      /free
          jdbc_begin_object_group(10);

          monitor;
             str = s(%char(date:*iso));
             jdt = Date_valueOf(str);
             if (jdt = *NULL);
                rc = *OFF;
             else;
                if (%parms>=4 and null=*ON);
                   setDate(prep: idx: *NULL);
                else;
                   setDate(prep: idx: jdt);
                endif;
                rc = *ON;
             endif;
          on-error;
             rc = *OFF;
          endmon;

          jdbc_end_object_group();
          return rc;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetTime(): Set a time value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *    time = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetTime...
     P                 B                   export
     D JDBC_SetTime...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   time                          T   timfmt(*hms) const
     D   null                         1N   const options(*nopass)
     D jtm             s                   like(jSqlTime)
     D str             s                   like(jString)
     D rc              s              1N   inz(*ON)
     D Time_valueOf    PR                  like(jSqlTime)
     D                                     extproc(*java
     D                                     : 'java.sql.Time'
     D                                     : 'valueOf')
     D                                     static
     D   theTime                           like(jString)
      /free
          if (JniVersion() < 1.00004);
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : 'JDK Version 1.4 or later required!'
                      : 80
                      : '*ESCAPE'
                      : '*PGMBDY'
                      : 1
                      : MsgKey
                      : ErrCode );
             return *OFF;
          endif;

          jdbc_begin_object_group(10);

          monitor;
             str = s(%char(time:*hms:));
             jtm = Time_valueOf(str);
             if (jtm = *NULL);
                rc = *OFF;
             else;
                if (%parms>=4 and null=*ON);
                   setTime(prep: idx: *NULL);
                else;
                   setTime(prep: idx: jtm);
                endif;
                rc = *ON;
             endif;
          on-error;
             rc = *OFF;
          endmon;

          jdbc_end_object_group();
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetTimestamp(): Set a timestamp value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *      ts = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_SetTimestamp...
     P                 B                   export
     D JDBC_SetTimestamp...
     D                 PI             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   ts                            Z   const
     D   null                         1N   const options(*nopass)
     D jts             s                   like(jSqlTimestamp)
     D charTS          s             29A   varying
     D str             s                   like(jString)
     D rc              s              1N   inz(*ON)
     D TS_valueOf      PR                  like(jSqlTimestamp)
     D                                     extproc(*java
     D                                     : 'java.sql.Timestamp'
     D                                     : 'valueOf')
     D                                     static
     D   theTS                             like(jString)
      /free
          if (JniVersion() < 1.00004);
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : 'JDK Version 1.4 or later required!'
                      : 80
                      : '*ESCAPE'
                      : '*PGMBDY'
                      : 1
                      : MsgKey
                      : ErrCode );
             return *OFF;
          endif;

          jdbc_begin_object_group(10);

          monitor;
             charTS = %char(ts:*iso) + '000';
             %subst(charTS:11:1) = ' ';
             %subst(charTS:14:1) = ':';
             %subst(charTS:17:1) = ':';
             str = s(charTS);
             jts = TS_valueOf(str);
             if (jts = *NULL);
                rc = *OFF;
             else;
                if (%parms>=4 and null=*ON);
                   setTimestamp(prep: idx: *NULL);
                else;
                   setTimestamp(prep: idx: jts);
                endif;
                rc = *ON;
             endif;
          on-error;
             rc = *OFF;
          endmon;

          jdbc_end_object_group();
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_RegisterOutParameter(): Register an output parameter
      *                           returned from a stored-proc call
      *
      *    call = (input) Callable statement to register output for
      *     idx = (input) Parameter index to register
      *    type = (input) Data type to register
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_RegisterOutParameter...
     P                 B                   export
     D JDBC_RegisterOutParameter...
     D                 PI
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D   type                        10I 0 value
      /free
          jdbc_begin_object_group(10);
          monitor;
             registerOutParameter( call: idx: type);
          on-error;
             // ignore error
          endmon;
          jdbc_end_object_group();
          return;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_GetString(): Get a string from a called statement
      *
      *    call = (input) Callable statement to get string from
      *     idx = (input) Parameter index to get
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetString...
     P                 B                   export
     D JDBC_GetString...
     D                 PI         32767A   varying
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D result          s          32767A   varying
     D str             s                   like(jString)
      /free
          jdbc_begin_object_group(10);

          monitor;
             str = getString( call: idx);
             if (str = *NULL);
                result = '';
             else;
                result = r(str);
             endif;
          on-error;
             result = '';
          endmon;

          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_GetInt(): Get an integer from a called statement
      *
      *    call = (input) Callable statement to get string from
      *     idx = (input) Parameter index to get
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetInt...
     P                 B                   export
     D JDBC_GetInt...
     D                 PI            10I 0
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D result          s             10I 0
      /free
          jdbc_begin_object_group(10);

          monitor;
             result = getInt( call: idx);
          on-error;
             result = 0;
          endmon;

          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_GetShort(): Get a short from a called statement
      *
      *    call = (input) Callable statement to get string from
      *     idx = (input) Parameter index to get
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetShort...
     P                 B                   export
     D JDBC_GetShort...
     D                 PI            10I 0
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D result          s             10I 0
     D short           s                   like(jShort)
      /free
          jdbc_begin_object_group(10);

          monitor;
             short = getShort( call: idx);
             if (short = 0);
                result = 0;
             else;
                result = short;
             endif;
          on-error;
             result = 0;
          endmon;

          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_GetBoolean(): Get a boolean from a called statement
      *
      *    call = (input) Callable statement to get string from
      *     idx = (input) Parameter index to get
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetBoolean...
     P                 B                   export
     D JDBC_GetBoolean...
     D                 PI             1N
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D result          s              1N
      /free
          jdbc_begin_object_group(10);
          monitor;
             result = getBoolean( call: idx);
          on-error;
             result = *OFF;
          endmon;
          jdbc_end_object_group();
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecPrepQry(): Execute a query from a prepared statement
      *
      *      prep = (input) prepared statement to execute
      *
      * Returns ResultSet object or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ExecPrepQry...
     P                 B                   export
     D JDBC_ExecPrepQry...
     D                 PI                  like(ResultSet)
     D   prep                              like(PreparedStatement) const
     D temp            s                   like(ResultSet)
     D rs              s                   like(ResultSet)
      /free
          jdbc_begin_object_group(50);
          monitor;
             temp = PrepExecuteQuery(prep);
             jdbc_end_object_group(temp: rs);
          on-error;
             jdbc_end_object_group();
             return *null;
          endmon;
          return rs;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecPrepUpd(): Execute SQL that doesn't return data
      *                     from a prepared statement
      *
      *      prep = (input) prepared statement to execute
      *
      * Returns 0 or a row count if successful
      *     or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ExecPrepUpd...
     P                 B                   export
     D JDBC_ExecPrepUpd...
     D                 PI            10I 0
     D   prep                              like(PreparedStatement) const
     D rc              s             10i 0
      /free
          jdbc_begin_object_group(50);
          monitor;
             rc = PrepExecuteUpdate(prep);
          on-error;
             rc = -1;
          endmon;
          jdbc_end_object_group();
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecCall(): Execute SQL statement that calls a stored
      *                     procedure
      *
      *      call = (input) callable statement to execute
      *
      * Returns *ON if first result is a ResultSet
      *      or *OFF if first result is an update count
      *
      * Use JDBC_moreResults(), JDBC_getUpdateCount() and
      *     JDBC_getResultSet() to get results of this function
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_ExecCall...
     P                 B                   export
     D JDBC_ExecCall...
     D                 PI             1N
     D   call                              like(CallableStatement) const
     D rc              s              1n
      /free
          jdbc_begin_object_group(50);
          monitor;
             rc = CallExecute(call);
          on-error;
             rc = *OFF;
          endmon;
          jdbc_end_object_group();
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_Execute(): Execute Prepared SQL Statement
      *
      *      stmt = (input) prepared statement to execute
      *
      * Returns *ON if first result is a ResultSet
      *      or *OFF if first result is an update count
      *
      * Use JDBC_moreResults(), JDBC_getUpdateCount() and
      *     JDBC_getResultSet() to get results of this function
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Execute...
     P                 B                   export
     D JDBC_Execute...
     D                 PI             1N
     D   stmt                              like(PreparedStatement) const
     D rc              s              1n
      /free
          jdbc_begin_object_group(50);
          monitor;
             rc = PrepExecute(stmt);
          on-error;
             rc = *OFF;
          endmon;
          return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_FreePrepStmt(): Free prepared statement
      *
      *    prep = (input) Prepared Statement to Free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_FreePrepStmt...
     P                 B                   export
     D JDBC_FreePrepStmt...
     D                 PI
     D   prep                              like(PreparedStatement)
      /free
         stmt_close(prep);
         DeleteLocalRef(JNIENV_P: prep);
         prep = *NULL;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_FreeCallStmt(): Free callable statement
      *
      *    call = (input) Callable Statement to Free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_FreeCallStmt...
     P                 B                   export
     D JDBC_FreeCallStmt...
     D                 PI
     D   call                              like(CallableStatement)
      /free
         DeleteLocalRef(JNIENV_P: call);
         call = *NULL;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_NextRow():  Position result to next row
      *
      *       rs = (input) Result handle to move
      *
      *  Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_NextRow    B                   export
     D JDBC_NextRow    PI             1N
     D   rs                                like(ResultSet)
      /free
          monitor;
             return nextRec(rs);
          on-error;
             return *OFF;
          endmon;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetCol():  Get column from current row
      *
      *       rs = (input) Result handle to use
      *      col = (input) column number to retrieve
      *  nullInd = (output/optional) will be set to *ON if the
      *             field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetCol     B                   export
     D JDBC_GetCol     PI         32767A   varying
     D   rs                                like(ResultSet)
     D   col                         10I 0 value
     D   nullInd                      1N   options(*nopass:*omit)
     D result          s          32767A   varying
     D str             s                   like(jstring)
     D null            s              1N   inz(*OFF)
      /free
          jdbc_begin_object_group(5);
          monitor;
             str = getColString(rs: col);
             if (str = *NULL);
                result = '';
                null = *ON;
             else;
                result = r(str);
             endif;
          on-error;
             null = *ON;
             result = '';
          endmon;
          jdbc_end_object_group();
          if (%parms >= 3 and %addr(nullInd)<>*NULL);
              nullInd = Null;
          endif;
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColC():  Get column from current row in Unicode
      *
      *       rs = (input) Result handle to use
      *      col = (input) column number to retrieve
      *  nullInd = (output/optional) will be set to *ON if the
      *             field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColC    B                   export
     D JDBC_GetColC    PI         16383C   varying
     D   rs                                like(ResultSet)
     D   col                         10I 0 value
     D   nullInd                      1N   options(*nopass:*omit)
     D result          s          16383c   varying
     D str             s                   like(jstring)
     D null            s              1N   inz(*OFF)
      /free
          jdbc_begin_object_group(5);
          monitor;
             str = getColString(rs: col);
             if (str = *NULL);
                result = %ucs2('');
                null = *ON;
             else;
                result = c(str);
             endif;
          on-error;
             null = *ON;
             result = %ucs2('');
          endmon;
          jdbc_end_object_group();
          if (%parms >= 3 and %addr(nullInd)<>*NULL);
              nullInd = Null;
          endif;
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_FreeResult(): Free result handle
      *
      *     rs = (input) Result handle to free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_FreeResult...
     P                 B                   export
     D JDBC_FreeResult...
     D                 PI
     D   rs                                like(ResultSet)
     D stmt            s                   like(Statement)
      /free
          stmt = rs_getStatement(rs);
          stmt_close(stmt);
          DeleteLocalRef(JNIENV_P: rs);
          DeleteLocalRef(JNIENV_P: stmt);
          rs = *NULL;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_setCommit(): Set auto commit flag
      *
      *     conn = (input) Connection to commit
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_setCommit  B                   export
     D JDBC_setCommit  PI
     D   conn                              like(Connection)
     D   flag                         1N   value
      /free
          setCommit(conn: flag);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Commit():  Commit transaction
      *
      *     conn = (input) Connection to commit on
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Commit     B                   export
     D JDBC_Commit     PI
     D   conn                              like(Connection)
      /free
          commitTrn(conn);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Rollback():  Rollback transaction
      *
      *     conn = (input) Connection to rollback on
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Rollback   B                   export
     D JDBC_Rollback   PI
     D   conn                              like(Connection)
      /free
          rollbackTrn(conn);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Close():  Close connection to server
      *                   and free connection handle
      *
      *     conn = (input) Connection to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_Close      B                   export
     D JDBC_Close      PI
     D   conn                              like(Connection)
      /free
          closeConn(conn);
          DeleteLocalRef(JNIENV_P: conn);
          conn = *NULL;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      *  jdbc_get_jni_env():
      *
      *  Service program utility to get a pointer to the JNI environment
      *  you'll need this pointer in order to call many of the JNI
      *  routines.
      *
      *  returns the pointer, or *NULL upon error
      *-----------------------------------------------------------------
     P jdbc_get_jni_env...
     P                 B
     D jdbc_get_jni_env...
     D                 PI              *

     D wwEnv           s               *

      /free
        wwEnv = attach_jvm();
        if (wwEnv = *NULL);
           wwEnv = start_jvm();
        endif;

        JNIENV_P = wwEnv;
        return wwEnv;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * jni_checkError():  Check for an error in JNI routines
      *-----------------------------------------------------------------
     P jni_checkError  B
     D jni_checkError  PI             1N
     D    errString                 256A   varying options(*omit)

     D sleep           pr            10I 0 extproc('sleep')
     D   intv                        10I 0 value

     D exc             s                   like(jthrowable)
     D str             s                   like(jstring)
     d msg             s            256A   varying
      /free
          if (%addr(errString) <> *NULL);
              %len(errString) = 0;
          endif;

          exc = ExceptionOccurred(JNIENV_P);
          if (exc = *NULL);
              return *OFF;
          endif;

          ExceptionDescribe(JNIENV_P);
          sleep(10);

          str = Exception_getMessage(exc);
          msg = r(str);
          DeleteLocalRef(JNIENV_P: str);

          SndPgmMsg( 'CPF9897'
                   : 'QCPFMSG   *LIBL'
                   : msg
                   : %len(msg)
                   : '*DIAG'
                   : '*'
                   : 0
                   : MsgKey
                   : ErrCode );

          if (%addr(errString) <> *NULL);
              errString = msg;
          endif;

          ExceptionClear(JNIENV_P);
          DeleteLocalRef(JNIENV_P: exc);

          return *ON;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * jdbc_begin_object_group():  Start a new group of objects
      *    which will all be freed when jdbc_end_object_group()
      *    gets called.
      *
      *   peCapacity = maximum number of objects that can be
      *        referenced within this object group.
      *
      *  NOTE: According to the 1.2 JNI Spec, you can create more
      *        objects in the new frame than peCapacity allows.  The
      *        peCapacity is the guarenteed number.   When no object
      *        groups are used, 16 references are guarenteed, so if
      *        you specify 16 here, that would be comparable to a
      *        "default value".
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     P jdbc_begin_object_group...
     P                 B
     D jdbc_begin_object_group...
     D                 PI            10I 0
     D    peCapacity                 10I 0 value

     D wwEnv           s               *
     D wwRC            s             10I 0

      /free

       wwEnv = jdbc_get_jni_env();
       if (wwEnv = *NULL);
           return -1;
       endif;

       if  ( PushLocalFrame (wwEnv: peCapacity) <> JNI_OK );
           return -1;
       else;
           return 0;
       endif;

      /end-free
     P                 E


      *-----------------------------------------------------------------
      * jdbc_end_object_group():  Frees all Java objects that
      *    have been created since calling jdbc_begin_object_group()
      *
      *        peOldObj = (see below)
      *        peNewObj = Sometimes it's desirable to preserve one
      *            object by moving it from the current object group
      *            to the parent group.   These parameters allow you
      *            to make that move.
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     P jdbc_end_object_group...
     P                 B
     D jdbc_end_object_group...
     D                 PI            10I 0
     D   peOldObj                          like(jObject) const
     D                                     options(*nopass)
     D   peNewObj                          like(jObject)
     D                                     options(*nopass)

     D wwOld           s                   like(jObject) inz(*NULL)
     D wwNew           s                   like(jObject)

      /free

          jdbc_get_jni_env();
          if (JNIENV_p = *NULL);
              return -1;
          endif;

          if %parms >= 2;
              wwOld = peOldObj;
          endif;

          wwNew = PopLocalFrame (JNIENV_p: wwOld);

          if %parms >= 2;
              peNewObj = wwNew;
          endif;

          return 0;

      /end-free
     P                 E


      *-----------------------------------------------------------------
      *  start_jvm():   Start the Java Virtual Machine (JVM)
      *
      *  NOTE: Originally, this called JNI routines to start a new JVM,
      *        but that meant that a classpath and other options needed
      *        to be set manually in the JNI invocation.
      *
      *        I decided that it would be better to reduce the complexity
      *        and let RPG start the JVM, so I merely create & destroy
      *        a string here so that RPG will automatically start the
      *        JVM for me.
      *
      *  returns a pointer to the JNI environment
      *          or *NULL upon failure.
      *-----------------------------------------------------------------
     P start_jvm       B
     D start_jvm       PI              *

     D wwStr           s                   like(jString)

      /free
         status('Starting Java Virtual Machine...');
         wwStr = s('Temp String');
         status('.');
         JNIENV_P = attach_jvm();
         DeleteLocalRef(JNIENV_P: wwStr);
         return JNIENV_P;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * attach_jvm():  Attach to JVM if it's running
      *
      * Returns a pointer to the JNI environment, or *NULL upon error
      *-----------------------------------------------------------------
     P attach_jvm      B
     D attach_jvm      PI              *

     D dsAtt           ds                  likeds(JavaVMAttachArgs)
     D wwJVM           s                   like(JavaVM_p) dim(1)
     D wwJVMc          s                   like(jSize)
     D wwEnv           s               *   inz(*null) static
     D wwRC            s             10I 0
      /free

        if (wwEnv <> *NULL);
           return wwEnv;
        endif;

        status('Attaching RPG program to Java Virtual Machine...');

        monitor;
           wwRC = JNI_GetCreatedJavaVMs(wwJVM: 1: wwJVMc);

           if (wwRC <> JNI_OK  or  wwJVMc = 0);
               return *NULL;
           endif;

           JavaVM_P = wwJVM(1);
           dsAtt = *ALLx'00';
           dsAtt.version = JNI_VERSION_1_2;

           wwRC = AttachCurrentThread (wwJVM(1): wwEnv: %addr(dsAtt));
           if (wwRC <> JNI_OK);
               wwEnv = *NULL;
           endif;

        on-error;
           wwEnv = *NULL;
        endmon;

        status('.');
        return wwEnv;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JniVersion(): Get version of current JNI environment
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JniVersion      B
     D JniVersion      PI            10P 5
     D                 ds
     D  ver                          10I 0
     D  high                          5I 0 overlay(ver:1)
     D  low                           5I 0 overlay(ver:*NEXT)
     D result          s             10P 5 static
      /free
         if (result = 0);
            ver = GetVersion(jdbc_get_jni_env());
            result = high + (low / 100000);
         endif;
         return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Get UTC offset (in seconds) for timezone.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Timezone        B
     D Timezone        PI            10I 0

     D CEEUTCO         PR
     D   hours                       10I 0
     D   mins                        10I 0
     D   secs                         8F
     D   fc                          12A   options(*omit)

     D utc_offset_set  s              1N   inz(*OFF) static
     D utc_offset      s             10I 0           static

     D junk1           s             10I 0 static
     D junk2           s             10I 0 static
     D junk3           s              8F   static

      /free

          if (utc_offset_set = *OFF);
             CEEUTCO(junk1:junk2:junk3:*omit);
             utc_offset = junk3;
             utc_offset_set = *ON;
          endif;
          return utc_offset;

      /end-free
     P                 E


     P status          B                   export
     D status          PI             1N
     D   peMsgTxt                   256A   const

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    1A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 inz(256)
     D  dsECBytesA             5      8I 0 inz(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c     ' '           checkr    peMsgTxt      wwMsgLen
     c                   if        wwMsgLen<1
     c                   return    *OFF
     c                   endif

     c                   callp     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsgTxt: wwMsgLen: '*STATUS':
     c                               '*EXT': 0: wwTheKey: dsEC)

     c                   if        dsECBytesA>0
     c                   return    *off
     c                   else
     c                   return    *on
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColByName():  Get column from current row by
      *                        column name
      *
      *          rs = (input) Result handle to use
      *  columnName = (input) column name to retrieve
      *     nullInd = (output/optional) will be set to *ON if the
      *               field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColByName...
     P                 b                   Export
     D JDBC_GetColByName...
     D                 pi         32767a   varying
     D  rs                                 Like(ResultSet)
     D  ColumnName                32767a   varying Const options(*varsize)
     D  nullInd                       1N   options(*nopass:*omit)

     D null            s              1n   inz(*off)
     D parm            s                   Like(jstring)
     D str             s                   Like(jstring)
     D retField        s          32767a

      /free
        if (%len(ColumnName)=0 or ColumnName=*blank);
           null = *on;
           retField = '';
        else;
           jdbc_begin_object_group(100);
           Monitor;
             parm = s(ColumnName);
             str = getColStrByName(rs: parm);
             if (str = *null);
                null=*on;
                retField = '';
             else;
                null=*off;
                retField = r(str);
             endif;
           On-Error;
             retField = '';
             null = *on;
           Endmon;
           jdbc_end_object_group();
        Endif;

        if (%parms >= 3 and %addr(nullInd)<>*NULL);
            nullInd = Null;
        endif;

        Return retField;
      /end-free
     P                 e


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColByNameC():  Get column data in Unicode from the
      *                         current row by column name.
      *
      *          rs = (input) Result handle to use
      *  columnName = (input) column name to retrieve
      *     nullInd = (output/optional) will be set to *ON if the
      *               field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_GetColByNameC...
     P                 b                   Export
     D JDBC_GetColByNameC...
     D                 pi         16383c   varying
     D  rs                                 Like(ResultSet)
     D  ColumnName                16383c   varying Const options(*varsize)
     D  nullInd                       1N   options(*nopass:*omit)

     D null            s              1n   inz(*off)
     D parm            s                   Like(jstring)
     D str             s                   Like(jstring)
     D retField        s          16383c

      /free
        if (%len(ColumnName)=0 or ColumnName=*blank);
           null = *on;
           retField = %ucs2('');
        else;
           jdbc_begin_object_group(100);
           Monitor;
             parm = new_StringC(ColumnName);
             str = getColStrByName(rs: parm);
             if (str = *null);
                null=*on;
                retField = %ucs2('');
             else;
                null=*off;
                retField = c(str);
             endif;
           On-Error;
             retField = %ucs2('');
             null = *on;
           Endmon;
           jdbc_end_object_group();
        Endif;

        if (%parms >= 3 and %addr(nullInd)<>*NULL);
            nullInd = Null;
        endif;

        Return retField;
      /end-free
     P                 e


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getUpdateCount(): Get the number of rows modified
      *         by the last call to JDBC_ExecCall()
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns number of modified rows, or -1 if the current
      *          result is a ResultSet or if there are no results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_getUpdateCount...
     P                 b                   Export
     D JDBC_getUpdateCount...
     D                 pi            10i 0
     D  stmt                               Like(Statement) const
     D getUpdateCount  pr            10i 0 extproc(*JAVA
     D                                     : 'java.sql.Statement'
     D                                     : 'getUpdatecount')
     c                   return    getUpdateCount(stmt)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getResultSet(): Get the first/next ResultSet
      *         returned by JDBC_ExecCall()
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns the ResultSet or *NULL if the current result is
      *          not a ResultSet or if there are no more results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_getResultSet...
     P                 b                   Export
     D JDBC_getResultSet...
     D                 pi                  like(ResultSet)
     D  stmt                               Like(Statement) const
     D getResultSet    pr                  like(ResultSet)
     D                                     extproc(*JAVA
     D                                     : 'java.sql.Statement'
     D                                     : 'getResultSet')
     c                   return    getResultSet(stmt)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getMoreResults(): Move the results of this statement
      *         to the next result returned.
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns *ON if the next result is a ResultSet object,
      *          or *OFF if it's an update count or there are no
      *          more results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_getMoreResults...
     P                 b                   Export
     D JDBC_getMoreResults...
     D                 pi             1n
     D  stmt                               Like(Statement) const
     D getMoreResults  pr             1n   extproc(*JAVA
     D                                     : 'java.sql.Statement'
     D                                     : 'getMoreResults')
     c                   return    getMoreResults(stmt)
     P                 E


      /if defined(BLOB_SUPPORT)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getBlob(): Get BLOB column from current row
      *
      *       rs = (input) Result handle to use
      *      col = (input) column number to retrieve
      *  nullInd = (output/optional) will be set to *ON if the
      *             field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P JDBC_getBlob    B                   export
     D JDBC_getBlob    PI         32767A   varying
     D   rs                                like(ResultSet)
     D   col                         10I 0 value
     D   nullInd                      1N   options(*nopass:*omit)

     D blob_length     PR            20i 0 extproc(*java
     D                                     : 'java.sql.Blob'
     D                                     : 'length')


     D result          s          32767A   varying
     D str             s                   like(jstring)
     D null            s              1N   inz(*OFF)
      /free
          jdbc_begin_object_group(5);
          monitor;
             str = getColString(rs: col);
             if (str = *NULL);
                result = '';
                null = *ON;
             else;
                result = r(str);
             endif;
          on-error;
             null = *ON;
             result = '';
          endmon;
          jdbc_end_object_group();
          if (%parms >= 3 and %addr(nullInd)<>*NULL);
              nullInd = Null;
          endif;
          return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * blob_getBytes():  Calls the JNI functions needed to
      *   retrieve a raw string of bytes containing the BLOB
      *   data.
      *
      *    obj = (input) Blob object to get contents of
      *    pos = (input) starting position to retrieve from blob
      *    len = (input) number of bytes to extract
      *
      * returns pointer to teraspace memory containing the blob
      *         (freshly allocated -- must be freed separately.)
      *      or *null upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P blob_getBytes   B
     D blob_getBytes   PI              *
     D   obj                               like(Blob)
     D   pos                         20i 0 value
     D   len                         10i 0 value

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   len                          5P 0 const
     D   data                     32702A   options(*varsize)
     D   table                       10A   const

     D jni_getBytes    PR                  LIKE(jobject)
     D                                     EXTPROC(*CWIDEN
     D                                     : JNINativeInterface.
     D                                       CallObjectMethod_P)
     D   env                               LIKE(JNIEnv_P) VALUE
     D   obj                               LIKE(jobject) VALUE
     D   methodID                          LIKE(jmethodID) VALUE
     D   pos                               LIKE(jlong) VALUE
     D                                     options(*nopass)
     D   length                            LIKE(jint) VALUE
     D                                     options(*nopass)

     D BLOB_CLASS      C                   x'6a6176612f73716c2f426c6f62'
     D NAME_GETBYTES   C                   x'6765744279746573'
     D SIG_GETBYTES    C                   x'284a49295b42'

     D env             s               *   static inz(*NULL)
     D msg             s            256A   varying
     D cls             s                   like(jclass)
     D mid             s                   like(jmethodid)
      /free
          if (env = *NULL);
              env = jdbc_get_jni_env();
          endif;

          if (cls = *null);
             cls = FindClass(env: BLOB_CLASS);
             if (jni_CheckError(*omit));
                return *NULL;
             endif;
          endif;

          if ( cls = *NULL );
             msg = 'Class java.sql.Blob not found!';
             exsr DiagMsg;
             return *NULL;
          endif;

          if (mid = *null);
             mid = GetMethodID(env: cls: NAME_GETBYTES: SIG_GETBYTES);
             if (jni_CheckError(*omit));
                return *NULL;
             endif;
          endif;

          if ( mid = *NULL );
             msg = 'getBytes() method for java.sql.Blob'
                 + ' not found!';
             exsr DiagMsg;
             return *NULL;
          endif;

          arr = jni_getBytes( env: obj: mid: pos: len);
          if (jni_CheckError(*omit));
             msg = 'error calling jni_getBytes routine';
             exsr DiagMsg;
             return *NULL;
          endif;

          buf = getByteArrayElements( env: arr: isCopy );
          if (jni_CheckError(*omit));
             msg = 'error calling getByteArrayElements()';
             return *NULL;
          endif;

          ret = %alloc(len);
          memcpy(ret: buf: len);

          ReleaseByteArrayElements( JNIENV_P: arr: buf: 0 );
          DeleteLocalRef(JNIENV_P: arr);

          return ret;

          begsr DiagMsg;
             SndPgmMsg( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : msg
                      : %len(msg)
                      : '*DIAG'
                      : '*'
                      : 0
                      : MsgKey
                      : ErrCode );
          endsr;
      /end-free
     P                 E
      /endif
