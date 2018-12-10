# hadpark
## Environment requirements
    1. Ubuntu14.04+
    2. Java7+
    3. Docker(current version)
    4. Network
    5. User in the group which have sudo privilige
## Targets
    1. 3 datanodes in 3 docker containers
    2. 1 namenode in master
    3. spark in master
## Todo
    1. add config in master
    2. run hadoop
    3. config spark 
## Experience
    1. when config sshd without pw in slave, should change config file /etc/ssh/sshd_config as followings:
        > UsePAM no
        > PasswordAuthentication no
    2. As it hasn't been explicitly mentioned, sshd is by default very strict on permissions on for the authorized_keys files. So, if authorized_keys is writable for anybody other than the user or can be made writable by anybody other than the user, it'll refuse to authenticate (unless sshd is configured with StrictModes no)

    3. docker run ... /bin/bash will override CMD ... in Dockerfile
