###
# Librairies contenant les fonctions de base necessaire au shell
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Pointeur de temps de départ du script
OLIX_CORE_EXEC_START=${SECONDS}


###
# Sortie du programme shell avec nettoyage
# @param $1 : Code de sortie
# @param $2 : Raison du pourquoi de la sortie
##
function core_exit()
{
    local CODE="$1"
    local REASON="$2"

    logger_debug "core_exit ($1)"

    logger_debug "Effacement des fichiers temporaires"
    rm -f /tmp/olix.* > /dev/null 2>&1

    if [[ -n "${REASON}" ]]; then 
        logger_info "EXIT : ${REASON}"
    fi
    exit ${CODE}
}


###
# Vérifie que ce soit root qui puisse exécuter le script
##
function core_checkIfRoot()
{
    logger_debug "core_checkIfRoot ()"
    [[ $(id -u) != 0 ]] && return 1
    return 0
}


###
# Vérifie que ce soit le propriétaire qui puisse exécuter le script
##
function core_checkIfOwner()
{
    logger_debug "core_checkIfOwner ()"
    local OWNER=$(core_getOwner)
    [[ ${LOGNAME} != ${OWNER} ]] && return 1
    return 0
}


###
# Retourne le propriétaire où est installé oliXsh
##
function core_getOwner()
{
    logger_debug "system_getOwner (${OLIX_CORE_PATH_CONFIG})"
    echo $(stat -c %U ${OLIX_CORE_PATH_CONFIG})
}


###
# Vérifie si l'installation de oliXsh est complète
# @param $1 $2 : Commandes
##
function core_checkInstall()
{
    logger_debug "core_checkInstall ($1, $2)"

    [[ "$1" == "install" && "$2" == "olix" ]] && return 0

    logger_info "Vérification de la présence de lien ${OLIX_CORE_SHELL_LINK}"
    if [[ ! -x ${OLIX_CORE_SHELL_LINK} ]]; then
        logger_warning "${OLIX_CORE_SHELL_LINK} absent"
        logger_warning "oliXsh n'a pas été installé correctement. Relancer le script './olixsh install olix'"
        echo && return 1
    fi
}


###
# Créer un fichier temporaire
##
function core_makeTemp()
{
    echo -n $(mktemp /tmp/olix.XXXXXXXXXX.tmp)
}


###
# Retourne le temps d'execution
##
function core_getTimeExec()
{
    echo -n $((SECONDS-OLIX_CORE_EXEC_START))
}


###
# Si un item est contenu dans une liste
# @param $1 : Item à chercher
# @param $2 : Liste
##
function core_contains()
{
    local LIST="$2"
    local ITEM="$1"
    [[ ${LIST} =~ (^|[[:space:]])"${ITEM}"($|[[:space:]]) ]] && return 0
    return 1
}


###
# Envoi d'un mail
# @param $1 : Format html ou text
# @param $2 : Email
# @param $3 : Chemin du fichier contenant le contenu du mail
# @param $4 : Sujet du mail
##
function core_sendMail()
{
    logger_debug "core_sendMail ($1, $2, $3, $4)"

    local SUBJECT SERVER
    #SERVER="${OLIX_CONF_SERVER_NAME}"
    #[[ -z ${SERVER} ]] && SERVER=${HOSTNAME}
    SERVER=${HOSTNAME}
    SUBJECT="[${SERVER}:${OLIX_MODULE}] $4"

    if [[ "$1" == "html" || "$1" == "HTML" ]]; then
        mailx -s "${SUBJECT}" -a "Content-type: text/html; charset=UTF-8" $2 < $3
    else
        mailx -s "${SUBJECT}" $2 < $3
    fi
    return $?
}
