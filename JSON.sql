##########################
# 16.11.2017 by baruch@brillix.co.il
#       JSON on MySQL 5.7.X
############

SET @document = '[10,20,[30,40]]';

select json_extract(json_extract(@document,'$[2]'),'$[1]');



CREATE TABLE features (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    feature JSON NOT NULL
);


INSERT  into  features (feature) VALUES ('{
   "type":"Feature",
   "geometry":{
      "type":"Polygon",
      "coordinates":[
         [
            [-122.42200352825247,37.80848009696725,0],
            [-122.42207601332528,37.808835019815085,0],
            [-122.42110217434865,37.808803534992904,0],
            [-122.42106256906727,37.80860105681814,0],
            [-122.42200352825247,37.80848009696725,0]
         ]
      ]
   },
   "properties":{
      "TO_ST":"0",
      "BLKLOT":"0001001",
      "STREET":"UNKNOWN",
      "FROM_ST":"0",
      "LOT_NUM":"001",
      "ST_TYPE":null,
      "ODD_EVEN":"E",
      "BLOCK_NUM":"0001",
      "MAPBLKLOT":"0001001"
   }
}');

INSERT  into  features (feature) VALUES ('{
   "type":"Feature",
   "geometry":{
      "type":"Polygon",
      "coordinates":[
         [
            [-122.42200352825247,37.80848009696725,0],
            [-122.42207601332528,37.808835019815085,0],
            [-122.42110217434865,37.808803534992904,0],
            [-122.42106256906727,37.80860105681814,0],
            [-122.42200352825247,37.80848009696725,0]
         ]
      ]
   },
   "properties":{
      "TO_ST":"0",
      "BLKLOT":"0001001",
      "STREET":"MARKET",
      "FROM_ST":"0",
      "LOT_NUM":"1001",
      "ST_TYPE":null,
      "ODD_EVEN":"E",
      "BLOCK_NUM":"0001",
      "MAPBLKLOT":"0001001"
   }
}');


SELECT json_extract(feature,'$.geometry.coordinates') FROM features
WHERE feature->"$.properties.STREET" = 'MARKET';


SELECT feature -> "$.geometry.coordinates" FROM features
WHERE feature->"$.properties.STREET" = 'MARKET';


##
## install mysql shell
# sudo yum install mysql-shell

## enable x protocol
#mysqlsh -u root -h localhost --classic --dba enableXProtocol
## in 8.x


## in the log

#2017-10-15T18:52:51.558629Z 0 [Note] Plugin mysqlx reported: 'X Plugin listens on TCP (bind-address:'::', port:33060)'
#2017-10-15T18:52:51.558653Z 0 [Note] Plugin mysqlx reported: 'X Plugin listens on UNIX socket (/var/run/mysqld/mysqlx.sock)'
#2017-10-15T18:52:51.558680Z 0 [Note] Plugin mysqlx reported: 'Server starts handling incoming connections'




##CRUD

#mysqlsh --uri root@localhost
./mysqlsh -mc -u root -poracle -h mysqlserver01


db = session.getSchema('world_x')
db
db.getCollections()
\use world_x

# insert
db.countryinfo.add(
 {
    GNP: .6,
    IndepYear: 1948,
    Name: "Acme",
    _id: "ACM",
    demographics: {
        LifeExpectancy: 120,
        Population: 22
    },
    geography: {
        Continent: "Asia",
        Region: "British Islands",
        SurfaceArea: 193
    },
    government: {
        GovernmentForm: "Monarchy",
        HeadOfState: "Michael Bates"
    }
  }
);
## remove
db.countryinfo.remove("_id='ACM'");



db.getCollection("CountryInfo").find('Name= "United States"').limit(1)



## from sql
\sql
SELECT doc FROM world_x.CountryInfo WHERE (JSON_EXTRACT(doc,'$.Name') = 'United States') LIMIT 1;
##
