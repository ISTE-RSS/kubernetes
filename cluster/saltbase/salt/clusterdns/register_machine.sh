#!/bin/bash
echo -e "add woofwoof $(hostname).openstacklocal $(ip route get 1 | awk '{print $NF;exit}')" > /dev/tcp/10.0.0.3/9999
