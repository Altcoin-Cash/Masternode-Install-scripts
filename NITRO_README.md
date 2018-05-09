# NITRO
Shell script to install a NITRO MasterNode on a Linux server running Ubuntu 16.04 x64.  Use it on your own risk.<br>
Multiples MN in same VPS not tested, this default to mainnet port.<br> The script create a worker and install the masternode in workers directory. You get the option to name worker.
This script was tested on [www.vultr.com](https://www.vultr.com/?ref=7408116) $5 Vps

***
## Installation:
```
wget -q https://raw.githubusercontent.com/Altcoin-Cash/Masternode-Install-scripts/master/install_nitro.sh
chmod 755 install_nitro.sh
./install_nitro.sh
```
NOTE: Due some pc problems while adding this script you may encounter an error "/bin/bash^M: bad interpreter: No such file or directory"
To fix, open your script with vi or vim and enter in vi command mode (key Esc), then type this:
:set fileformat=unix
Finally save it
:x! or :wq!
***

Follow the FEW steps and SAVE RESUMEN INFORMATION. 

## Desktop wallet setup

After the MN is up and running, you need to configure the desktop wallet accordingly. Here are the steps for NITRO Wallet
1. Open the **NITRO Desktop Wallet**.
1. Go to RECEIVE and create a New Address: **MasterNode01**
1. Send **1000** **NITRO** to **MasterNode01** address.
1. Wait for 20 confirmations.
1. Go to **Tools -> "Debug console - Console"**
1. Type the following command: **masternode outputs**
1. Go to  **Tools -> "Open Masternode Configuration File"**
1. Add the following entry:
```
alias IP:port masternodeprivkey collateral_output_txid collateral_output_index
```
* Alias: **MasterNode01** 
* Address: **VPS_IP:PORT** #see resumen after masternode install script on VPS
* masternodeprivkey: **Masternode Private Key** #see resumen masternode install script
* collateral_output_txid: **First value from Step 6**
* collateral_output_index:  **Second value from Step 6**
1. Save and close the file.
1. Go to **Masternode Tab**. If you tab is not shown, please enable it from: **Settings - Options - Wallet - Show Masternodes Tab**
1. Click **Update status** to see your node. If it is not shown, close the wallet and start it again. 
1. Select your MN and click **Start Alias** to start it.
1. Alternatively, open **Debug Console** and type:
```
masternode start-alias MasterNode01
```
***

## Usage:
Login with MasterNode User set on install Script
```
nitro-cli mnsync status
nitro-cli getinfo
nitro-cli masternode status #This command will show your masternode status
```

Also, if you want to check/start/stop **NITRO** , run one of the following commands as **root**:

```
systemctl status USER.service #To check the service is running.
systemctl start USER.service #To start NITRO service.
systemctl stop USER.service #To stop NITRO service.
systemctl is-enabled USER.service #To check whetether NITRO service is enabled on boot or not.
```

Replace USER with your worker name.
***

## Donations:  

Any donation is highly appreciated.  

**NITRO**: NMUXTjNWyi2UDzovhGbFcwyhh4SggkFH78
**Xeon**: 9faZx7BKi3E5FTnE9gUbQAaGGucb6isjoN<br>
**XMON**: MMtUrbr2PYY4HKBbYnLtwmYkDHdKfNL7iF<br>
**ZLS**: ZPyt8NnQ81y5WruGs9nBkezwon2SJxisau <br>
**BTC**: 1NswKQuXjsemtNMYXH4DkJNgmAiJp5d9MT  <br>
**ETH**: 0x478c06b33f2b03892dcbb03cd353defba356bc26 <br>
**LTC**: LfjAKi26j7uNj5Vivvwn6o6PRy8QDKq7QT<br>
