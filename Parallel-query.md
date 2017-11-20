[https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236&DB_Short_Name=On-Time]

[https://github.com/Percona-Lab/ontime-airline-performance.git]








```sql
create database flights;





use flights;
truncate table ontime;
drop table ontime;
CREATE TABLE `ontime` (
`YearD` year(4) NOT NULL,
`Quarter` tinyint(4) DEFAULT NULL,
`MonthD` tinyint(4) DEFAULT NULL,
`DayofMonth` tinyint(4) DEFAULT NULL,
`DayOfWeek` tinyint(4) DEFAULT NULL,
`FlightDate` date DEFAULT NULL,
`UniqueCarrier` char(7) DEFAULT NULL,
`AirlineID` int(11) DEFAULT NULL,
`Carrier` char(7) DEFAULT NULL,
`TailNum` varchar(50) DEFAULT NULL,
--
`FlightNum` varchar(10) DEFAULT NULL,
`OriginAirportID` int(11) DEFAULT NULL,
`OriginAirportSeqID` int(11) DEFAULT NULL,
`OriginCityMarketID` int(11) DEFAULT NULL,
`Origin` char(7) DEFAULT NULL,
`OriginCityName` varchar(100) DEFAULT NULL,
`OriginState` char(7) DEFAULT NULL,
`OriginStateFips` varchar(10) DEFAULT NULL,
`OriginStateName` varchar(100) DEFAULT NULL,
`OriginWac` int(11) DEFAULT NULL,
--
`DestAirportID` int(11) DEFAULT NULL,
`DestAirportSeqID` int(11) DEFAULT NULL,
`DestCityMarketID` int(11) DEFAULT NULL,
`Dest` char(5) DEFAULT NULL,
-- ... (removed number of fields)
`id` int(11) NOT NULL AUTO_INCREMENT,
PRIMARY KEY (`id`),
KEY `YearD` (`YearD`),
KEY `Carrier` (`Carrier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

```bash 
mysql -u root -poracle -e "LOAD DATA INFILE '/u01/DemoData/ontime.88.2016.csv' INTO TABLE flights.ontime FIELDS TERMINATED BY ','  ENCLOSED BY '\"' 
(YearD,
Quarter,
MonthD,
DayofMonth,
DayOfWeek,
FlightDate,
UniqueCarrier,
AirlineID,
Carrier,
TailNum,
FlightNum,
OriginAirportID,
OriginAirportSeqID,
OriginCityMarketID,
Origin,
OriginCityName,
OriginState,
OriginStateFips,
OriginStateName,
OriginWac,
DestAirportID,
DestAirportSeqID,
DestCityMarketID,
Dest) set ID=NULL " flights
```
ALTER TABLE ontime  ADD INDEX y (year);


```sql
select year, count(*) from ontime group by year
```

```sql
explain select year, count(*) from ontime group by year\G
```

```
*************************** 1. row ***************************
id: 1
select_type: SIMPLE
table: ontime
type: index
possible_keys: YearD,comb1
key: YearD
key_len: 1
ref: NULL
rows: 148046200 <---
Extra: Using index
1 row in set (0.00 sec)
```


```sql
select year, count(*) from ontime group by year;
+-------+----------+
| yeard | count(*) |
+-------+----------+
| 1988  | 5202096  |
| 1989  | 5041200  |
| 1990  | 5270893  |
| 1991  | 5076925  |
| 1992  | 5092157  |
| 1993  | 5070501  |
| 1994  | 5180048  |
| 1995  | 5327435  |
| 1996  | 5351983  |
| 1997  | 5411843  |
| 1998  | 5384721  |
| 1999  | 5527884  |
| 2000  | 5683047  |
| 2001  | 5967780  |
| 2002  | 5271359  |
| 2003  | 6488540  |
| 2004  | 7129270  |
| 2005  | 7140596  |
| 2006  | 7141922  |
| 2007  | 7455458  |
| 2008  | 7009726  |
| 2009  | 6450285  |
| 2010  | 6450117  |
| 2011  | 6085281  |
| 2012  | 6096762  |
| 2013  | 5349447  |
+-------+----------+
26 rows in set (54.10 sec)
```




-- run in multi sessions
``` bash
#!/bin/bash
date
for y in {2000..2009}
do
  sql="select year, count(*) from ontime where year=$y"
  mysql -vvv -u root -poracle flights -e "$sql" &>par_sql1/$y.log &
done
wait
date
```



## complex

```sql
select
   min(yeard), max(yeard), Carrier, count(*) as cnt,
   sum(ArrDelayMinutes>30) as flights_delayed,
   round(sum(ArrDelayMinutes>30)/count(*),2) as rate
FROM ontime
WHERE
   DayOfWeek not in (6,7) and OriginState not in ('AK', 'HI', 'PR', 'VI')
   and DestState not in ('AK', 'HI', 'PR', 'VI')
   and flightdate < '2010-01-01'
GROUP by carrier
HAVING cnt > 100000 and max(yeard) > 1990
ORDER by rate DESC
```
##The query runs in ~15 minutes:



id: 1
select_type: SIMPLE
table: ontime
type: index
possible_keys: comb1
key: comb1
key_len: 9
ref: NULL
rows: 148046200 <----
Extra: Using where; Using temporary; Using filesort



(for this query I’ve created the combined index: KEY comb1 (Carrier,YearD,ArrDelayMinutes)  to increase performance)



date
for c in '9E' 'AA' 'AL' 'AQ' 'AS' 'B6' 'CO' 'DH' 'DL' 'EA' 'EV' 'F9' 'FL' 'HA' 'HP' 'ML' 'MQ' 'NW' 'OH' 'OO' 'PA' 'PI' 'PS' 'RU' 'TW' 'TZ' 'UA' 'US' 'WN' 'XE' 'YV'
do
   sql=" select min(yeard), max(yeard), Carrier, count(*) as cnt, sum(ArrDelayMinutes>30) as flights_delayed, round(sum(ArrDelayMinutes>30)/count(*),2) as rate FROM ontime WHERE DayOfWeek not in (6,7) and OriginState not in ('AK', 'HI', 'PR', 'VI') and DestState not in ('AK', 'HI', 'PR', 'VI') and flightdate < '2010-01-01' and carrier = '$c'"
   mysql -uroot -vvv ontime -e "$sql" &>par_sql_complex/$c.log &
done
wait
date


Results: total time is 5 min 47 seconds (3x faster)











Cpu3 : 22.0%us, 1.2%sy, 0.0%ni, 74.4%id, 2.4%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu4 : 16.0%us, 0.0%sy, 0.0%ni, 84.0%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu5 : 39.0%us, 1.2%sy, 0.0%ni, 56.1%id, 3.7%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu6 : 33.3%us, 0.0%sy, 0.0%ni, 51.9%id, 13.6%wa, 0.0%hi, 1.2%si, 0.0%st
Cpu7 : 33.3%us, 1.2%sy, 0.0%ni, 48.8%id, 16.7%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu8 : 24.7%us, 0.0%sy, 0.0%ni, 60.5%id, 14.8%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu9 : 24.4%us, 0.0%sy, 0.0%ni, 56.1%id, 19.5%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu10 : 40.7%us, 0.0%sy, 0.0%ni, 56.8%id, 2.5%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu11 : 19.5%us, 1.2%sy, 0.0%ni, 65.9%id, 12.2%wa, 0.0%hi, 1.2%si, 0.0%st
Cpu12 : 40.2%us, 1.2%sy, 0.0%ni, 56.1%id, 2.4%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu13 : 82.7%us, 0.0%sy, 0.0%ni, 17.3%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu14 : 55.4%us, 0.0%sy, 0.0%ni, 43.4%id, 1.2%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu15 : 86.6%us, 0.0%sy, 0.0%ni, 13.4%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu16 : 61.0%us, 1.2%sy, 0.0%ni, 37.8%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu17 : 29.3%us, 1.2%sy, 0.0%ni, 69.5%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu18 : 18.8%us, 0.0%sy, 0.0%ni, 52.5%id, 28.8%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu19 : 14.3%us, 1.2%sy, 0.0%ni, 57.1%id, 27.4%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu20 : 12.3%us, 0.0%sy, 0.0%ni, 59.3%id, 28.4%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu21 : 10.7%us, 0.0%sy, 0.0%ni, 76.2%id, 11.9%wa, 0.0%hi, 1.2%si, 0.0%st
Cpu22 : 0.0%us, 0.0%sy, 0.0%ni,100.0%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st
Cpu23 : 10.8%us, 2.4%sy, 0.0%ni, 71.1%id, 15.7%wa, 0.0%hi, 0.0%si, 0.0%st
