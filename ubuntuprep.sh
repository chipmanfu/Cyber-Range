#!/bin/bash
servername="RootDNS"
Proxy="http://172.30.0.2:9999"
adminnic="ens160"
graynic="ens192"
export http_proxy=$Proxy
export https_proxy=$Proxy

echo "Changings some environment settings"
sleep 2
echo "colo industry" > /root/.vimrc
echo 'LS_COLORS=$LSCOLORS:"di=96:"; export LS_COLORS' >> /root/.bashrc
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
mkdir /etc/update-motd.d/originals
mv /etc/update-motd.d/* /etc/update-motd.d/originals 2</dev/null

echo "#!/bin/bash" > /etc/update-motd.d/00-header
echo "echo 'Welcome to the'" >> /etc/update-motd.d/00-header
echo "figlet $servername" >> /etc/update-motd.d/00-header
clear
echo "Removing unncessary applications"
sleep 2
apt --purge remove -y cloud-* unattended-upgrades open-iscsi multipath-tools snapd nplan netplan.io
apt autoremove -y
rm -fr /root/snap
clear
echo "Disabling unnecssary services"
systemctl stop systemd-resolve.service systemd-timesyncd.service
systemctl disable system-resolve.service systemd-timesyncd.service
systemctl mask system-resolve.service systemd-timesyncd.service
rm /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
clear
echo "Installing needed applications"
sleep 2
apt install -y ifupdown net-tools curl make figlet ipcalc traceroute dos2unix
