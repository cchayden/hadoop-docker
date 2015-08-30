FROM nimmis/java:oracle-8-jdk
MAINTAINER Martin Chalupa <chalimartines@gmail.com>

#Base image doesn't start in root
WORKDIR /

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
RUN wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key && sudo apt-key add archive.key && \
    sudo apt-get update

#Add postgres Repo
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	sudo apt-get update 

#Install CDH package and dependencies
RUN sudo apt-get install -y zookeeper-server && \
    sudo apt-get install -y hadoop-conf-pseudo && \
    sudo apt-get install -y oozie && \
    sudo apt-get install -y python2.7 && \
    sudo apt-get install -y hue && \
    sudo apt-get install -y hue-plugins && \
    sudo apt-get install -y spark-core spark-history-server spark-python && \
    sudo apt-get install -y hive && \
    sudo apt-get install -y hive-metastore && \
    sudo apt-get install -y hive-server2 && \
    sudo apt-get install -y postgresql-9.4  && \
    sudo apt-get install -y libpostgresql-jdbc-java

#jdbc setup
RUN ln -s /usr/share/java/postgresql-jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc4.jar

#Copy updated config files
COPY conf/core-site.xml /etc/hadoop/conf/core-site.xml
COPY conf/hdfs-site.xml /etc/hadoop/conf/hdfs-site.xml
COPY conf/mapred-site.xml /etc/hadoop/conf/mapred-site.xml
COPY conf/hadoop-env.sh /etc/hadoop/conf/hadoop-env.sh
COPY conf/yarn-site.xml /etc/hadoop/conf/yarn-site.xml
COPY conf/oozie-site.xml /etc/oozie/conf/oozie-site.xml
COPY conf/spark-defaults.conf /etc/spark/conf/spark-defaults.conf
COPY conf/hue.ini /etc/hue/conf/hue.ini
COPY conf/hive-site-meta.xml /usr/lib/hive/conf/hive-site.xml
COPY conf/hive-site-server.xml /etc/lib/hive/conf/hive-site.xml
COPY conf/postgresql_init.sql /tmp/postgresql_init.sql

#Setup Postgres
USER postgres
RUN service postgresql start && \
    psql -a -f /tmp/postgresql_init.sql && \
    service postgresql stop
USER root

#Format HDFS
RUN sudo -u hdfs hdfs namenode -format

COPY conf/run-hadoop.sh /usr/bin/run-hadoop.sh
RUN  chmod +x /usr/bin/run-hadoop.sh

RUN  wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip -O ext.zip && \
     unzip ext.zip -d /var/lib/oozie

RUN service zookeeper-server init

# NameNode (HDFS)
EXPOSE 8020 50070

# DataNode (HDFS)
EXPOSE 50010 50020 50075

# ResourceManager (YARN)
EXPOSE 8030 8031 8032 8033 8088

# NodeManager (YARN)
EXPOSE 8040 8042

# JobHistoryServer
EXPOSE 10020 19888

# Hue
EXPOSE 8888

# Spark history server
EXPOSE 18080

# Technical port which can be used for your custom purpose.
EXPOSE 9999

CMD ["/usr/bin/run-hadoop.sh"]
