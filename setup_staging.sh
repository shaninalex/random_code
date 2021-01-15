#!/bin/sh

APP_NAME=$1

# require to install git

sudo apt-get update
sudo apt-get upgrade
sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl


# check if folder git-hooks exists if not 
mkdir /home/${USER}/hooks
mkdir /home/${USER}/apps
mkdir /home/${USER}/apps/${APP_NAME}
mkdir /home/${USER}/apps/frontend/

APP_ROOT=/home/${USER}/apps/${APP_NAME}

git init --bare /home/${USER}/hooks/${APP_NAME}.git
cat << 'EOF' > /home/${USER}/hooks/${APP_NAME}.git/hooks/post-receive
#!/bin/bash

git --work-tree=${APP_ROOT} --git-dir=/home/alex/git_hooks/${APP_NAME}.git checkout -f

echo "Update requirements"
source ${APP_ROOT}/core/env/bin/activate
pip install -r ${APP_ROOT}/core/requirements.txt

echo "Update static files and database"
${APP_ROOT}/env/bin/python3 ${APP_ROOT}/core/manage.py collectstatic --noinput
${APP_ROOT}/env/bin/python3 ${APP_ROOT}/core/manage.py migrate

echo "Restart nginx daemon gunicorn"
sudo systemctl daemon-reload
sudo systemctl restart ${APP_NAME}
sudo systemctl restart nginx
sudo nginx -t && sudo systemctl restart nginx
EOF

chmod +x /home/${USER}/hooks/${APP_NAME}.git/hooks/post-receive



cat << 'EOF' > /etc/systemd/system/gunicorn.socket
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
EOF


cat << 'EOF' > /etc/systemd/system/gunicorn.service
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=${USER}
Group=www-data
WorkingDirectory=${APP_ROOT}/core/
ExecStart=${APP_ROOT}/core/env/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          ${APP_ROOT}.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket
sudo systemctl daemon-reload
sudo systemctl restart gunicorn


cat << 'EOF' > /etc/nginx/sites-available/tutorcore
server {
    listen 80;
    server_name ${APP_NAME}.domainame.com;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location / { 
        root mkdir /home/${USER}/apps/frontend/dist/frontend;
        try_files $uri $uri/ /index.html;
    }

    location /api/static/ {
        root ${APP_ROOT}/core;
    }

    location /api/ {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
sudo ufw delete allow 8000
sudo ufw allow 'Nginx Full'
sudo systemctl restart gunicorn
sudo systemctl daemon-reload
sudo systemctl restart gunicorn.socket gunicorn.service
sudo nginx -t && sudo systemctl restart nginx

sudo add-apt-repository ppa:certbot/certbot
sudo apt install python-certbot-nginx

sudo certbot --nginx -d tutorcore.shaninpersonal.xyz


