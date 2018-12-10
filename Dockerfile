FROM ubuntu:16.04
MAINTAINER deadoggy


# BASE DIR
RUN mkdir /cluster
RUN chmod a+w /cluster

# COPY FILE AND SET SSH
RUN mkdir /cluster/hadoop
ADD hadoop /cluster/hadoop/
RUN apt-get update
RUN apt-get -y  install openssh-server sudo

# ENV
RUN mkdir /lib/java
ADD java /lib/java
ENV JAVA_HOME /lib/java
ENV CLASSPATH /lib/java/lib/
ENV PATH /lib/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# PORT
EXPOSE 50010 50075 50475 50020 22

#ADD HADOOP USER AND CONFIG SSH WITHOUT PASSWD
ADD user /root/
RUN useradd -s /bin/bash -m -r hadoop
RUN chpasswd < /root/user
RUN echo 'hadoop    ALL=(ALL) ALL' >> /etc/sudoers
RUN mkdir /var/run/sshd

#CHANGE USER AND START SSH
ADD id_rsa.pub /home/hadoop/.ssh/authorized_keys
RUN chmod 700 /home/hadoop/.ssh/authorized_keys
RUN chown -R  hadoop:hadoop /home/hadoop
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
RUN sed -i '$aPasswordAuthentication no' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]

