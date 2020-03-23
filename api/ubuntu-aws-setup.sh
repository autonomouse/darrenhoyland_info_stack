#!/usr/bin/env bash


printf '======================= Changing user and setting vars ========================== \n'

sudo su

SRV="/opt/stack"
APP="api"
PORT="8000"
DESCRIPTION="API microservice"
POETRYURL="https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py"
PYENVURL="https://pyenv.run"
STACKURL="https://github.com/autonomouse/darrenhoyland_info_stack.git"
PYVERS_MAJOR=3
PYVERS_MINOR=7
PYVERS_PATCH=5
PYVERSION=$PYVERS_MAJOR.$PYVERS_MINOR.$PYVERS_PATCH
PYTHON="python"$PYVERS_MAJOR.$PYVERS_MINOR


printf '=========================== Cloning the Repository ============================== \n'

mkdir -p $SRV
git clone $STACKURL $SRV
cd $SRV/$APP
WD=`pwd`

printf '============================= Apt/Pip Installing ================================ \n'

apt update
apt install --fix-missing -y build-essential $PYTHON python3-distutils libssl-dev \
zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git python3-pip \
gunicorn3
python3 -m pip install -U pip


printf '=============================== Getting PyEnv ================================== \n'

curl $PYENVURL | bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv update
if [ ! -d "$HOME/.pyenv/versions/$PYVERSION" ]; then
    pyenv install $PYVERSION;
fi


printf '=============================== Getting Poetry ================================== \n'

pyenv local $PYVERSION
curl -sSL $POETRYURL | $PYTHON
POETRY=$HOME/.poetry/bin/poetry
sed -i 's/python$/python3/g' $POETRY  # Nasty hack, but hey...
$POETRY self update
$POETRY config virtualenvs.create false


printf '========================= Setting up the Application ============================ \n'

$POETRY install -n
GUNICORNCMD='gunicorn3 --config gunicorn.conf --bind ":'$PORT'" '$APP'.App:app'


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
echo "WorkingDirectory = $SRV/$APP" >> $TMP_TARGET
echo "ExecStartPre = /bin/mkdir /run/$APP" >> $TMP_TARGET
echo "ExecStartPre = /bin/chown -R $APP:$APP /run/$APP" >> $TMP_TARGET
echo "ExecStart = /usr/bin/env $GUNICORNCMD --pid /run/$APP/$APP.pid" >> $TMP_TARGET
echo "ExecReload = /bin/kill -s HUP $MAINPID" >> $TMP_TARGET
echo "ExecStop = /bin/kill -s TERM $MAINPID" >> $TMP_TARGET
echo "ExecStopPost = /bin/rm -rf /run/$APP" >> $TMP_TARGET
echo "PrivateTmp = true" >> $TMP_TARGET

mv $TMP_TARGET $TARGET
chmod 755 $TARGET
systemctl enable $APP.service
systemctl daemon-reload


printf '============================= Starting the service =============================== \n'

systemctl start $APP.service


printf '============================= Obtaining service status =========================== \n'

systemctl status $APP.service

GUNICORNCMD
