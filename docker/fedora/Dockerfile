FROM fedora:latest

# Обновление и установка пакетов 
RUN dnf -y upgrade --refresh \
 && dnf -y install openssh-server python3 sudo ca-certificates \
 && dnf clean all

# Создать пользователя ansible 
RUN useradd -m -s /bin/bash ansible \
 && echo 'ansible:ansible' | chpasswd \
 && usermod -aG wheel ansible \
 && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Подготовить директории
RUN mkdir -p /var/run/sshd /home/ansible/.ssh \
 && chown -R ansible:ansible /home/ansible/.ssh \
 && chmod 700 /home/ansible/.ssh

# сгенерировать host keys (если ещё нет)
RUN ssh-keygen -A

EXPOSE 22
CMD ["/bin/bash", "-c", "cat /key.pub > /home/ansible/.ssh/authorized_keys && chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh && /usr/sbin/sshd -D"]

LABEL maintainer="fedora-paz"
WORKDIR /app

#ENTRYPOINT ["tail", "-f", "/dev/null"]