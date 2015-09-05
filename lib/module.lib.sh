###
# Librairie de la gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Installation complète du module
# @param $1 : Nom du module
##
function module_install()
{
    logger_debug "module_install ($1)"
    local UPDATE=false

    logger_info "Vérification du module $1"
    if ! $(module_isExist $1); then
        logger_warning "Le module '$1' est inéxistant"
        return 1
    fi

    logger_info "Vérification si le module est installé"
    if $(module_isInstalled $1); then
        logger_warning "Le module '$1' est déjà installé"
        module_removeDirModule $1
        UPDATE=true
        stdout_print "Mise à jour du module ${CCYAN}$1" "${CBLANC}"
    else
        stdout_print "Installation du module ${CCYAN}$1" "${CBLANC}"
    fi

    # Traitement
    module_download $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de télécharger le module $1"
    module_deploy $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de déployer le module $1"
    module_installCompletion $1
    [[ $? -ne 0 ]] && logger_critical "Impossible de déployer le fichier de completion du module $1"

    source $(module_getScript "$1")
    if [[ ${UPDATE} == false ]]; then
        stdout_print "Saisie des éléments de configuration du module ${CCYAN}$1" "${CBLANC}"
        olixmod_init install
    fi
    BINARIES="${BINARIES} $(olixmod_require_binary)"

    # Dépendances
    for I in $(olixmod_require_module); do
        module_install $I
    done

    system_whichBinaries "${BINARIES}"
}


###
# Télécharge le module
# @param $1 : Nom du module
##
function module_download()
{
    logger_debug "module_download ($1)"

    local URL=$(module_getUrl $1)
    logger_info "Téléchargement du module à l'adresse ${URL}"

    local OPTS="--tries=3 --timeout=30 --no-check-certificate"
    [[ ${OLIX_OPTION_VERBOSEDEBUG} == true ]] && OPTS="${OPTS} --debug"
    [[ ${OLIX_OPTION_VERBOSE} == false ]] && OPTS="${OPTS} --quiet"
    OPTS="${OPTS} --output-document=/tmp/olix.tar.gz"
    logger_debug "wget ${OPTS} ${URL}"

    wget ${OPTS} ${URL}
    return $?
}


###
# Déploiement du module dans le dossier /modules
# @param $1 : Nom du module
##
function module_deploy()
{
    logger_debug "module_deploy ($1)"

    file_extractArchive "/tmp/olix.tar.gz" "${OLIX_ROOT}/${OLIX_MODULE_DIR}" "--gzip"
    [[ $? -ne 0 ]] && return 1

    local DIRTAR=$(tar -tf /tmp/olix.tar.gz | grep -o '^[^/]\+' | sort -u)
    logger_info "Renommage de '${DIRTAR}' vers '$1'"
    mv ${OLIX_ROOT}/${OLIX_MODULE_DIR}/${DIRTAR} ${OLIX_ROOT}/${OLIX_MODULE_DIR}/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Install le fichier de completion
# @param $1 : Nom du module
##
function module_installCompletion()
{
    logger_debug "module_installCompletion ($1)"
    module_removeCompletion $1
    [[ ! -r modules/$1/completion ]] && return 0
    logger_info "Installation du fichier de completion"
    ln -s ../modules/$1/completion completion/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}


###
# Supprime le fichier de completion
# @param $1 : Nom du module
##
function module_removeCompletion()
{
    logger_debug "module_removeCompletion ($1)"
    if [[ -L completion/$1 || -f completion/$1 ]]; then
        logger_info "Suppression du fichier de completion"
        rm -f completion/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
        return $?
    fi
    return 0
}


###
# Supprime le fichier de configuration
# @param $1 : Nom du module
##
function module_removeFileConfiguration()
{
    logger_debug "module_removeFileConfiguration ($1)"
    local FILE=$(config_getFilenameModule $1)
    if [[ -f ${FILE} ]]; then
        logger_info "Suppression du fichier de configuration"
        rm -f ${FILE} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        return $?
    fi
    return 0
}


###
# Supprime le dossier du module
# @param $1 : Nom du module
##
function module_removeDirModule()
{
    logger_debug "module_removeDirModule ($1)"
    logger_info "Suppression du dossier du module"
    rm -rf modules/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}
