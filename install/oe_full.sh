#!/bin/bash

echo "Installer for 'Graph-OpenEthereum full node' on 'Ubuntu 18.04'"
echo "Will install with '--config non-standard-ports' as parameter"

# variables
useraccount="oefull"
blockstart=10400000
unitname=oefull

if [ $USER != "$useraccount" ]; then

	# CHECK root
	if ! [ $(id -u) = 0 ]; then
	   echo "Script must be run as root / sudo."
	   exit 1
	fi
	
	# user account
	adduser --disabled-password --gecos "" $useraccount
	
	# packages
	apt-get install unzip
	
		# create unitfile
	tee "/etc/systemd/system/$unitname.service" <<EOD
[Unit]
Description=ETH full node (openethereum)
After=network-online.target

[Service]
User=$useraccount
WorkingDirectory=/home/$useraccount/
ExecStart=/home/$useraccount/oe/openethereum --db-compaction=ssd --cache-size-db=15360 --config non-standard-ports --warp-barrier $blockstart
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=3
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
EOD
	
	# switch user
	echo "login as $gebruiker by running 'su $gebruiker' and start script again"
	su $useraccount
	exit 0
	
else
	
	# download openethereum
	mkdir oe
	cd oe
	wget https://github.com/openethereum/openethereum/releases/download/v3.0.1/openethereum-linux-v3.0.1.zip
	unzip openethereum-linux-v3.0.1.zip
	chmod +x ethkey
	chmod +x ethstore
	chmod +x openethereum
	chmod +x openethereum-evm
	
	echo -e "Run 'sudo systemctl start $unitname' & 'sudo systemctl enable $unitname'"
	echo "To see how your indexer is doing, run 'sudo journalctl --follow -o cat -u $unitname' (ctrl+c to stop the logview)."
	
fi
