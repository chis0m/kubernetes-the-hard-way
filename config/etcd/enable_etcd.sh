#!/bin/bash

# start and enable etcd
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
