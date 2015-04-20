###
# Librairies de gestion des commandes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



OLIX_COMMAND_LIST="install update"


###
# Affiche le menu des commands
##
function command_printList()
{
    logger_debug "command_printList ()"
    echo -e "${Cjaune} install ${CVOID}     : Installation des modules oliXsh"
    echo -e "${Cjaune} update  ${CVOID}     : Mise à jour des modules oliXsh "
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
        if [[ ${OLIX_OPTION_LIST} == true ]]; then
            # Pour afficher des listes simple utile pour la complétion
            olixcmd_list $@
        else
            olixcmd_main $@
        fi
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
# Retourne le nom du script a executer
# @param $1 : Nom de la commande
# @param $2 : Nom de la sous commande
##
function command_getSubScript()
{
    echo -n "${OLIX_ROOT}/commands/$1/$2.sh"
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
