#!/bin/bash

# install deps
sudo apt install flex bison g++ gcc autoconf gperf -y

# clone repo
git clone https://github.com/steveicarus/iverilog.git
cd iverilog/
sh autoconf.sh
./configure
make

sudo make install

pip install sootty
