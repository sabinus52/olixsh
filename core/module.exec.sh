###
# Librairies de gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# @TODO initialisation du module après son installation
##



###
# Execute le module
# @param $@ : 
# @param $1 : Nom du module
##
function Module.execute()
{
    OLIX_MODULE_NAME="$1"

    local SCRIPT=$(Module.script.main "$OLIX_MODULE_NAME")
    debug "Module.execute ($1) -> ${SCRIPT} avec ARGS : $@"
    info "Execution du module $OLIX_MODULE_NAME"

    debug "load $SCRIPT"
    source $SCRIPT
    source $(Config.template $OLIX_MODULE_NAME)
    shift

    if [[ $OLIX_OPTION_LIST == true ]]; then
        Module.execute.completion $@
    elif [[ $OLIX_OPTION_HELP == true || "$1" == "help" || "$1" == "" || "$2" == "help" ]]; then
        Module.execute.usage "$1"
    else
        Module.execute.action $@
    fi
    return 0
}


###
# Affiche l'aide du module et de son action
# @param $1 : Nom de l'action
##
function Module.execute.usage()
{
    debug "Module.execute.usage ($1)"

    # Chargement de la fichier contenant l'usage
    source $(Module.script.usage $OLIX_MODULE_NAME)

    local ACTION="main"
    [[ "$1" != "help" && "$1" != "" ]] && ACTION=$1
    if ! Function.exists "olixmodule_${OLIX_MODULE_NAME}_usage_${ACTION}"; then
        warning "Aucune aide trouvée à afficher"
    else
        Function.exists "olixmodule_${OLIX_MODULE_NAME}_require_libraries" && olixmodule_${OLIX_MODULE_NAME}_require_libraries
        Config.load $OLIX_MODULE_NAME
        Print.version
        olixmodule_${OLIX_MODULE_NAME}_usage_${ACTION}
    fi
}


###
# Pour afficher des listes simple utile pour la complétion
##
function Module.execute.completion()
{
    debug "Module.execute.completion ($@)"

    if Function.exists "olixmodule_${OLIX_MODULE_NAME}_list"; then
        Function.exists "olixmodule_${OLIX_MODULE_NAME}_require_libraries" && olixmodule_${OLIX_MODULE_NAME}_require_libraries
        Config.load $OLIX_MODULE_NAME
        olixmodule_${OLIX_MODULE_NAME}_list $@
    fi
}


###
# Execute l'action du module
# @param $@ : Action et ses paramètres
##
function Module.execute.action()
{
    debug "Module.execute.action ($1, $@)"
    local ACTION=$1
    shift
    local ACTION_SCRIPT=$(Module.script.action $OLIX_MODULE_NAME $ACTION)

    if [[ ! -r $ACTION_SCRIPT ]]; then
        warning "Action inconnu : '${ACTION}' (${ACTION_SCRIPT})"
        Config.load $OLIX_MODULE_NAME
        Module.execute.usage $ACTION
        die 1
    fi

    info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    debug "MODULE_ACTION=${ACTION}"
    debug "MODULE_PARAMS=$@"
    debug "MODULE_ACTION_SCRIPT=${ACTION_SCRIPT}"

    # Chargement des librairies
    if Function.exists "olixmodule_${OLIX_MODULE_NAME}_require_libraries"; then
        info "Chargement des Librairies du module"
        olixmodule_${OLIX_MODULE_NAME}_require_libraries
    fi
    # Chargement du fichier de configuration
    Config.load $OLIX_MODULE_NAME
    # Chargement du début du script
    if Function.exists "olixmodule_${OLIX_MODULE_NAME}_include_begin"; then
        info "Début du script"
        olixmodule_${OLIX_MODULE_NAME}_include_begin "${ACTION}" $@
    fi
    # Chargement et traitement du script
    debug "### EXEC ${ACTION_SCRIPT} $@ ###"
    source $ACTION_SCRIPT
    # Chargement du fin du script
    if Function.exists "olixmodule_${OLIX_MODULE_NAME}_include_end"; then
        info "Fin du script"
        olixmodule_${OLIX_MODULE_NAME}_include_end "${ACTION}" $@
    fi
}
