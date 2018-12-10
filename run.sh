#!/bin/bash

slave_size=$1

if [[ $1 -eq '' ]]; then
    slave_size=4
elif [[ $1 -gt 10 ]]; then
    echo 'too many slaves; exit'
    exit
fi

# detect java home
if [[ -z $JAVA_HOME ]]; then
echo 'No java found! exit'
exit
else
echo 'JAVA_HOME:'$JAVA_HOME
fi

#prepare file 
if [[ `ls / | grep cluster` -eq '' ]]; then
    sudo mkdir /cluster
    sudo chmod a+w /cluster
fi 



#copy Dockerfile
if [[ `ls /cluster | grep Dockerfile` -eq '' ]]; then
    cp Dockerfile /cluster/
fi
#copy pubkey
if [[ `ls /cluster | grep id_rsa` == '' ]]; then
    echo "copy pub key"
    cp ''$HOME'/.ssh/id_rsa.pub' '/cluster/id_rsa.pub'
fi

#copy user info
if [[ `ls /cluster | grep user` -eq '' ]]; then
    cp user /cluster/
fi

#downloading hadoop and spark

if [[ `ls /cluster | grep hadoop` == '' ]]; then
    cd /cluster
    echo downloading hadoop...
    wget -q  'http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz'
    echo done
    echo decompressing...
    tar -xzf 'hadoop-2.9.2.tar.gz'
    mv 'hadoop-2.9.2' hadoop
    #rm hadoop-2.9.2.tar.gz
    echo done
fi

#echo downing spark...
#wget -q  http://mirrors.hust.edu.cn/apache/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz 
#echo done
#echo decompressing...
#tar -xzf spark-2.2.1-bin-hadoop2.7.tgz
#mv spark-2.2.1-bin-hadoop2.7 spark
#rm spark-2.2.1-bin-hadoop2.7.tgz
#echo done

echo "======================================"
echo "Config Hadoop Conf Dir and Copy \$JAVA_HOME"
echo "======================================"

echo set HADOOP_CONF_DIR...
sudo sed -i '$aexport HADOOP_CONF_DIR=/cluster/hadoop/etc/hadoop' /etc/profile
source /etc/profile
cd /cluster

sudo sed -i '/JAVA_HOME/d' /cluster/hadoop/etc/hadoop/hadoop-env.sh
sudo sed -i '$aexport JAVA_HOME='$JAVA_HOME'' /cluster/hadoop/etc/hadoop/hadoop-env.sh

sudo cp -r $JAVA_HOME java
echo done

#create a docker network
echo "======================================"
echo "Build network"
echo "======================================"
sudo docker network create --subnet 192.168.0.0/16 hadoopnetwork

#build docker image
echo "======================================"
echo "Build Image"
echo "======================================"
sudo docker build -t hadoop_slave .

#modify hosts file in master
echo "======================================"
echo "Add Hosts to /etc/hosts"
echo "======================================"
for((i=1;i<=$slave_size;i++))
{
    tail_ip=`expr 4 + $i - 1`
    sudo sed -i  "\$a192.168.0.$tail_ip slave$i" /etc/hosts
}
# sudo sed -i  '$a192.168.0.4 slave1' /etc/hosts
# sudo sed -i  '$a192.168.0.5 slave2' /etc/hosts
# sudo sed -i  '$a192.168.0.6 slave3' /etc/hosts
# sudo sed -i  '$a192.168.0.7 slave4' /etc/hosts

#run docker container
echo "======================================"
echo "Run Docker Image"
echo "======================================"
for((i=1;i<=$slave_size;i++))
{
    tail_ip=`expr 4 + $i - 1`
    sudo docker run -tid --name slave$i --rm --net hadoopnetwork --ip 192.168.0.$tail_ip  --add-host master:192.168.0.1 hadoop_slave  
}
# sudo docker run -tid --rm --net hadoopnetwork --ip 192.168.0.4  --add-host master:192.168.0.1 hadoop_slave  --name slave1
# sudo docker run -tid --rm --net hadoopnetwork --ip 192.168.0.5  --add-host master:192.168.0.1 hadoop_slave  --name slave2
# sudo docker run -tid --rm --net hadoopnetwork --ip 192.168.0.6  --add-host master:192.168.0.1 hadoop_slave  --name slave3
# sudo docker run -tid --rm --net hadoopnetwork --ip 192.168.0.7  --add-host master:192.168.0.1 hadoop_slave  --name slave4

#TODO: modify slaves and other configure files in hadoop
sudo sed -i "/localhost/d" $HADOOP_CONF_DIR/slaves
sudo sed -i "/slave/d" $HADOOP_CONF_DIR/slaves
for((i=1;i<=$slave_size;i++))
{
    sudo echo slave$i >> $HADOOP_CONF_DIR/slaves
}
#TODO: startup hadoop namenode
