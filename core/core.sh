###
# Librairies contenant les fonctions de base necessaire au shell
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Chargement des librairies
# @param $1 : Un fichier ou filtre
##
function load()
{
    local LIB

    for LIB in $OLIX_ROOT/$1; do
        if [[ -f "$LIB" ]]; then
            debug "load ($LIB)"
            source $LIB
        else
            critical "Impossible de charger $LIB"
        fi
    done
}


###
# Sortie du programme shell avec nettoyage
# @param $1 : Code de sortie
# @param $2 : Raison du pourquoi de la sortie
##
function die()
{
    local CODE="$1"
    local REASON="$2"

    debug "die ($1)"

    rm -f /tmp/olix.* > /dev/null 2>&1

    if [[ -n "$REASON" ]]; then 
        info "EXIT : $REASON"
    fi
    exit $CODE
}


###
# Vérifie si l'installation de oliXsh est complète
# @param $1 $2 : Commandes
##
function checkOlixsh()
{
    debug "checkOlixsh ($1, $2)"

    [[ "$1" == "install" && "$2" == "olixsh" ]] && return 0

    info "Vérification de la présence de lien ${OLIX_CORE_SHELL_LINK}"
    if [[ ! -x ${OLIX_CORE_SHELL_LINK} ]]; then
        warning "${OLIX_CORE_SHELL_LINK} absent"
        warning "oliXsh n'a pas été installé correctement. Relancer le script './olixsh install olixsh'"
        echo && return 1
    fi

    info "Vérification de la présence de dossier de configuration ${OLIX_CORE_PATH_CONFIG}"
    if [[ ! -d ${OLIX_CORE_PATH_CONFIG} ]]; then
        warning "${OLIX_CORE_PATH_CONFIG} absent"
        critical "oliXsh n'a pas été installé correctement. Relancer le script './olixsh install olixsh'"
    fi
}


###
# Vérifie que ce soit le propriétaire qui puisse exécuter le script
##
function checkOlixshOwner()
{
    debug "checkOlixsh ()"
    local OWNER=$(Core.owner)
    [[ "$(System.logged.name)" != "$OWNER" ]] && return 1
    return 0
}


###
# Retourne le propriétaire où est installé oliXsh
##
function Core.owner()
{
    echo $(stat -c %U $OLIX_CORE_PATH_CONFIG)
}


###
# Si un alias existe
# @param $1 : Nom de l'alias
##
function Alias.exists()
{
    type -t $1 2> /dev/null | grep -q 'alias' && return 0
    return 1
}


###
# Si une fonction existe
# @param $1 : Nom de la fonction
##
function Function.exists()
{
    type -t $1 2> /dev/null | grep -q 'function' && return 0
    return 1
}
