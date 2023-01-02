#!/bin/sh

sudo sh -c "echo 'ClientAliveInterval 50' >> /etc/ssh/sshd_config"
sudo service sshd restart
