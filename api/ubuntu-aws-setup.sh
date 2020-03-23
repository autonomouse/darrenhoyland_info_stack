#!/usr/bin/env bash

SRV="/opt/stack"
APP="api"
PORT="8000"
DESCRIPTION="API microservice"
POETRYURL="https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py"
STACKURL="https://github.com/autonomouse/darrenhoyland_info_stack.git"


printf '=========================== Cloning the Repository ============================== \n'

sudo mkdir -p $SRV
sudo git clone $STACKURL $SRV
cd $APP
WD=`pwd`

printf '=============================== Getting Poetry ================================== \n'

curl -sSL $POETRYURL | python3
$HOME/.poetry/bin/poetry config virtualenvs.create false


printf '========================= Setting up the Application ============================ \n'

$HOME/.poetry/bin/poetry install -n
GUNICORNCMD='gunicorn --config gunicorn.conf --bind ":$PORT $APP.App:app"'


printf '=========================== Creating Systemd service ============================= \n'

TARGET="/etc/systemd/system/$APP.service"
echo "" > $TARGET
echo "[Unit]" >> $TARGET
echo "Description=$DESCRIPTION" >> $TARGET
echo "After=network.target" >> $TARGET
echo "" >> $TARGET
echo "[Service]" >> $TARGET
echo "PermissionsStartOnly = true" >> $TARGET
echo "PIDFile = /run/$APP/$APP.pid" >> $TARGET
echo "User = $APP" >> $TARGET
echo "Group = $APP" >> $TARGET
echo "WorkingDirectory = $SRV" >> $TARGET
echo "ExecStartPre = /bin/mkdir /run/$APP" >> $TARGET
echo "ExecStartPre = /bin/chown -R $APP:$APP /run/$APP" >> $TARGET
echo "ExecStart = /usr/bin/env $GUNICORNCMD --pid /run/$APP/$APP.pid" >> $TARGET
echo "ExecReload = /bin/kill -s HUP $MAINPID" >> $TARGET
echo "ExecStop = /bin/kill -s TERM $MAINPID" >> $TARGET
echo "ExecStopPost = /bin/rm -rf /run/$APP" >> $TARGET
echo "PrivateTmp = true" >> $TARGET

sudo chmod 755 $TARGET
sudo systemctl enable $APP.service
sudo systemctl daemon-reload


printf '============================= Starting the service =============================== \n'

sudo systemctl start $APP.service


printf '============================= Obtaining service status =========================== \n'

sudo systemctl status $APP.service
