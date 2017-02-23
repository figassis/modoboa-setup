#!/bin/bash
#Upgrade
#Backup /srv/modoboa/instance/sitestatic/css
#Backup /srv/modoboa/instance/media
#Change pdf text: /srv/modoboa/env/lib/python2.7/site-packages/modoboa_pdfcredentials/documents.py
#Change feed url: /srv/modoboa/env/lib/python2.7/site-packages/modoboa/core/views/dashboard.py
#Change blog link: /srv/modoboa/env/lib/python2.7/site-packages/modoboa/core/templates/core/dashboard.html

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
sudo service uwsgi restart
