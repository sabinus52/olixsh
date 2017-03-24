###
# Gestion des tableaux en mode objet
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nom de la variable du tableau
##


OLIX_LIB_ARRAY_METHODS=(all count delete find get index push)



###
# Crée une nouvelle instance d'un tableau
##
function Array.new()
{
    for METHOD in ${OLIX_LIB_ARRAY_METHODS[@]}; do
        eval "alias $1.$METHOD='Array.$METHOD $1 '"
    done
}


###
# Retourne tous les éléments
##
function Array.all()
{
    eval echo \${$1[@]}
}


###
# Retourne le nombre d'élément du tableau
##
function Array.count()
{
    eval echo \${#${1}[@]}
}


###
# Retourne la liste des index du tableau => 0 1 3 4 6
##
function Array.index()
{
    eval echo \${!${1}[@]}
}


###
# Retourne un élément par son index
##
function Array.get()
{
    eval echo \${${1}[\${2}]}
}


###
# Empile un nouvel élément
##
function Array.push()
{
    eval local INDEX=\${#${1}[*]}
    eval ${1}[$INDEX]='${2}'
    return $INDEX
}


###
# Supprime un élémenet
##
function Array.delete()
{
    unset ${1}[\${2}]
}

###
# Retourne l'index du premier élément trouvé
##
function Array.find()
{
    for I in $(Array.index $1); do
        [[ "$(Array.get $1 $I)" == "$2" ]] && echo $I && return 0
    done
    return 1
}
