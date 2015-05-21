###
# Suppression des modules oliXsh
# ==============================================================================
# @package olixsh
# @command remove
# @author Olivier <sabinus52@gmail.com>
##

OLIX_COMMAND_NAME="remove"


###
# Librairies necessaires
##
source lib/module.lib.sh
source lib/system.lib.sh
source lib/file.lib.sh


###
# Constantes
##



###
# Usage de la commande
##
olixcmd_usage()
{
    logger_debug "command_remove__olixcmd_usage ()"
    stdout_printVersion
    echo
    echo -e "Suppression des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}remove ${CJAUNE}module${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    module_printListInstalled
}


###
# Fonction de liste
##
olixcmd_list()
{
    logger_debug "command_remove__olixcmd_list ($@)"
    module_getListInstalled
}


###
# Function principale
##
olixcmd_main()
{
    logger_debug "command_remove__olixcmd_main ($@)"
    local MODULE=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixcmd_usage && core_exit 1
    [[ "$1" == "help" ]] && olixcmd_usage && core_exit 0

    command_remove_module $1
}


###
# Suppression du module
# @param $1 : Nom du module
##
function command_remove_module()
{
    logger_debug "command_remove_module ($1)"

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_critical "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"
    
    logger_info "Vérification du module $1"
    if ! $(module_isExist $1); then
        logger_warning "Le module '$1' est inéxistant"
        core_exit 1
    fi

    logger_info "Vérification si le module est installé"
    if ! $(module_isInstalled $1); then
        logger_warning "Le module '$1' n'est pas installé"
        core_exit 1
    fi

    module_removeCompletion $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de supprimer le fichier de completion du module $1"

    module_removeFileConfiguration $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de supprimer le fichier de configuration du module $1"
    
    module_removeDirModule $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de supprimer le module $1"

    echo -e "${CVERT}La suppression du module ${CCYAN}$1${CVERT} s'est terminé avec succès${CVOID}"
}
