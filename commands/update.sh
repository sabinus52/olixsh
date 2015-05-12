###
# Mise à jour des modules oliXsh
# ==============================================================================
# @package olixsh
# @command update
# @author Olivier <sabinus52@gmail.com>
##

OLIX_COMMAND_NAME="update"


###
# Librairies necessaires
##
source lib/module.lib.sh
source lib/system.lib.sh
source lib/file.lib.sh



###
# Usage de la commande
##
olixcmd_usage()
{
    logger_debug "command_update__olixcmd_usage ()"
    stdout_printVersion
    echo
    echo -e "Mise à jour des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}update ${CJAUNE}[MODULE]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    echo -e "${Cjaune} olix ${CVOID}        : Mise à jour de oliXsh"
    module_printListInstalled
}


###
# Fonction de liste
##
olixcmd_list()
{
    logger_debug "command_update__olixcmd_list ($@)"
    while [[ $# -ge 1 ]]; do
        case $1 in
            --with-olix) 
                echo -n "olix "
                ;;
        esac
        shift
    done
    module_getListInstalled
}


###
# Function principale
##
olixcmd_main()
{
    logger_debug "command_update__olixcmd_main ($@)"
    local MODULE=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixcmd_usage && core_exit 1
    [[ "$1" == "help" ]] && olixcmd_usage && core_exit 0

    case ${MODULE} in
        olix) olixcmd__olixsh;;
        *)    command_update_module $1;;
    esac
}


###
# Mise à jour du module
# @param $1 : Nom du module
##
function command_update_module()
{
    logger_debug "command_update_module ($1)"

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"
    
    logger_info "Vérification du module $1"
    if ! $(module_isExist $1); then
        logger_warning "Le module '$1' est inéxistant"
        core_exit 1
    fi

    logger_info "Vérification si le module est installé"
    if ! $(module_isInstalled $1); then
        logger_warning "Le module '$1' n'est pas installé"
        stdout_print "Essayer : ${CBLANC}$(basename ${OLIX_ROOT_SCRIPT}) install $1${CVOID} pour installer le module"
        core_exit 1
    fi

    module_install $1

    echo -e "${CVERT}La mise à jour du module ${CCYAN}$1${CVERT} s'est terminé avec succès${CVOID}"
}
