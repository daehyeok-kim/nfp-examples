#!/bin/bash

echo "==================================="
echo "    Setting up kmod"
echo "==================================="
sudo modprobe -r nfp
sudo modprobe nfp nfp_dev_cpp=1 nfp_pf_netdev=0
sudo systemctl start nfp-sdk6-rte

sudo modprobe uio
sudo insmod igb_uio.ko

# RTE only works when netdev PFs are off
# I don't know why netronome had this in example P4_INT
# sudo ifconfig eth8 up

echo "==================================="
echo "    DONE"
echo "==================================="
