-- Base table for kingdom matrix (pg 1 taxonomy bubbles). Result used by taxon_matrix.R

CREATE DATABASE IF NOT EXISTS ${hiveconf:CR_DB};

DROP TABLE IF EXISTS ${hiveconf:CR_DB}.kingdom_matrix;
CREATE TABLE ${hiveconf:CR_DB}.kingdom_matrix
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE 
AS SELECT t1.country, t1.kingdom, sum(`_c3`), round((sum(`_c3`)/sum(`_c4`))*100) FROM
(
SELECT 
  o1.countrycode AS country, 
  o1.kingdom AS kingdom, 
  o1.kingdomkey AS kingdom_key,
  sum(if(to_date(from_unixtime(cast(o1.fragmentcreated/1000 AS int))) BETWEEN '2014-07-01' AND '2015-06-30',1,0)),
  sum(if(to_date(from_unixtime(cast(o2.fragmentcreated/1000 AS int))) < '2015-07-01',1,0)) 

FROM ${hiveconf:PROD_DB}.occurrence_hdfs o1 JOIN ${hiveconf:PROD_DB}.occurrence_hdfs o2 ON o1.gbifid = o2.gbifid 
WHERE to_date(from_unixtime(cast(o1.fragmentcreated/1000 AS int))) < '2015-07-01' 
AND (o1.kingdomkey IN (6, 1, 4, 1, 7, 5)) 
GROUP BY 
  o1.countrycode, 
  o1.kingdom, 
  o1.kingdomkey, 
  year(to_date(from_unixtime(cast(o1.fragmentcreated/1000 AS int)))),
  year(to_date(from_unixtime(cast(o2.fragmentcreated/1000 AS int))))
) t1
GROUP BY t1.country, t1.kingdom
