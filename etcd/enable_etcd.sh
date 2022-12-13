#!/bin/bash

# config ssh
sudo sh -c "echo 'ClientAliveInterval 50' >> /etc/ssh/sshd_config"
sudo service sshd restart

# start and enable etcd
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
