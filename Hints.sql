
/*##########################
# 16.11.2017 by baruch@brillix.co.il
# Forcing the index to be used despite its cost
#############################*/



/*
show create table Country\G
*************************** 1. row ***************************
       Table: Country
Create Table: CREATE TABLE `country` (
  `Code` char(3) NOT NULL DEFAULT '',
  `Name` char(52) NOT NULL DEFAULT '',
  `Continent` enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') NOT NULL DEFAULT 'Asia',
  `Region` char(26) NOT NULL DEFAULT '',
  `SurfaceArea` float(10,2) NOT NULL DEFAULT '0.00',
  `IndepYear` smallint(6) DEFAULT NULL,
  `Population` int(11) NOT NULL DEFAULT '0',
  `LifeExpectancy` float(3,1) DEFAULT NULL,
  `GNP` float(10,2) DEFAULT NULL,
  `GNPOld` float(10,2) DEFAULT NULL,
  `LocalName` char(45) NOT NULL DEFAULT '',
  `GovernmentForm` char(45) NOT NULL DEFAULT '',
  `HeadOfState` char(60) DEFAULT NULL,
  `Capital` int(11) DEFAULT NULL,
  `Code2` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`Code`),
  KEY `p` (`Population`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)
*/



--# Join tables in the order specified
SELECT STRAIGHT_JOIN Country.Name as CountryName, City.Name AS City
FROM Country INNER JOIN City ON City.CountryCode=Country.Code;

--# Force usage of an index
SELECT * FROM Country FORCE INDEX (p)
WHERE continent='Asia' and population > 5000000;

--# Ignore an index
SELECT * FROM Country IGNORE INDEX (p)
WHERE continent='Asia' and population > 5000000;

--# Suggest an index over other indexes
SELECT * FROM Country USE INDEX (p)
WHERE continent='Asia' and population > 5000000;



/*
DEMO:
*/

EXPLAIN FORMAT=JSON
SELECT * FROM Country  WHERE continent='Asia' and population > 5000000\G
/*
EXPLAIN: {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "53.80" <---
    },
....
*/


EXPLAIN FORMAT=JSON
SELECT * FROM Country FORCE INDEX (p) WHERE continent='Asia' and population > 5000000\G

/*
{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "152.21" ## we force the CBO to use the index .
    },
    "table": {
      "table_name": "Country",
      "access_type": "range",
      "possible_keys": [
        "p"
      ],
      "key": "p",
      "used_key_parts": [
        "Population"
      ],
      "key_length": "4",
      "rows_examined_per_scan": 108,
      "rows_produced_per_join": 15,
      "filtered": "14.29",
      "index_condition": "(`world`.`country`.`Population` > 5000000)",
      "cost_info": {
        "read_cost": "149.12",
        "eval_cost": "3.09",
        "prefix_cost": "152.21",
        "data_read_per_join": "3K"
      },
      "used_columns": [
        "Code",
        "Name",
        "Continent",
        "Region",
        "SurfaceArea",
        "IndepYear",
        "Population",
        "LifeExpectancy",
        "GNP",
        "GNPOld",
        "LocalName",
        "GovernmentForm",
        "HeadOfState",
        "Capital",
        "Code2"
      ],
      "attached_condition": "(`world`.`country`.`Continent` = 'Asia')"
    }
  }
}
*/


/*
use the p index 
*/
EXPLAIN FORMAT=JSON
SELECT   * FROM Country
WHERE Population > 1000000000 AND Continent='Asia'\G

/*
 NO_RANGE_OPTIMIZATION - 	Disables range optimization for the specified tables or indexes.
 will disable the use of the index 
*/
EXPLAIN FORMAT=JSON
SELECT /*+NO_RANGE_OPTIMIZATION(Country) */  * FROM Country
WHERE Population > 1000000000 AND Continent='Asia'\G