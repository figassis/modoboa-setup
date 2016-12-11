#!/bin/bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22
sudo ufw allow 587
sudo ufw allow 25
sudo ufw allow 443
sudo ufw allow 993
sudo ufw allow 80

sudo ufw allow from 127.0.0.1 to any port 143
sudo ufw allow from 127.0.0.1 to any port 10024
sudo ufw allow from 127.0.0.1 to any port 10025
sudo ufw allow from 127.0.0.1 to any port 10026
sudo ufw allow from 127.0.0.1 to any port 9998
sudo ufw allow from 127.0.0.1 to any port 34607
sudo ufw allow from 127.0.0.1 to any port 58278
sudo ufw allow from 127.0.0.1 to any port 3306
sudo ufw allow from 107.170.24.173 to any port 3306
sudo ufw enable