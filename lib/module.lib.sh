###
# Librairie de la gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne l'URL de téléchargement du module
# @param $1 : Nom du module
##
function module_getUrl()
{
    logger_debug "module_getUrl ($1)"
    local URL
    IFS='|' read -ra URL <<< $(grep "^$1|" ${OLIX_MODULE_REPOSITORY})
    echo ${URL[1]}
}


###
# Télécharge le module
# @param $1 : Nom du module
##
function module_download()
{
    logger_debug "module_download ($1)"

    local URL=$(module_getUrl $1)

    local OPTS="--tries=3 --timeout=30 --no-check-certificate"
    [[ ${OLIX_OPTION_VERBOSEDEBUG} == true ]] && OPTS="${OPTS} --debug"
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && OPTS="${OPTS} --verbose"
    OPTS="${OPTS} --output-document=/tmp/olix.module.tar.gz"
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

    filesystem_extractTAR "/tmp/olix.module.tar.gz" "${OLIX_ROOT}/${OLIX_MODULE_DIR}" "--gzip"
    [[ $? -ne 0 ]] && return 1

    logger_info "Renommage de 'olixshmodule-$1' vers '$1'"
    mv ${OLIX_ROOT}/${OLIX_MODULE_DIR}/olixshmodule-$1 ${OLIX_ROOT}/${OLIX_MODULE_DIR}/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}