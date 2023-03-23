#!/bin/bash
 
# ======================================
# CONFIGURATION
# ======================================
logfile=/tmp/lvmoperations.log
 
# ======================================
# NEW DISK DETECTION:
# 1. List all disks
# 2. Take physical disks
# 3. Extract the last {number of arguments} disks
# ======================================
new_disks=($( \
    lsblk -ln --output NAME,TYPE | \
    grep disk | \
    tail -n $# | \
    awk '{print "/dev/" $1}' \
))
 
# ======================================
# DISK OPERATIONS
# ======================================
echo 'DISK OPERATIONS' > $logfile
i=0
while test $# -gt 0
do
    array_index=$i
    mountpoint=$1
    device_path=${new_disks[array_index]}
    device_name=$(echo $device_path | sed 's/.*\(...\)/\1/')
     
    # determine next vg
    sequence_number=$(lvs | awk '{print $2}' | wc -l)
    vgmntname="vg$sequence_number"
    lvmntname=$(printf '%s' "$mountpoint" | sed 's,/,,g')
  
    echo "Processing mountpoint $sequence_number: $device_path -> $mountpoint"
    echo "Mountpoint $sequence_number: $1" >> $logfile
  
    # Create LVM
    if ls -l /dev | grep $device_name
    then
            pvcreate $device_path
            pvs | grep $device_name
            vgcreate $vgmntname $device_path
            vgs | grep $vgmntname
            lvcreate -l 100%FREE -n $lvmntname $vgmntname
            lvs | grep $lvmntname
    else
        echo "There is no disk $device_path to create $lvmntname LVM"
        echo "There is no disk $device_path to create $lvmntname LVM" >> $logfile
    fi
  
    # Create FS
    if lvs | grep $lvmntname
    then
            mkfs.ext4 /dev/$vgmntname/$lvmntname
            mkdir $mountpoint
            name=$(blkid | grep $lvmntname | cut -d ":" -f 1)
            echo "$name     $mountpoint           ext4    defaults        0 0"  >> /etc/fstab
            mount -a
    else
        echo "There is no $lvmntname LVM to create a file system"
        echo "There is no $lvmntname LVM to create a file system" >>  $logfile
    fi
      
    i=$((array_index+1))
    shift
done