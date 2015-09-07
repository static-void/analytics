-- Base table for the fig 2 blob on page 1 (published by data). Published occ count for within report period and total count. Used by pg1_pub_blob.R
-- TODO: parameterize query dates
CREATE DATABASE IF NOT EXISTS ${hiveconf:CR_DB};

DROP TABLE IF EXISTS ${hiveconf:CR_DB}.pg1_pub_blob;

CREATE TABLE ${hiveconf:CR_DB}.pg1_pub_blob
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE 
AS SELECT o1.publishingcountry, 
sum(if(to_date(from_unixtime(cast(o1.fragmentcreated/1000 AS int))) BETWEEN '2014-08-01' AND '2015-07-31',1,0)) ,
sum(if(to_date(from_unixtime(cast(o2.fragmentcreated/1000 AS int))) < '2015-08-01',1,0)) 

FROM ${hiveconf:PROD_DB}.occurrence_hdfs o1 JOIN ${hiveconf:PROD_DB}.occurrence_hdfs o2 ON o1.gbifid = o2.gbifid
GROUP BY o1.publishingcountry
ORDER BY o1.publishingcountry