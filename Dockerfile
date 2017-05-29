# ---- XFrames HDFS Docker ----

# ---- Version Control ----

FROM nimmis/java:oracle-8-jdk

# ---- Download Links ----

#Base image doesn't start in root
WORKDIR /

# ---- apt-get install ----

RUN apt-get update && apt-get install -y wget zip sudo

# ---- Set the locale ----

RUN locale-gen en_US.UTF-8 && \
	update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

#Add the CDH 5 repository
COPY conf/cloudera.list /etc/apt/sources.list.d/cloudera.list
#Set preference for cloudera packages
COPY conf/cloudera.pref /etc/apt/preferences.d/cloudera.pref
#Add repository for python installation
COPY conf/python.list /etc/apt/sources.list.d/python.list

#Add a Repository Key
RUN wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key && sudo apt-key add archive.key && sudo apt-get update

#Install CDH package and dependencies
RUN sudo apt-get install -y hadoop-conf-pseudo=2.6.0+cdh5.4.4+597-1.cdh5.4.4.p0.6~trusty-cdh5.4.4
 
#Copy updated config files
COPY conf/core-site.xml /etc/hadoop/conf/core-site.xml
COPY conf/hdfs-site.xml /etc/hadoop/conf/hdfs-site.xml

# ---- Install hive ----

# ---- Ports ----

# NameNode (HDFS)
EXPOSE 8020 50070

# DataNode (HDFS)
EXPOSE 50010 50020 50075

# ---- Runner ----
COPY conf/run.sh /usr/bin/run.sh
RUN chmod u+x /usr/bin/run.sh
CMD ["/usr/bin/run.sh"]
