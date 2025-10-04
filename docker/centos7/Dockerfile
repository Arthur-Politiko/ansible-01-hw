FROM ubuntu:20.04
#RUN apt-get update && apt-get install -y nginx 

# Установка необходимых пакетов
RUN apt update \
 && apt install -y --no-install-recommends openssh-server python3 python3-apt sudo ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# FROM centos7:latest
 
# RUN yum update -y && \
#     yum install -y epel-release && \
#     yum install -y openssh-server openssh-clients && \
#     yum -y install python3 python3-pip sudo ca-certificates && \
#     yum clean all

RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    usermod -aG sudo ansible && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Подготовить SSH
RUN mkdir -p /var/run/sshd /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh

EXPOSE 22
CMD ["/bin/bash", "-c", "cat /key.pub > /home/ansible/.ssh/authorized_keys && chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh && /usr/sbin/sshd -D"]

LABEL maintainer="centos7-paz"
WORKDIR /app

#ENTRYPOINT ["tail", "-f", "/dev/null"]

