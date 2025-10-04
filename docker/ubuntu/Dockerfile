FROM ubuntu:20.04
#RUN apt-get update && apt-get install -y nginx 

# Установка необходимых пакетов
RUN apt update \
 && apt install -y --no-install-recommends openssh-server python3 python3-apt sudo ca-certificates \
 && rm -rf /var/lib/apt/lists/*

#RUN mkdir -p -m 0700 ~/.ssh && cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# Создать пользователя ansible, задать пароль (для тестов) и дать sudo
RUN useradd -m -s /bin/bash ansible \
 && echo 'ansible:ansible' | chpasswd \
 && usermod -aG sudo ansible \
 && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Подготовить SSH
RUN mkdir -p /var/run/sshd /home/ansible/.ssh \
 && chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh

#RUN cat /root/.ssh/key.pub >> /home/ansible/.ssh/authorized_keys

EXPOSE 22 

CMD ["/bin/bash", "-c", "cat /key.pub > /home/ansible/.ssh/authorized_keys && /usr/sbin/sshd -D"]

LABEL maintainer="ubuntu-paz"
WORKDIR /app