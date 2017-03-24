###
# Librairies des informations sur les processus
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne la liste de tous les process
##
function Process.list()
{
    ps ax
}


###
# Retourne si un process tourne
# @param $1 : PID ou nom du process
##
function Process.running()
{
    if Digit.integer $1; then
        ps --pid $1 > /dev/null && return 0
    else
        Process.list | grep -v grep | grep "$1" > /dev/null && return 0
    fi
    return 1
}


###
# Retourne le nombre de process pour un process
# @param $1 : Nom du process
##
function Process.count()
{
     Process.list | grep -v grep | grep -v $$ | grep "$1" | wc -l
}


###
# Retourne le PID d'un process
# @param $1 : Nom du process
##
function Process.id()
{
    Process.list | grep -i "$1" | grep -v grep | head -1 | sed 's/ \?\([0-9]*\).*/\1/'
}


###
# Tue un processus
# @param $1 : PID ou nom du process
##
function Process.kill()
{
    [[ -n "$2" ]] && local SIGNAL="$2" || local SIGNAL="SIGTERM"
    if Digit.integer $1; then
        local PID=$1
    else
        local PID=$(Process.id "$1")
    fi
    if [[ -n "$PID" ]]; then
        kill --signal $SIGNAL $PID 2> /dev/null
    fi
}
