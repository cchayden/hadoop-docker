#!/bin/bash
# This is the base process of the container.

init()
{
	# Setup HDFS
	echo -e "\n----INIT ----\n"
	chown hdfs:hadoop /var/lib/hadoop-hdfs/cache/
	rm -Rf /var/lib/hadoop-hdfs/cache/*
	sudo -u hdfs hdfs namenode -format
}


# Initalize the container
init_container()
{
	echo -e "\n----INIT CONTAINER ----\n"
	init
	start_container
}


# Start hadoop and tail logs to keep PID 1 going.
start_container() 
{
	echo -e "\n----START CONTAINER ----\n"
	start_hadoop
}

copy_files()
{
        echo -e "\n---- Copying files ----\n"
        /opt/xframes/scripts/hdfs-setup
}

finish()
{
	sleep 5
	tail -f /var/log/hadoop-*/*.out
}


# Start the tomcat service
start_hadoop() 
{
	# Start the HDFS service 
        echo -e "\n---- Launching HDFS ----\n"
	service hadoop-hdfs-namenode start
	service hadoop-hdfs-datanode start

	sudo -u hdfs hdfs dfs -mkdir /user
	echo -e "\n---- Startup Complete ----\n"
}


# Stop the hadoop service
stop_hadoop() 
{
	service hadoop-hdfs-namenode stop
	service hadoop-hdfs-datanode stop
}




# Startup the container
if [ -z $1 ] || [ "$1" == "run" ]; then
#	init_container
	start_container
	finish
fi

# Initalize the container
if [ "$1" == "init" ]; then 
	init_container
	start_container
	copy_files
	finish
fi

# Start hadoop
if [ "$1" == "start" ]; then 
	start_hadoop
fi

# Stop hadoop
if [ "$1" == "stop" ]; then 
	stop_hadoop
fi

# Restart hadoop
if [ "$1" == "restart" ]; then 
	stop_hadoop
	sleep 2
	start_hadoop
fi

