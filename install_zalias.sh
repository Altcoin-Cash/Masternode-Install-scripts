#!/bin/bash

TMP_FOLDER=$(mktemp -d)
NAME_COIN="ZALIAS"
GIT_REPO="https://github.com/zaliasdev/zaliascore.git"
BINARY_FILE="zaliasd"
BINARY_CLI="/usr/local/bin/zalias-cli"
BINARY_CLI_FILE="zalias-cli"
BINARY_PATH="/usr/local/bin/${BINARY_FILE}"
DIR_COIN=".zaliascore"
CONFIG_FILE="zalias.conf"
DEFULT_PORT=7936

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function prepare_system() {

	echo -e "Prepare the system to install ${NAME_COIN} master node."
	apt-get update 
	DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade 
	apt install -y software-properties-common 
	echo -e "${GREEN}Adding bitcoin PPA repository"
	apt-add-repository -y ppa:bitcoin/bitcoin 
	echo -e "Installing required packages, it may take some time to finish.${NC}"
	apt-get update
	apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
	build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
	libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils \
	libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban pwgen libzmq3-dev autotools-dev pkg-config libevent-dev libboost-all-dev
	clear
	if [ "$?" -gt "0" ];
	  then
	    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
	    echo "apt-get update"
	    echo "apt -y install software-properties-common"
	    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
	    echo "apt-get update"
	    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
	libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git pwgen curl libdb4.8-dev \
	bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban pwgen libzmq3-dev autotools-dev pkg-config libevent-dev libboost-all-dev"
	 exit 1
	fi

	clear
	echo -e "Checking if swap space is needed."
	PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
	if [ "$PHYMEM" -lt "2" ];
	  then
	    echo -e "${GREEN}Server is running with less than 2G of RAM, creating 2G swap file.${NC}"
	    dd if=/dev/zero of=/swapfile bs=1024 count=2M
	    chmod 600 /swapfile
	    mkswap /swapfile
	    swapon -a /swapfile
	else
	  echo -e "${GREEN}Server running with at least 2G of RAM, no swap needed.${NC}"
	fi
	clear
}

function checks() {
	if [[ $(lsb_release -d) != *16.04* ]]; then
	  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
	  exit 1
	fi

	if [[ $EUID -ne 0 ]]; then
	   echo -e "${RED}$0 must be run as root.${NC}"
	   exit 1
	fi

	if [ -n "$(pidof ${BINARY_FILE})" ]; then
	  echo -e "${GREEN}\c"
	  read -e -p "${NAME_COIN} is already running. Do you want to add another MN? [Y/N]" ISNEW
	  echo -e "{NC}"
	  clear
	else
	  ISNEW="new"
	fi
}

function compile_server() {
  	echo -e "Clone git repo and compile it. This may take some time. Press a key to continue."
	read -n 1 -s -r -p ""

	git clone $GIT_REPO $TMP_FOLDER
	cd $TMP_FOLDER

	./autogen.sh
	./configure
	make

	cp -a $TMP_FOLDER/src/$BINARY_FILE $BINARY_PATH
	cp -a $TMP_FOLDER/src/$BINARY_CLI_FILE $BINARY_CLI
  clear
}

function ask_user() {
	  DEFAULT_USER="worker01"
	  read -p "${NAME_COIN} user: " -i $DEFAULT_USER -e WORKER
	  : ${WORKER:=$DEFAULT_USER}

	  if [ -z "$(getent passwd $WORKER)" ]; then
	    useradd -m $WORKER
	    USERPASS=$(pwgen -s 12 1)
	    echo "$WORKER:$USERPASS" | chpasswd

	    HOME_WORKER=$(sudo -H -u $WORKER bash -c 'echo $HOME')
	    DEFAULT_FOLDER="$HOME_WORKER/${DIR_COIN}"
	    read -p "Configuration folder: " -i $DEFAULT_FOLDER -e WORKER_FOLDER
	    : ${WORKER_FOLDER:=$DEFAULT_FOLDER}
	    mkdir -p $WORKER_FOLDER
	    chown -R $WORKER: $WORKER_FOLDER >/dev/null
	  else
	    clear
	    echo -e "${RED}User exits. Please enter another username: ${NC}"
	    ask_user
	  fi
}

function check_port() {
	  declare -a PORTS
	  PORTS=($(netstat -tnlp | awk '/LISTEN/ {print $4}' | awk -F":" '{print $NF}' | sort | uniq | tr '\r\n'  ' '))
	  ask_port

	  while [[ ${PORTS[@]} =~ $PORT_COIN ]] || [[ ${PORTS[@]} =~ $[PORT_COIN+1] ]]; do
	    clear
	    echo -e "${RED}Port in use, please choose another port:${NF}"
	    ask_port
	  done
}


function ask_port() {
	read -p "${NAME_COIN} Port: " -i $DEFULT_PORT -e PORT_COIN
	: ${PORT_COIN:=$DEFULT_PORT}
}


function create_config() {
	RPCUSER=$(pwgen -s 8 1)
	RPCPASSWORD=$(pwgen -s 15 1)
cat << EOF > $WORKER_FOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$[PORT_COIN+1]
listen=1
server=1
daemon=1
port=$PORT_COIN
EOF
}

function create_key() {
	  echo -e "Enter your ${RED}Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
	  read -e KEY_COIN
	  if [[ -z "$KEY_COIN" ]]; then
	  sudo -u $WORKER $BINARY_PATH -conf=$WORKER_FOLDER/$CONFIG_FILE -datadir=$WORKER_FOLDER
	  sleep 15
	  if [ -z "$(pidof ${BINARY_FILE})" ]; then
	   echo -e "${RED}${NAME_COIN} server couldn't start. Check /var/log/syslog for errors.{$NC}"
	   exit 1
	  fi
	  KEY_COIN=$(sudo -u $WORKER $BINARY_CLI -conf=$WORKER_FOLDER/$CONFIG_FILE -datadir=$WORKER_FOLDER masternode genkey)
	  sudo -u $WORKER $BINARY_CLI -conf=$WORKER_FOLDER/$CONFIG_FILE -datadir=$WORKER_FOLDER stop
	  fi
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $WORKER_FOLDER/$CONFIG_FILE
  NODEIP=$(curl -s4 icanhazip.com)
  cat << EOF >> $WORKER_FOLDER/$CONFIG_FILE
logtimestamps=1
maxconnections=256
masternode=1
externalip=$NODEIP:$PORT_COIN
masternodeprivkey=$KEY_COIN
EOF
  chown -R $WORKER: $WORKER_FOLDER >/dev/null
}

function enable_firewall() {
  echo -e "Installing ${GREEN}fail2ban${NC} and setting up firewall to allow ingress on port ${GREEN}$PORT_COIN${NC}"
  ufw allow $PORT_COIN/tcp comment "${NAME_COIN} MN port" >/dev/null
  ufw allow $[PORT_COIN+1]/tcp comment "${NAME_COIN} RPC port" >/dev/null
  ufw allow ssh >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  systemctl enable fail2ban >/dev/null 2>&1
  systemctl start fail2ban >/dev/null 2>&1
}

function systemd_up() {
  cat << EOF > /etc/systemd/system/$WORKER.service
[Unit]
Description=${NAME_COIN} service
After=network.target
[Service]
Type=forking
User=$WORKER
Group=$WORKER
WorkingDirectory=$WORKER_FOLDER
ExecStart=$BINARY_PATH -daemon
ExecStop=$BINARY_PATH stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
  
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $WORKER.service
  systemctl enable $WORKER.service >/dev/null 2>&1

  if [[ -z "$(pidof ${BINARY_FILE})" ]]; then
    echo -e "${RED}${NAME_COIN} is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo "systemctl start $WORKER.service"
    echo "systemctl status $WORKER.service"
    echo "less /var/log/syslog"
    exit 1
  fi
}

function resumen() {
 echo
 echo -e "================================================================================================================================"
 echo -e "${NAME_COIN} Masternode is up and running as user ${GREEN}$WORKER${NC} and it is listening on port ${GREEN}$PORT_COIN${NC}."
 echo -e "${GREEN}$WORKER${NC} password is ${RED}$USERPASS${NC}"
 echo -e "Configuration file is: ${RED}$WORKER_FOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $WORKER.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $WORKER.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$PORT_COIN${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$KEY_COIN${NC}"
 echo -e "================================================================================================================================"
}

function setup_node() {
	ask_user
	check_port
	create_config
	create_key
	update_config
	enable_firewall
	systemd_up
	resumen
}

######################################################
#                      Main Script                   #
######################################################

clear

checks
if [[ ("$ISNEW" == "y" || "$ISNEW" == "Y") ]]; then
  setup_node
  exit 0
elif [[ "$ISNEW" == "new" ]]; then
  prepare_system
  compile_server
  setup_node
else
  echo -e "${GREEN}${NAME_COIN} already running.${NC}"
  exit 0
fi
