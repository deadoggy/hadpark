#!/bin/bash

# detect java home
if [[ -z $JAVA_HOME ]]; then
echo 'No java found! exit'
exit
else
echo 'Java home:'$JAVA_HOME
fi

#prepare file 
sudo mkdir /cluster
sudo chmod a+w /cluster

#copy java home
cp -r  $JAVA_HOME /cluster/

#copy Dockerfile
cp Dockerfile /cluster/

#copy pubkey
cp $HOME/.ssh/id_rsa.pub /cluster/id_rsa.pub

#copy user info
cp user /cluster/

#downloading hadoop and spark

cd /cluster
echo downing hadoop...
wget -q  http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.8.3/hadoop-2.8.3.tar.gz
echo done
echo decompressing,,,
tar -xzf hadoop-2.8.3.tar.gz
mv hadoop-2.8.3 hadoop
rm hadoop-2.8.3.tar.gz
echo done

echo downing spark...
wget -q  http://mirrors.hust.edu.cn/apache/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz 
echo done
echo decompressing...
tar -xzf spark-2.2.1-bin-hadoop2.7.tgz
mv spark-2.2.1-bin-hadoop2.7 spark
rm spark-2.2.1-bin-hadoop2.7.tgz
echo done

echo set HADOOP_CONF_DIR...
sudo sed -i '$aexport HADOOP_CONF_DIR=/cluster/hadoop/etc/hadoop' /etc/profile
cd /etc
source profile
cd /cluster
echo done

#create a docker network
docker network create --subnet 192.168.0.0/16 hadoopnetwork

#build docker image
docker build -t hadoop_slave .

#modify hosts file in master
sudo sed -i  '$a192.168.0.4 slave1' /etc/hosts
sudo sed -i  '$a192.168.0.5 slave2' /etc/hosts
sudo sed -i  '$a192.168.0.6 slave3' /etc/hosts

#run docker container
docker run -tid --net hadoopnetwork --ip 192.168.0.4  --add-host master:192.168.0.1 hadoop_slave 
docker run -tid --net hadoopnetwork --ip 192.168.0.5  --add-host master:192.168.0.1 hadoop_slave 
docker run -tid --net hadoopnetwork --ip 192.168.0.6  --add-host master:192.168.0.1 hadoop_slave 

#TODO: modify slaves and other configure files in hadoop
#TODO: startup hadoop namenode
