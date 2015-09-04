###
# Gestion de la configuration des différents fichier
# ==============================================================================
# @package olixsh
# @author Olivier
##



###
# Vérifie que la valeur de la configuration n'est pas vide
# @param $1 : Clé de la configuration (variable)
# @param $2 : Valeur par défaut
##
function config_require()
{
    logger_debug "config_require ($1, $2)"
    
    local VALUE
    eval "VALUE=\"\$$1\""

    if [[ -z ${VALUE} ]]; then
        [[ -z $2 ]] && return
        config_warning "$1" "$2"
        eval "$1=\"\$2\""
    fi
}

###
# Indique un avertissement pour la configuration
# @param $1 : Clé de la configuration (variable)
# @param $2 : Valeur par défaut
##
function config_warning()
{
    logger_debug "conf_warning ($1, $2)"
    logger_warning "La configuration $1 n'est pas renseignée, utilisation de la valeur \"$2\"."  
}


###
# Retourne le nom du fichier de configuration du module
# @param $1 : Nom du module
##
function config_getFilenameModule()
{
    echo -n "${OLIX_CORE_PATH_CONFIG}/$1.conf"
}


###
# Vérifie qu'un fichier de configuration existe pour un module
# @param $1 : Nom du module
##
function config_isModuleExist()
{
    logger_debug "config_isModuleExist ($1)"
    [[ -r $(config_getFilenameModule $1) ]] && return 0
    return 1
}


###
# Vérifie si la configuration du module a été effectuée et la charge
# @param $1 : Nom du module
## 
function config_loadConfigModule()
{
    logger_debug "config_loadConfigModule ($1)"

    logger_info "Test si la configuration est déjà effectuée"
    if ! config_isModuleExist $1; then
        logger_critical "Pour reinitialiser la configuration du module '$1', utiliser : ${OLIX_CORE_SHELL_NAME} $1 init"
    fi

    local FILECONF=$(config_getFilenameModule $1)
    logger_info "Charge le fichier de configuration ${FILECONF}"
    source ${FILECONF}
}


###
# Vérifie si la configuration du module a été effectuée et la charge en mode silencieux
# @param $1 : Nom du module
## 
function config_loadConfigQuietModule()
{
    logger_debug "config_loadConfigQuietModule ($1)"

    logger_info "Test si la configuration est déjà effectuée"
    if ! config_isModuleExist $1; then
        return 1
    fi

    local FILECONF=$(config_getFilenameModule $1)
    logger_info "Charge le fichier de configuration ${FILECONF}"
    source ${FILECONF}
    return $?
}


###
# Affecte une valeur dans un paramètre du fichier de conf du module
# @param $1 : Nom du module
# @param $2 : Nom du paramètre
# @param $3 : Valeur du paramètre
##
function config_setConfig()
{
    logger_debug "config_setConfig ($1, $2, $3)"

    local FILECONF=$(config_getFilenameModule $1)
    logger_debug "FILECONF=${FILECONF}"

    if [[ ! -r ${FILECONF} ]]; then
        echo "# Fichier de configuration du module APPWEB" > ${FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
        [[ $? -ne 0 ]] && logger_critical
    fi

    if grep "^$2\s*=" ${FILECONF} > /dev/null; then
        sed -i "s/^\($2\s*=\s*\).*\$/\1$3/" ${FILECONF}
    else
        echo "$2=$3" >> ${FILECONF}
    fi
}
