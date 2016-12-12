###
# Gestion des propriétés des fichiers
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nom du fichier
##



###
# Si le fichier existe
##
function File.exists()
{
    [[ -z $1 ]] && return 1
    [[ -f $1 ]] && return 0 || return 1
}


###
# Vérifie si un fichier peut être créé
##
function File.created()
{
    [[ -w $(dirname $1) ]] && return 0 || return 1
}


###
# Nom, dossier et extension du fichier
##
function File.basename()
{
    basename "$1"
}
alias File.name='File.basename'

function File.dirname()
{
    dirname "$1"
}

function File.extension()
{
    echo "${1##*.}"
}
alias File.ext='File.extension'


###
# Propriétaire et gourpe d'appartenance du fichier
##
function File.owner()
{
    File.exists $1 && echo $(stat -c %U $1)
}
alias File.user='File.owner'

function File.group()
{
    File.exists $1 && echo $(stat -c %G $1)
}


###
# Taille du fichier en bytes, K et M
##
function File.size.bytes()
{
    File.exists $1 && echo $(stat -c %s $1)
}
alias File.size='File.size.bytes'

function File.size.Kbytes()
{
    File.exists $1 && echo $(($(File.size.bytes "$1")/1024))
}

function File.size.Mbytes()
{
    File.exists $1 && echo $(($(File.size.Kbytes "$1")/1024))
}

function File.size.human()
{
    File.exists $1 && echo $(du -h "$1" | cut -f1)
}


###
# Date de modification
##
function File.modified.date()
{
    File.exists $1 && echo $(stat -c %y $1)
}


###
# Copie un fichier dans son emplacement
# @param $2 : Fichier ou emplacement de destination
##
function File.copy()
{
    debug "File.copy ($1, $2)"
    [[ ! -f $1 ]] && return 1
    cp $1 $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}


###
# Crée un lien avec un fichier
# @param $2 : Lien de destination
##
function File.link()
{
    debug "File.link ($(readlink -f $1), $2)"
    [[ ! -f $1 ]] && return 1
    ln -sf $(readlink -f $1) $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}


###
# Retourne la valeur d'un paramètre dans un fichier
# @param $2 : Nom du paramètre
# @param $3 : Délémiteur
##
function File.content.value()
{
    [[ ! -r $1 ]] && return 1
    local DELIMITER="="
    [[ -n $3 ]] && DELIMITER=$3
    grep "^$2" $1 | cut --delimiter="$DELIMITER" --fields=2 | tr -d '"'
}


###
# Crée le fichier d'exclusion pour la synchronisation
# @param $1 : Liste des exclusions
# @TODO à tester et vérifier Filesystem.synchronize + Compression.tar.create
##
function File.exclude.create()
{
    debug "File.exclude.create ($1)"
    local FILEX=$(System.file.temp)

    echo "ee" > $FILEX
    IFS='|'
    for I in $1; do
      echo $I >> $FILEX
    done
    unset IFS
    sed -i "s/\\\//g" $FILEX
    echo -n $FILEX
}
