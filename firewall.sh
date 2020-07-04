#!/bin/bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22
sudo ufw allow 587
sudo ufw allow 25
sudo ufw allow 443
sudo ufw allow 993
sudo ufw allow 80
sudo ufw allow 3306

sudo ufw enable