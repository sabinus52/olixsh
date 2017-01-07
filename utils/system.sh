###
# Librairies des informations système
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne le Load Average
# @param $1 : 1 ou 5 ou 15
##
function System.loadaverage()
{
    debug "System.uptime ($1)"
    case $1 in
        5)  cat /proc/loadavg | cut -f 2 -d ' ';;
        15) cat /proc/loadavg | cut -f 3 -d ' ';;
        *)  cat /proc/loadavg | cut -f 1 -d ' ';;
    esac
}


###
# Retourne le nombre de processus
##
function System.processes()
{
    debug "System.processes ()"
    ps axue | grep -vE "^USER|grep|ps" | wc -l
}


###
# Retourne l'utilisation CPU
##
function System.processor.utilisation()
{
    debug "System.processor.utilisation ()"
    local TEMP USER SYSTEM

    TEMP=$(vmstat 1 3 |tail -1)
    USER=$(echo $TEMP |awk '{printf("%s\n",$13)}')
    SYSTEM=$(echo $TEMP |awk '{printf("%s\n",$14)}')
    echo|awk '{print (c1+c2)}' c1=$SYSTEM c2=$USER
}

###
# Retourne le nombre de coeur
##
function System.processor.cores()
{
    debug "System.processor.cores ()"
    grep -c ^processor /proc/cpuinfo 2>/dev/null
    [[ $? -ne 0 ]] && echo "1"
}



###
# Retourne l'utilisation de la RAM
##
function System.memory.utilisation()
{
    debug "System.memory.utilisation ()"
    local TOTAL USED CACHED

    TOTAL=$(free | grep 'Mem:' | awk '{ print $2 }')
    USED=$(free | grep 'Mem:' | awk '{ print $3 }')
    CACHED=$(free | grep 'Mem:' | awk '{ print $7 }')
    USED=$(expr $USED - $CACHED)
    echo $(expr $USED \* 100 / $TOTAL)
}



###
# Retourne l'utilisation du SWAP
##
function System.swap.utilisation()
{
    debug "System.swap.utilisation ()"
    local TOTAL USED

    swapon -s | grep /dev > /tmp/olix.swap.tmp
    for I in $(cat /tmp/olix.swap.tmp | awk '{ print $3 }'); do
        TOTAL=`expr $TOTAL + $I`
    done
    for I in $(cat /tmp/olix.swap.tmp | awk '{ print $4 }'); do
        USED=`expr $USED + $I`
    done
    echo $(expr $USED \* 100 / $TOTAL)
}



###
# Retourne la liste des UUID des partitions
##
function System.partitions()
{
    debug "System.partitions ()"
    lsblk -nr -o FSTYPE,UUID | egrep -v "^LVM2|^swap|^\s" | awk '{ print $2}'
}

###
# Retourne la liste des montages des partitions
##
function System.partitions.mount()
{
    debug "System.partitions.mount ()"
    lsblk -nr -o FSTYPE,MOUNTPOINT | egrep -v "^LVM2|^swap|^\s" | awk '{ print $2}'
}

###
# Retourne le nom de la partition
# @param $1 : UUID
##
function System.partition.name()
{
    debug "System.partition.name ($1)"
    df /dev/disk/by-uuid/$1 | awk '{ print $1}' | tail -1
}

###
# Retourne l'utilisation d'une partition
# @param $1 : UUID
##
function System.partition.utilisation()
{
    debug "System.partition.utilisation ($1)"
    df /dev/disk/by-uuid/$1 | awk '{ print $5}' | tail -1 | tr -d '%'
}

###
# Retourne le type de système de fichier d'une partition
# @param $1 : UUID
##
function System.partition.fstype()
{
    debug "System.partition.fstype ($1)"
    lsblk /dev/disk/by-uuid/$1 -o FSTYPE -n
}


###
# Retourne le point de montage d'une partition
# @param $1 : UUID
##
function System.partition.mount()
{
    debug "System.partition.mount ($1)"
    lsblk /dev/disk/by-uuid/$1 -o MOUNTPOINT -n
}
