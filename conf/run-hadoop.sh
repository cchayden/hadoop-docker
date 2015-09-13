#!/bin/bash

service hadoop-hdfs-namenode start
service hadoop-hdfs-datanode start

sudo -u hdfs hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn
sudo -u hdfs hdfs dfs -mkdir /user
sudo -u hdfs hdfs dfs -mkdir /user/hive
sudo -u hdfs hdfs dfs -mkdir /user/hive/warehouse
sudo -u hdfs hdfs dfs -chmod -R 777 /user/hive/warehouse 
sudo -u hdfs hdfs dfs -chmod -R 777 /

service zookeeper-server start

service hadoop-yarn-resourcemanager start
service hadoop-yarn-nodemanager start
service hadoop-mapreduce-historyserver start

sudo -u hdfs hadoop fs -mkdir -p /user/hdfs
sudo -u hdfs hadoop fs -chown hdfs /user/hdfs

#init oozie
sudo -u hdfs hadoop fs -mkdir /user/oozie
sudo -u hdfs hadoop fs -chown oozie:oozie /user/oozie
sudo oozie-setup sharelib create -fs hdfs://localhost:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn

service oozie start
sudo -u oozie /usr/lib/oozie/bin/ooziedb.sh create -sqlfile /tmp/oozie.sql -run

#init spark history server
sudo -u hdfs hadoop fs -mkdir /user/spark
sudo -u hdfs hadoop fs -mkdir /user/spark/applicationHistory
sudo -u hdfs hadoop fs -chown -R spark:spark /user/spark
sudo -u hdfs hadoop fs -chmod 1777 /user/spark/applicationHistory

#init spark shared libraries
#client than can use SPARK_JAR=hdfs://<nn>:<port>/user/spark/share/lib/spark-assembly.jar
sudo -u spark hadoop fs -mkdir -p /user/spark/share/lib 
sudo -u spark hadoop fs -put /usr/lib/spark/lib/spark-assembly.jar /user/spark/share/lib/spark-assembly.jar
service spark-history-server start

service hue start

${HIVE_HOME}/bin/hive --service metastore

# To hell with security
sudo -u hdfs hdfs dfs -chmod -R 777 /

#echo " ---- Startup complete ----"

# tail log directory
tail -n 1000 -f /var/log/hadoop-*/*.out
