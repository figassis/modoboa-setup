#!/bin/bash
echo "Change version file. Also, script not ready."
exit
sudo su - modoboa
source env/bin/activate
pip install modoboa==1.6.3
cd instance
python manage.py migrate
yes | python manage.py collectstatic
exit
sudo service nginx restart
sudo service postfix restart
