###
# Librairies de gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Emplacement du fichier contenant la liste des modules existants
OLIX_MODULE_REPOSITORY="conf/modules.lst"

# Emplacement des modules installés
OLIX_MODULE_DIR="modules"

# Fichier de conf utilisé par le module
OLIX_MODULE_FILECONF=""


###
# Affiche la liste des modules disponibles
##
function module_printListAvailable()
{
    logger_debug "module_printListAvailable ()"
    local MODULE
    while read I; do
        IFS='|' read -ra MODULE <<< "$I"
        echo -en "${Cjaune} ${MODULE[0]} ${CVOID} "
        stdout_strpad "${MODULE[0]}" 10 " "
        echo -e " : ${MODULE[2]}"
    done < <(grep -v "^#" ${OLIX_MODULE_REPOSITORY})
}


###
# Affiche la liste des modules installés
##
function module_printListInstalled()
{
    logger_debug "module_printListInstalled ()"
    local MODULE
    for I in $(ls -d ${OLIX_MODULE_DIR}/*/ | cut -f2 -d'/'); do
        IFS='|' read -ra MODULE <<< $(grep "^$I|" ${OLIX_MODULE_REPOSITORY})
        echo -en "${Cjaune} ${MODULE[0]} ${CVOID} "
        stdout_strpad "${MODULE[0]}" 10 " "
        echo -e " : ${MODULE[2]}"
    done
}


###
# Retourne la liste des modules disponibles
##
function module_getListAvailable()
{
    logger_debug "module_getListAvailable ()"
    local MODULE
    while read I; do
        IFS='|' read -ra MODULE <<< "$I"
        echo -n "${MODULE[0]} "
    done < <(grep -v "^#" ${OLIX_MODULE_REPOSITORY})
}


###
# Retourne le liste des modules déjà installés
##
function module_getListInstalled()
{
    logger_debug "module_getListEnabled ()"
    echo $(ls -d ${OLIX_MODULE_DIR}/*/ | cut -f2 -d'/')
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
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    if config_isModuleExist ${OLIX_MODULE_NAME}; then
        logger_info "Chargement du fichier de configuration ${OLIX_MODULE_FILECONF}"
        source ${OLIX_MODULE_FILECONF}
    fi

    olixmod_init $@
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
    grep "^$1|" ${OLIX_MODULE_REPOSITORY} >/dev/null 2>&1 && return 0
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
