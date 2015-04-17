###
# Librairies contenant les fonctions de base necessaire au shell
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Pointeur de temps de départ du script
OLIX_CORE_EXEC_START=${SECONDS}

# Nom du fichier de l'interpréteur
OLIX_CORE_SHELL_NAME="olixsh"
# Lien vers l'interpréteur olixsh
OLIX_CORE_SHELL_LINK="/usr/bin/otestsh"


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
