#!/bin/bash
 
# ======================================
# LOGGING
# ======================================
logfile=/tmp/lvmoperations.log

# Init Logfile
echo 'DISK OPERATIONS' > $logfile

log () {
    echo $1
    echo $1 >> $logfile 
}

 
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

log "Args: $*"

i=0
while test $# -gt 0
do
    log "num args: $#"
    log "Arg1: $1"

    array_index=$i
    log "array index: $array_index"
    mountpoint=$1
    log "mountpoint: $mountpoint"

    device_path=${new_disks[array_index]}
    log "device path: $device_path"
    device_name=$(echo $device_path | sed 's/.*\(...\)/\1/')
    log "device name: $device_name" 

    # determine next vg
    sequence_number=$(sudo lvs | awk '{print $2}' | wc -l)
    log "sequence number: $sequence_number"
    vgmntname="vg$sequence_number"
    log "vgmntname: $vgmntname"
    lvmntname=$(printf '%s' "$mountpoint" | sed 's,/,,g')
    log "lvmntname: $lvmntname"
  
    log "Processing mountpoint $sequence_number: $device_path -> $mountpoint"
    log "Mountpoint $sequence_number: $1" 
  
    # Create LVM
    if ls -l /dev | grep $device_name
    then
            log "Creating LVM $lvmntname on $device_path"
            sudo pvcreate $device_path
            sudo pvcreate $device_path >> $logfile
            log "pvs: "
            sudo pvs | grep $device_name
            sudo pvs | grep $device_name >> $logfile
            log "Creating VG $vgmntname"
            sudo vgcreate $vgmntname $device_path
            sudo vgcreate $vgmntname $device_path >> $logfile
            log "vgs: "
            sudo vgs | grep $vgmntname
            sudo vgs | grep $vgmntname >> $logfile
            log "Creating LV $lvmntname"
            sudo lvcreate -l 100%FREE -n $lvmntname $vgmntname
            log "lvs: "
            sudo lvs | grep $lvmntname
            sudo lvs | grep $lvmntname >> $logfile
            log "LVM $lvmntname created on $device_path"
    else
        log "There is no disk $device_path to create $lvmntname LVM"
    fi
  
    # Create FS
    log "Creating FS $lvmntname"
    if sudo lvs | grep $lvmntname
    then
            log "Creating FS $lvmntname"
            sudo mkfs.ext4 /dev/$vgmntname/$lvmntname
            log "FS $lvmntname created"
            log "mkdir $mountpoint"
            sudo mkdir $mountpoint
            name=$(sudo blkid | grep $lvmntname | cut -d ":" -f 1)
            log "name $name $mountpoint ext4 defaults 0 0 redirected to /etc/fstab"
            #sudo echo "$name     $mountpoint           ext4    defaults        0 0"  >> /etc/fstab
            echo "$name     $mountpoint           ext4    defaults        0 0"  | sudo tee -a  /etc/fstab
            log "Mounting $mountpoint"
            sudo mount -a
            log "Mounted $mountpoint"
    else
        log "There is no $lvmntname LVM to create a file system"
    fi
      
    log "Processing mountpoint $sequence_number: $device_path -> $mountpoint done"
    i=$((array_index+1))
    log "i: $i"
    shift
done