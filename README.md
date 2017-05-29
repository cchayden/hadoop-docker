XFrames HDFS
============

Summary
-------
Simple hdfs docker used to run XFrames hdfs tests.

 * HDFS : 50070 8020

Dependencies
-------
 * Ubuntu >= 12.04, Centos >= 6.5
 * docker >= 1.8.1 (https://docs.docker.com/installation/)

Installation 
-------
 * Pull the latest HDFS docker container. $`docker pull cchayden/xframes-hdfs`

Running
-------
 
 * Launch the Hadoop docker container:
 $  docker run -it -p 50070:50070 -p 8088:8088 -p 8040:8040 \
    -v /tmp/hdfs-cache:/var/lib/hadoop-hdfs/cache \
    --hostname xframes-hdfs cchayden/xframes-hdfs

Testing
-------
 * From host machine: $`docker ps`

Example
-------


Notes
-------

