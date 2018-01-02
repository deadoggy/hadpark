FROM ubuntu:16.04
MAINTAINER deadoggy

# BASE DIR
RUN mkdir /cluster
RUN chmod a+w /cluster

# COPY FILE AND SET SSH
ADD hadoop /cluster/
ADD id_rsa.pub /root/.ssh/
RUN mv /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
 
# ENV
ADD java /lib/
ENV JAVA_HOME /lib/java
ENV CLASSPATH /lib/java/lib/
ENV PATH /lib/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 


# PORT
EXPOSE 50010 50075 50475 50020
