#!/bin/bash

################################
#               By Jason Zhang #
#                 3.8.6-1-ARCH #
# Wed Apr 10 19:16:04 CST 2013 #
################################

IP=
CHOICE=
USERNAME=$(cat /etc/iscsi/initiatorname.iscsi | cut -d '=' -f 2)
PASSWORD=
USERNAME_IN=
PASSWORD_IN=
NOCHAPCONFPATH=iscsid.conf.NOCHAP
CHAPCONFPATH=iscsid.conf.CHAP
DONECHAPCONFPATH=iscsid.conf.CHAP.done
#ISCSIDPATH=/etc/iscsi/iscsid.conf
ISCSIDPATH=/home/jason/temp/iscsid.conf
# if iscsid.conf does not exists, maybe you should uncomment the next line;)
#ISCSIDPATH=$(sudo find / -name iscsid.conf)
PV=
VG=
LV=
LVSIZE=
FSTYPE=
MOUNTPOINT=
ISMOUNT=

echo
echo '+--------------------------------+'
echo '| start discovering iscsi device |'
echo '+--------------------------------+'

echo 'enter the device ip: (maybe 192.168.1.128 or 129)'
read IP
sudo iscsiadm -m discovery -t sendtargets -p $IP
USERNAME_IN=$(sudo iscsiadm -m node)

echo '+----------------+'
echo '| discovery done |'
echo '+----------------+'

echo '---------------------'

echo '+------------------------------+'
echo '| start logining to the device |'
echo '+------------------------------+'

echo 'make a choice: '
echo '    1: without CHAP[default]'
echo '    2: with CHAP'
read CHOICE

case $CHOICE in
    2)
        echo 'enter the initiator password: '
        read PASSWORD
        echo 'enter the target password: '
        read PASSWORD_IN
        
        sed -e "s/_username_in_/${USERNAME_IN}/" $CHAPCONFPATH > \
            sed -e "s/_password_in_/${PASSWORD_IN}/" > \
            sed -e "s/_username_/${USERNAME}/" > \
            sed -e "s/_password_/${PASSWORD}/" > \
            $DONECHAPCONFPATH
        sudo cp -f $DONECHAPCONFPATH $ISCSIDPATH
        sudo rm -f $DONECHAPCONFPATH
        ;;
    *)
        sudo cp -f $NOCHAPCONFPATH $ISCSIDPATH
        ;;
esac

sudo iscsiadm -m node -L all

echo '+------------+'
echo '| login done |'
echo '+------------+'

echo 'do you want me to mount the lvm?'
echo 'to be continued...'
echo '+-----------------+'
echo '| start multipath |'
echo '+-----------------+'

sudo cp multipath.conf /etc/multipath.conf
sudo multipathd
sudo multipath -ll
echo 'choose which device you want to initialize a disk or partition for use by LVM: '
read PV
sudo pvcreate /dev/mapper/${PV}

echo 'type the volume group: '
read VG
sudo vgcreate $VG /dev/mapper/${PV}

echo 'type the logical volume: '
read LV
echo 'type the logical volume size: ( K for kilobbytes, M for megabytes, G for gigabytes, P for petabytes or E for exabytes. Default unit is megabytes)'
read LVSIZE
sudo lvcreate -L $LVSIZE $VG -n $LV
echo 'type the type of the filesystem: '
read FSTYPE
sudo mkfs.${FSTYPE} /dev/mapper/${VG}-${LV}

echo 'type the mount point: '
read MOUNTPOINT
sudo mkdir $MOUNTPOINT
echo 'mount the LVM now? [Y/n]'
read ISMOUNT
case $ISMOUNT in
    n)
        exit
        ;;
    *)
        sudo mount /dev/mapper/${VG}-${LV} $MOUNTPOINT
esac
echo 'mount done;)'

echo '+----------------+'
echo '| done multipath |'
echo '+----------------+'

echo 'Now recheck'
sudo df -h
