###
# Librairie de la gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



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
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && OPTS="${OPTS} --verbose"
    OPTS="${OPTS} --output-document=/tmp/olixmodule.tar.gz"
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

    file_extractArchive "/tmp/olixmodule.tar.gz" "${OLIX_ROOT}/${OLIX_MODULE_DIR}" "--gzip"
    [[ $? -ne 0 ]] && return 1

    logger_info "Renommage de 'olixshmodule-$1' vers '$1'"
    mv ${OLIX_ROOT}/${OLIX_MODULE_DIR}/olixshmodule-$1* ${OLIX_ROOT}/${OLIX_MODULE_DIR}/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
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
    ln -s modules/$1/completion completion/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}


###
# Supprime le fichier de completion
# @param $1 : Nom du module
##
function module_removeCompletion()
{
    logger_debug "module_removeCompletion ($1)"
    if [[ -L completion/$1 ]] || [[ -f completion/$1 ]]; then
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
