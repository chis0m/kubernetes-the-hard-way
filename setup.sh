#!/bin/bash

echo "\033[33m BEGIN SETUP...\033[0m"

sh pki.sh
sh copykeys.sh
sh kubeconfig.sh
sh copyconfig.sh
sh etcd.sh

echo "\033[32m SETUP COMPLETED SUCCESSFULLY !!!\033[0m"
