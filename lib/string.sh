###
# Gestion des chaines de caractères
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Chaine de caractères
##



###
# Retourne le padding d'un texte avec une taille fixe complétée par des caratères
# @param $2 : Taille de la chaine
# @param $3 : Caractère à compléter
##
function String.pad()
{
    local PAD=$(printf '%0.1s' "$3"{1..60})
    printf '%*.*s' 0 $(($2 - ${#1} )) "${PAD}"
}


###
# Met tout en minuscule
##
function String.lower()
{
    echo "$1" | tr '[:upper:]' '[:lower:]'
}


###
# Met tout en majuscule
##
function String.upcase()
{
    echo "$1" | tr '[:lower:]' '[:upper:]'
}


###
# Met une capitale sur le 1er caractère
##
function String.capitalize()
{
    echo "$1" | sed 's/\b\(.\)/\U\1/'
}


###
# Efface les espaces superflus
##
function String.trim()
{
    echo "$1" | sed 's/^ *//g' | sed 's/ *$//g'
}


###
# Longueur d'une chaine
##
function String.length()
{
    echo ${#1}
}


###
# Retourne une sous-chaine
##
function String.sub()
{
    echo ${1:$2:$3}
}


###
# Retourne si une chaine est contenu dans une autre
# @param $2 : Chaine à rechercher
##
function String.contains()
{
    [[ -z $1 ]] && return 1
    [[ -z $2 ]] && return 1
    echo "$1" | grep "$2" > /dev/null && return 0
    return 1
}


###
# Retourne si c'est un nombre
##
function String.digit()
{
    [ "$1" -eq "$1" ] 2>/dev/null && return 0
    return 1
}


###
# Extrait une chaine avec un délimiteur
# @param $2 : Indice du champs à extraire
# @param $3 : Délimiteur
##
function String.explode()
{
    debug "echo $1 | cut --delimiter='$3' --fields=$2"
    echo "$1" | cut --delimiter="$3" --fields=$2
}

###
# Extrait la valeur d'une chaine avec un délimiteur (param=value)
# @param $2 : Délimiteur
##
function String.explode.value()
{
    local DELIMITER="="
    [[ -n $2 ]] && DELIMITER=$2
    echo $(String.explode $1 2 "$DELIMITER")
    #IFS='=' read -ra PARAM <<< "$1"
    #echo ${PARAM[1]}
}

###
# Extrait le paramètre d'une chaine avec un délimiteur (param=value)
# @param $2 : Délimiteur
##
function String.explode.param()
{
    local DELIMITER="="
    [[ -n $2 ]] && DELIMITER=$2
    echo $(String.explode $1 1 "$DELIMITER")
}


###
# Retourne si un élément est contenu dans une liste
# @param $2 : Element à rechercher
##
function String.list.contains()
{
    [[ -z $1 ]] && return 1
    [[ -z $2 ]] && return 1
    echo " $1 " | grep " $2 " > /dev/null && return 0
    #[[ ${LIST} =~ (^|[[:space:]])"${ITEM}"($|[[:space:]]) ]] && return 0
    return 1
}



###
# Retourne l'utilisateur, le hostname ou le port depuis une chaine de connexion
# @param $1 : chaine de connexion au format user@host:port
##
function String.connection.user()
{
    echo -n $1 | grep '@' | sed "s/@.*$//"
}

function String.connection.host()
{
    echo -n $1 | sed "s/:.*$//" | sed "s/^.*@//"
}

function String.connection.port()
{
    echo -n $1 | grep ':' | sed "s/^.*://"
}
