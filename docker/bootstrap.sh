#!/bin/bash

apt update \
&& apt install -y --no-install-recommends openssh-server python3 python3-apt sudo ca-certificates \
&& rm -rf /var/lib/apt/lists/*

useradd -m -s /bin/bash ansible \
&& echo 'ansible:ansible' | chpasswd \
&& usermod -aG sudo ansible \
&& echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

mkdir -p /var/run/sshd /home/ansible/.ssh \
&& chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh

# Настройка SSH для работы с ключами
cat /root/.ssh/key.pub >> /root/.ssh/authorized_keys

/usr/sbin/sshd -D