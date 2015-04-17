###
# Installation des modules oliXsh
# ==============================================================================
# @package olixsh
# @command install
# @author Olivier <sabinus52@gmail.com>
##

OLIX_COMMAND_NAME="install"


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
    logger_debug "command_install__olixcmd_usage ()"
    stdout_printVersion
    echo
    echo -e "Installation des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}install ${CJAUNE}[MODULE]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    echo -e "${Cjaune} olix ${CVOID}        : Installation de oliXsh sur le système"
    module_printList
}


###
# Function principale
##
olixcmd_main()
{
    logger_debug "command_install__olixcmd_main ($@)"
    local MODULE=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixcmd_usage && core_exit 1
    [[ "$1" == "help" ]] && olixcmd_usage && core_exit 0

    case ${MODULE} in
        olix) olixcmd__olixsh;;
        *)    olixcmd__module $1;;
    esac
}


###
# Installation du module
# @param $1 : Nom du module
##
olixcmd__module()
{
    logger_debug "command_install__olixcmd__olixsh ($1)"

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"
    
    logger_info "Vérification du module $1"
    if ! $(module_isExist $1); then
        logger_warning "Le module '$1' est inéxistant"
        exit 1
    fi

    logger_info "Vérification si le module est installé"
    if $(module_isInstalled $1); then
        logger_warning "Le module '$1' est déjà installé"
        exit 1
    fi

    logger_info "Téléchargement du module"
    module_download $1
    [[ $? -ne 0 ]] && logger_error "Impossible de télécharger le module $1"
    
    module_deploy $1
    [[ $? -ne 0 ]] && logger_error "Impossible de déployer le module $1"
}


###
# Installation de Olix dans le système
##
olixcmd__olixsh()
{
    logger_debug "command_install__olixcmd__olixsh ()"

    # Fore l'activation des warnings
    OLIX_OPTION_WARNINGS=true

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer l'installation d'oliXsh"

    echo -e "${CBLANC}Installation de oliXsh dans le système${CVOID}"
    echo -e "${CBLANC}--------------------------------------${CVOID}"

    logger_info "Vérification des binaires requis"
    system_whichBinaries "${OLIX_BINARIES_REQUIRED}"
    [[ $? -ne 0 ]] && echo && logger_warning "ATTENTION !!! Ces binaires sont requis pour le bon fonctionnement de oliXsh" && echo

    olixcmd__createLinkShell

    echo -e "${CVERT}L'installation s'est terminé avec succès${CVOID}"
}


###
# Effectue un lien vers l'interpréteur olixsh depuis /bin/olixsh pour l'installation
##
function olixcmd__createLinkShell()
{
    logger_debug "olixcmd__createLinkShell ()"
    logger_info "Création du lien ${OLIX_CORE_SHELL_LINK}"
    ln -sf $(pwd)/${OLIX_CORE_SHELL_NAME} ${OLIX_CORE_SHELL_LINK} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le lien ${OLIX_CORE_SHELL_LINK}"
}