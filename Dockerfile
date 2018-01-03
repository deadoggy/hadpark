FROM ubuntu:16.04
MAINTAINER deadoggy

# BASE DIR
RUN mkdir /cluster
RUN chmod a+w /cluster

# COPY FILE AND SET SSH
ADD hadoop /cluster/
RUN chmod 0600 /root/.ssh/authorized_keys
RUN apt-get install open-ssh sudo

# ENV
ADD java /lib/
ENV JAVA_HOME /lib/java
ENV CLASSPATH /lib/java/lib/
ENV PATH /lib/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# PORT
EXPOSE 50010 50075 50475 50020 22

#ADD HADOOP USER
ADD user /root/
RUN useradd -m -r hadoop
RUN chpasswd < /root/user
RUN echo "hadoop    ALL=(ALL) ALL" >> /etc/sudoers

#CHANGE USER AND START SSH
USER hadoop
ADD id_rsa.pub /home/hadoop/.ssh/
RUN mv /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys
RUN /user/sbin/sshd
