###
# Librairies de gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Affiche la liste des modules disponibles
##
function module_printListAvailable()
{
    logger_debug "module_printListAvailable ()"
    local MODULE I
    while read I; do
        echo -en "${Cjaune} ${I} ${CVOID} "
        stdout_strpad "${I}" 10 " "
        echo -n " : "; module_getLabel "$I"
    done < <(module_getListAvailable)
}


###
# Affiche la liste des modules installés
##
function module_printListInstalled()
{
    logger_debug "module_printListInstalled ()"
    local MODULE I
    while read I; do
        echo -en "${Cjaune} ${I} ${CVOID} "
        stdout_strpad "${I}" 10 " "
        echo -n " : "; module_getLabel "$I"
    done < <(module_getListInstalled)
}


###
# Retourne le nom du script a executer
# @param $1 : Nom du module
##
function module_getScript()
{
    echo -n "${OLIX_ROOT}/${OLIX_MODULE_DIR}/$1/olixmod.sh"
}


###
# Test si le module existe
# @param $1 : Nom du module
##
function module_isExist()
{
    logger_debug "module_isExist ($1)"
    local RESULT
    RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY_USER})
    [[ $? -eq 0 ]] && return 0
    RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY})
    [[ $? -eq 0 ]] && return 0
    return 1
}


###
# Test si le module est déjà installé
# @param $1 : Nom du module
##
function module_isInstalled()
{
    logger_debug "module_isInstalled ($1)"
    [[ -r $(module_getScript "$1") ]] && return 0
    return 1
}


###
# Retourne la liste des modules disponibles
##
function module_getListAvailable()
{
    logger_debug "module_getListAvailable ()"
    local FILES="${OLIX_MODULE_REPOSITORY}"
    [[ -r ${OLIX_MODULE_REPOSITORY_USER} ]] && FILES="${FILES} ${OLIX_MODULE_REPOSITORY_USER}"
    cat ${FILES} | grep -v "^#" | cut -d '|' -f1 | sort | uniq
}


###
# Retourne le liste des modules déjà installés
##
function module_getListInstalled()
{
    logger_debug "module_getListEnabled ()"
    find ${OLIX_MODULE_DIR}  -maxdepth 1 -mindepth 1 -type d | cut -f2 -d'/' | sort
}


###
# Recupère le label du module
# @param $1 : Nom du module
##
function module_getLabel()
{
    logger_debug "module_getLabel ($1)"
    local RESULT MODULE URL LABEL
    RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY_USER})
    [[ $? -ne 0 ]] && RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY})
    IFS='|' read MODULE URL LABEL <<< ${RESULT}
    echo ${LABEL}
}


###
# Recupère l'url de téléchargement du module
# @param $1 : Nom du module
##
function module_getUrl()
{
    logger_debug "module_getLabel ($1)"
    local RESULT MODULE URL LABEL PROTOCOL URI
    RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY_USER})
    [[ $? -ne 0 ]] && RESULT=$(grep "^$1|" ${OLIX_MODULE_REPOSITORY})
    IFS='|' read MODULE URL LABEL <<< ${RESULT}
    IFS=':' read PROTOCOL URI <<< ${URL}
    if [[ ${PROTOCOL} == "github" ]]; then
        logger_debug "GITHUB=https:${URI}"
        URL=$(curl -s https:${URI} | grep 'tarball_url' | cut -d\" -f4)
    fi
    echo ${URL}
}


###
# Execute le module
# @param $@ : 
# @param $1 : Nom du module
##
function module_execute()
{
    local SCRIPT=$(module_getScript "$1")
    logger_debug "module_execute ($1) -> ${SCRIPT} avec ARGS : $@"
    logger_info "Execution du module $1"

    if module_isInstalled "$1"; then
        source ${SCRIPT}
        shift
        OLIX_MODULE_FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})

        if [[ ${OLIX_OPTION_LIST} == true ]]; then
            # Pour afficher des listes simple utile pour la complétion
            olixmod_list $@
        elif [[ "$1" == "init" ]]; then
            module_initialize $@
        else
            olixmod_main $@
        fi
        core_exit 0
    fi
    logger_warning "Le module $1 est inexistant"
    core_exit 1
}


###
# Initialisation du module avec création de son fichier de configuration
# @param $@
##
function module_initialize()
{
    logger_debug "module_initialize ($@)"
    source lib/stdin.lib.sh
    OLIX_MODULE_FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})

    local FORCE=false
    while [[ $# -ge 1 ]]; do
        case $1 in
            --force|-f) FORCE=true;;
        esac
        shift
    done

    # Test si la configuration existe
    logger_info "Test si la configuration est déjà effectuée"
    if config_isModuleExist ${OLIX_MODULE_NAME} && [[ ${FORCE} == false ]] ; then
        logger_warning "Le fichier de configuration existe déjà"
        if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
            echo "----------"
            cat ${OLIX_MODULE_FILECONF}
            echo "----------"
        fi
        echo "Pour reinitialiser la configuration du module, utiliser : ${OLIX_CORE_SHELL_NAME} ${OLIX_MODULE_NAME} init -f|--force"
        core_exit 0
    fi

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_critical "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    if config_isModuleExist ${OLIX_MODULE_NAME}; then
        logger_info "Chargement du fichier de configuration ${OLIX_MODULE_FILECONF}"
        source ${OLIX_MODULE_FILECONF}
    fi

    olixmod_init $@
}
