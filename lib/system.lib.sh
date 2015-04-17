###
# Librairies de la gestion du système
# ==============================================================================
# @package olixsh
# @author Olivier
##


###
# Vérifie si le binaire est installé
# @param $1 : Nom du binaire
##
function system_whichBinary ()
{
    logger_debug "core_whichBinary ($1)"
    which $1 > /dev/null 2>&1
    [[ $? -ne 0 ]] && logger_warning "Le binaire \"$1\" n'est pas présent" && return 1
    return 0
}


###
# Vérifie si une liste de binaire est installée
# @param $1 : Liste
##
function system_whichBinaries ()
{
    logger_debug "system_whichBinaries ($1)"
    local RET=0
    for I in $1; do
        system_whichBinary $I
        [[ $? -ne 0 ]] && RET=1
    done
    return ${RET}
}


