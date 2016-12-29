###
# Gestion des nombres
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nombre
##



###
# Retourne si c'est un entier
##
function Digit.integer()
{
    [ "$1" -eq "$1" ] 2>/dev/null && return 0
    return 1
}


###
# Compare des nombres
# @param $1 : Chaine de comparaison
##
function Digit.compare()
{
    (( $(echo "$1" | bc -l) ))
    return $?
}
