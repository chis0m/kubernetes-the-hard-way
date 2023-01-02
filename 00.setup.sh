#!/bin/bash

echo "\033[33m BEGIN SETUP...\033[0m"

sh 01.pki.sh
sh 02.copykeys.sh
sh 03.kubeconfig.sh
sh 04.copyconfig.sh
sh 05.etcd.sh
sh 06.controlplane.sh
sh 07.worker.sh

echo "\033[32m SETUP COMPLETED SUCCESSFULLY !!!\033[0m"
