#!/bin/bash

sudo apt-get install -y python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev
git clone https://github.com/modoboa/modoboa-installer
mv installer.cfg modoboa-installer/installer.cfg
cd modoboa-installer
sudo ./run.py bantumail.com
