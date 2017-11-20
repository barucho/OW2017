/*##########################
# 16.11.2017 by baruch@brillix.co.il
#       Profiling 
############*/



## enable pt-profiles to sys 
# via shell
wget http://www.tocker.ca/files/ps-show-profiles.sql
mysql -u root -p < ps-show-profiles.sql



use world;
CALL sys.enable_profiling();
SELECT * FROM Country WHERE Continent='Asia'   and population > 5000000;
CALL sys.show_profiles;




CALL sys.show_profile_for_event_id(113);
/*
+----------------------+-----------+
| Status               | Duration  |
+----------------------+-----------+
| starting             | 64.82 us  |
| checking permissions | 4.10 us   |
| Opening tables       | 11.87 us  |
| init                 | 29.74 us  |
| System lock          | 5.63 us   |
| optimizing           | 8.74 us   |
| statistics           | 139.38 us |
| preparing            | 11.94 us  |
| executing            | 348.00 ns |
| Sending data         | 192.59 us |
| end                  | 1.17 us   |
| query end            | 4.60 us   |
| closing tables       | 4.07 us   |
| freeing items        | 13.60 us  |
| cleaning up          | 734.00 ns |
+----------------------+-----------+
15 rows in set (0.00 sec)
*/


/*
lets add sleep to the profile 
in this query the server will run sleep every time he find Continent='Antarctica'
*/

SELECT * FROM Country WHERE Continent='Antarctica' and SLEEP(1);
CALL sys.show_profiles();
CALL sys.show_profile_for_event_id(<event_id>);



/*
sorting and group by 
will show as Status Sending Data simply means transferring rows between the storage engine and the server
*/
SELECT region, count(*) as c FROM Country GROUP BY region;
CALL sys.show_profiles();
CALL sys.show_profile_for_event_id(<event_id>);

/*
performance schema 
*/

SELECT * FROM performance_schema.events_statements_history_long
WHERE event_id=<event_id>\G


/*
*************************** 1. row ***************************
              THREAD_ID: 3062
               EVENT_ID: 1566
           END_EVENT_ID: 1585
             EVENT_NAME: statement/sql/select
                 SOURCE: init_net_server_extension.cc:80
            TIMER_START: 588883869566277000
              TIMER_END: 588883870317683000
             TIMER_WAIT: 751406000
              LOCK_TIME: 132000000
               SQL_TEXT: SELECT region, count(*) as c FROM Country GROUP BY region
                 DIGEST: d3a04b346fe48da4f1f5c2e06628a245
            DIGEST_TEXT: SELECT `region` , COUNT ( * ) AS `c` FROM `Country` GROUP BY `region`
         CURRENT_SCHEMA: world
            OBJECT_TYPE: NULL
          OBJECT_SCHEMA: NULL
            OBJECT_NAME: NULL
  OBJECT_INSTANCE_BEGIN: NULL
            MYSQL_ERRNO: 0
      RETURNED_SQLSTATE: NULL
           MESSAGE_TEXT: NULL
                 ERRORS: 0
               WARNINGS: 0
          ROWS_AFFECTED: 0
              ROWS_SENT: 25  <-- 
          ROWS_EXAMINED: 289 <--
CREATED_TMP_DISK_TABLES: 0
     CREATED_TMP_TABLES: 1
       SELECT_FULL_JOIN: 0
 SELECT_FULL_RANGE_JOIN: 0
           SELECT_RANGE: 0
     SELECT_RANGE_CHECK: 0
            SELECT_SCAN: 1
      SORT_MERGE_PASSES: 0
             SORT_RANGE: 0
              SORT_ROWS: 25  <--
              SORT_SCAN: 1
          NO_INDEX_USED: 1
     NO_GOOD_INDEX_USED: 0
       NESTING_EVENT_ID: NULL
     NESTING_EVENT_TYPE: NULL
    NESTING_EVENT_LEVEL: 0

*/









