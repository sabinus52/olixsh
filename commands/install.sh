###
# Installation des modules oliXsh
# ==============================================================================
# @package olixsh
# @command install
# @author Olivier <sabinus52@gmail.com>
##

OLIX_COMMAND_NAME="install"

source lib/module.lib.sh
source lib/filesystem.lib.sh

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
    echo -e "${Cjaune} olixsh ${CVOID}      : Installation de oliXsh sur le système"
    module_printList
}


olixcmd_main()
{
    logger_debug "command_install__olixcmd_main ($@)"
    local MODULE=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixcmd_usage && core_exit 1
    [[ "$1" == "help" ]] && olixcmd_usage && core_exit 0

    case ${MODULE} in
        olixsh) olixcmd__olixsh;;
        *)      olixcmd__module $1;;
    esac
}


olixcmd__olixsh()
{
    logger_debug "command_install__olixcmd__olixsh ()"
    #source $(command_getSubScript ${OLIX_COMMAND_NAME} olixsh)
    #olix_cmd_main $@
    echo "coucou olixsh"

#    which logger > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"logger\" n'est pas présent"
#    which gzip > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"gzip\" n'est pas présent"
#    which bzip2 > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"bzip2\" n'est pas présent"
#    which tar > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"tar\" n'est pas présent"
#    which rsync > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"rsync\" n'est pas présent"
#    which mysql > /dev/null 2>&1
#    [[ $    ? -ne 0 ]] && logger_warning "Le binaire \"mysql\" n'est pas présent"
#    which mysqldump > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"mysqldump\" n'est pas présent"
#    which lftp > /dev/null 2>&1
#    [[ $? -ne 0 ]] && logger_warning "Le binaire \"lftp\" n'est pas présent"
#    wget
}


olixcmd__module()
{
    logger_debug "command_install__olixcmd__olixsh ($1)"

    logger_info "Vérification du module $1"
    if ! $(module_isExist $1); then
        logger_warning "Le module $1 est inéxistant"
        exit 1
    fi

    logger_info "Vérification si le module est installé"
    if $(module_isInstalled $1); then
        logger_warning "Le module $1 est déjà installé"
        exit 1
    fi

    logger_info "Téléchargement du module"
    module_download $1
    [[ $? -ne 0 ]] && logger_error "Impossible de télécharger le module $1"
    
    module_deploy $1
    [[ $? -ne 0 ]] && logger_error "Impossible de déployer le module $1"
    #source $(command_getSubScript ${OLIX_COMMAND_NAME} olixsh)
    #olix_cmd_main $@
    echo "coucou $1"
}