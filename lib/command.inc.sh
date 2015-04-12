###
# Librairies de gestion des commandes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



OLIX_COMMAND_LIST_FILENAME="commands.lst"


###
# Affiche le menu des commands
##
function command_printList()
{
    logger_debug "command_printList ()"
    local COMMAND

    pad=$(printf '%0.1s' " "{1..60})

    while read I; do
        IFS=':' read -ra COMMAND <<< "$I"
        echo -en "${Cjaune} ${COMMAND[0]} ${CVOID} "
        stdout_strpad "${COMMAND[0]}" 10 " "
        echo -e " : ${COMMAND[1]}"
    done < ./commands/${OLIX_COMMAND_LIST_FILENAME}
}


###
# Execute la commande
# @param $@ : 
# @param $1 : Nom de la commande
##
function command_execute()
{
    local SCRIPT=$(command_getScript "$1")
    logger_debug "command_execute ($1) -> ${SCRIPT} avec ARGS : $@"
    logger_info "Execution de la commande $1"

    if command_isExist "$1"; then
        source ${SCRIPT}
        shift
        olix_cmd_main $@
        core_exit 0
    fi
    logger_warning "La commande $1 est inexistante"
    core_exit 1
}


###
# Retourne le nom du script a executer
# @param $1 : Nom de la commande
##
function command_getScript()
{
    echo -n "${OLIX_ROOT}/commands/$1.sh"
}


###
# Test si la commande existe
# @param $1 : Nom de la commande
##
function command_isExist()
{
    logger_debug "command_isExist ($1)"
    [[ -r $(command_getScript "$1") ]] && return 0
    return 1
}
