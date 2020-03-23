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
GUNICORNCMD='gunicorn --config gunicorn.conf --bind ":'$PORT' '$APP'.App:app"'


printf '=========================== Creating Systemd service ============================= \n'

TMP_TARGET="/tmp/tmp_$APP.service"
TARGET="/etc/systemd/system/$APP.service"

echo "" > $TMP_TARGET
echo "[Unit]" >> $TMP_TARGET
echo "Description=$DESCRIPTION" >> $TMP_TARGET
echo "After=network.target" >> $TMP_TARGET
echo "" >> $TMP_TARGET
echo "[Service]" >> $TMP_TARGET
echo "PermissionsStartOnly = true" >> $TMP_TARGET
echo "PIDFile = /run/$APP/$APP.pid" >> $TMP_TARGET
echo "User = $APP" >> $TMP_TARGET
echo "Group = $APP" >> $TMP_TARGET
echo "WorkingDirectory = $SRV" >> $TMP_TARGET
echo "ExecStartPre = /bin/mkdir /run/$APP" >> $TMP_TARGET
echo "ExecStartPre = /bin/chown -R $APP:$APP /run/$APP" >> $TMP_TARGET
echo "ExecStart = /usr/bin/env $GUNICORNCMD --pid /run/$APP/$APP.pid" >> $TMP_TARGET
echo "ExecReload = /bin/kill -s HUP $MAINPID" >> $TMP_TARGET
echo "ExecStop = /bin/kill -s TERM $MAINPID" >> $TMP_TARGET
echo "ExecStopPost = /bin/rm -rf /run/$APP" >> $TMP_TARGET
echo "PrivateTmp = true" >> $TMP_TARGET

sudo mv $TMP_TARGET $TARGET
sudo chmod 755 $TARGET
sudo systemctl enable $APP.service
sudo systemctl daemon-reload


printf '============================= Starting the service =============================== \n'

sudo systemctl start $APP.service


printf '============================= Obtaining service status =========================== \n'

sudo systemctl status $APP.service
