#!/bin/sh

echo "==================================="
echo "    Loading Nic"
echo "==================================="
#sudo rtecli -p 20206 design-load -p out/pif_design.json -c rules.p4cfg -f ./out/app.nffw
sudo -E env "PATH=$PATH" rtecli -p 20206 design-load -p out/pif_design.json -f ./out/app.nffw

echo "==================================="
echo "    Binding to igb_uio"
echo "==================================="
sudo -E $RTE_SDK/usertools/dpdk-devbind.py --bind igb_uio 0000:05:08.0
sudo -E $RTE_SDK/usertools/dpdk-devbind.py --bind igb_uio 0000:05:08.1
sudo -E $RTE_SDK/usertools/dpdk-devbind.py --bind igb_uio 0000:05:08.2
sudo -E $RTE_SDK/usertools/dpdk-devbind.py --bind igb_uio 0000:05:08.3

echo "==================================="
echo "    DONE"
echo "==================================="
