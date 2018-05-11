Xeon

Shell script to install a IDAPAY MasterNode on a Linux server running Ubuntu 16.04 x64. Use it on your own risk.
Multiples MN in same VPS not tested, this default to mainnet port.
Script create a worker and install in worker directory. You get the option to name worker. This script was tested on www.vultr.com $5 Vps
Installation:

wget -q https://raw.githubusercontent.com/Altcoin-Cash/Masternode-Install-scripts/master/install_idapay.sh

chmod 755 install_idapay.sh

./install_idapay.sh

Follow the FEW steps and SAVE RESUMEN INFORMATION.
Desktop wallet setup

After the MN is up and running, you need to configure the desktop wallet accordingly. Here are the steps for Xeon Wallet

    Open the IDA Desktop Wallet.
    Go to RECEIVE and create a New Address: MasterNode01
    Send 1500 IDA to MasterNode01 address.
    Wait for 20 confirmations.
    Go to Tools -> "Debug console - Console"
    Type the following command: masternode outputs
    Go to Tools -> "Open Masternode Configuration File"
    Add the following entry:

alias IP:port masternodeprivkey collateral_output_txid collateral_output_index

    Alias: MasterNode01
    Address: VPS_IP:PORT #see resumen after masternode install script on VPS
    masternodeprivkey: Masternode Private Key #see resumen masternode install script
    collateral_output_txid: First value from Step 6
    collateral_output_index: Second value from Step 6

    Save and close the file.
    Go to Masternode Tab. If you tab is not shown, please enable it from: Settings - Options - Wallet - Show Masternodes Tab
    Click Update status to see your node. If it is not shown, close the wallet and start it again.
    Select your MN and click Start Alias to start it.
    Alternatively, open Debug Console and type:

masternode start-alias MasterNode01

Usage:

Login with MasterNode User set on install Script

idapay-cli mnsync status
idapay-cli getinfo
idapay-cli masternode status #This command will show your masternode status

Also, if you want to check/start/stop Xeon , run one of the following commands as root:

systemctl status idapay.service #To check the service is running.
systemctl start idapay.service #To start Xeon service.
systemctl stop idapay.service #To stop Xeon service.
systemctl is-enabled idapay.service #To check whetether Xeon service is enabled on boot or not.

Replace idapay with your worker name.
Donations:

Any donation is highly appreciated.

IDA: D2nB9nkZLfBRpdfT61SSuKdSryyWK1t9hJ
Xeon: 9faZx7BKi3E5FTnE9gUbQAaGGucb6isjoN
XMON: MMtUrbr2PYY4HKBbYnLtwmYkDHdKfNL7iF
ZLS: ZPyt8NnQ81y5WruGs9nBkezwon2SJxisau
BTC: 1NswKQuXjsemtNMYXH4DkJNgmAiJp5d9MT
ETH: 0x478c06b33f2b03892dcbb03cd353defba356bc26
LTC: LfjAKi26j7uNj5Vivvwn6o6PRy8QDKq7QT
