FROM ubuntu:16.04
MAINTAINER deadoggy

# BASE DIR
RUN mkdir /cluster
RUN chmod a+w /cluster

# COPY FILE AND SET SSH
ADD hadoop /cluster/
RUN apt-get install open-ssh sudo

# ENV
ADD java /lib/
ENV JAVA_HOME /lib/java
ENV CLASSPATH /lib/java/lib/
ENV PATH /lib/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# MODIFY HOSTS
RUN sed "1i/192.168.0.1 master" /etc/hosts

# PORT
EXPOSE 50010 50075 50475 50020 22

#ADD HADOOP USER AND CONFIG SSH WITHOUT PASSWD
ADD user /root/
RUN useradd -s /bin/bash -m -r hadoop
RUN chpasswd < /root/user
RUN echo "hadoop    ALL=(ALL) ALL" >> /etc/sudoers
ADD id_rsa.pub /home/hadoop/.ssh/
RUN mv /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys
RUN chmod 777 /home/hadoop/.ssh/authorized_keys

#CHANGE USER AND START SSH
USER hadoop
RUN /user/sbin/sshd -D

