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
source lib/filesystem.lib.sh



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
    module_printList
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
    module_getListEnabled
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
        *)    olixcmd__module $1;;
    esac
}