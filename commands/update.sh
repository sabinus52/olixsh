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
        olix) command_update_olixsh;;
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


###
# Mise à jour d'Olix
##
function command_update_olixsh()
{
    logger_debug "command_update_olixsh ()"

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    command_update_olixsh_download
    [[ $? -ne 0 ]] && logger_error "Impossible de télécharger la mise à jour oliXsh"
    command_update_olixsh_deploy
    [[ $? -ne 0 ]] && logger_error "Impossible de déployer la mise à jour oliXsh"

    echo -e "${CVERT}La mise à jour de ${CCYAN}oliXsh${CVERT} s'est terminé avec succès${CVOID}"
}


###
# Télécharge la mise à jour d'Olix
##
function command_update_olixsh_download()
{
    logger_debug "command_update_olixsh_download ($1)"

    local URL=$(curl -s ${OLIX_CORE_GITURL} | grep 'tarball_url' | cut -d\" -f4)
    
    logger_info "Téléchargement de la mise à jour à l'adresse ${URL}"

    local OPTS="--tries=3 --timeout=30 --no-check-certificate"
    [[ ${OLIX_OPTION_VERBOSEDEBUG} == true ]] && OPTS="${OPTS} --debug"
    [[ ${OLIX_OPTION_VERBOSE} == false ]] && OPTS="${OPTS} --quiet"
    OPTS="${OPTS} --output-document=/tmp/olixsh.tar.gz"
    logger_debug "wget ${OPTS} ${URL}"

    wget ${OPTS} ${URL}
    return $?
}


###
# Déploiement de la mise à jour
##
function command_update_olixsh_deploy()
{
    logger_debug "command_update_olixsh_deploy ()"

    file_extractArchive "/tmp/olixsh.tar.gz" "/tmp" "--gzip"
    [[ $? -ne 0 ]] && return 1

    local DIRTAR="/tmp/$(tar -tf /tmp/olixsh.tar.gz | grep -o '^[^/]\+' | sort -u)"

    logger_info "Copie des fichiers à mettre à jour"
    cp ${DIRTAR}/completion/olixmain ${OLIX_ROOT}/completion > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/conf/modules.lst ${OLIX_ROOT}/conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/include/* ${OLIX_ROOT}/include > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/lib/* ${OLIX_ROOT}/lib > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/commands/* ${OLIX_ROOT}/commands > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/olixsh ${OLIX_ROOT} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/LICENSE ${OLIX_ROOT} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/VERSION ${OLIX_ROOT} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    cp ${DIRTAR}/README.md ${OLIX_ROOT} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1

    return 0
}