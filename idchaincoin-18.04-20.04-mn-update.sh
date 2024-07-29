#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'idchaincoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop idchaincoind${NC}"
        idchaincoin-cli stop
        sleep 30
        if pgrep -x 'idchaincoind' > /dev/null; then
            echo -e "${RED}idchaincoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 idchaincoind
            sleep 30
            if pgrep -x 'idchaincoind' > /dev/null; then
                echo -e "${RED}Can't stop idchaincoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your IDCHAINCOIN Masternode Will be Updated To The Latest Version v1.0.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'idchaincoinauto.sh' | crontab -

#Stop idchaincoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/idchaincoin*
mkdir IDCHAINCOIN_1.0.0
cd IDCHAINCOIN_1.0.0
wget https://github.com/Idchaincoin/idchaincoin/releases/download/v1.0.0/idchaincoin-2.2.0-linux.tar.gz
tar -xzvf idchaincoin-2.2.0-linux.tar.gz
mv idchaincoind /usr/local/bin/idchaincoind
mv idchaincoin-cli /usr/local/bin/idchaincoin-cli
chmod +x /usr/local/bin/idchaincoin*
rm -rf ~/.idchaincoin/blocks
rm -rf ~/.idchaincoin/chainstate
rm -rf ~/.idchaincoin/sporks
rm -rf ~/.idchaincoin/evodb
rm -rf ~/.idchaincoin/zerocoin
rm -rf ~/.idchaincoin/peers.dat
cd ~/.idchaincoin/
wget https://github.com/Idchaincoin/idchaincoin/releases/download/v1.0.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.idchaincoin/bootstrap.zip ~/IDCHAINCOIN_1.0.0

# add new nodes to config file
sed -i '/addnode/d' ~/.idchaincoin/idchaincoin.conf

echo "addnode=155.138.156.125
addnode=216.128.179.249
addnode=155.138.149.241
addnode=155.138.135.104
addnode=155.138.135.104
addnode=155.138.135.104" >> ~/.idchaincoin/idchaincoin.conf

#start idchaincoind
idchaincoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.idchaincoin/idchaincoin.pid" ]; then /usr/local/bin/idchaincoind -daemon ; fi' > /root/idchaincoinauto.sh
chmod -R 755 /root/idchaincoinauto.sh
#Setting auto start cron job for IDCHAINCOIN
if ! crontab -l | grep "idchaincoinauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/idchaincoinauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"