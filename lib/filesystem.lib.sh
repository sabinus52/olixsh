###
# Librairies de la gestion de système de fichiers
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


function filesystem_getExtension()
{
    logger_debug "filesystem_getExtension ($1)"
    local FILE
    FILE=$(basename $1)
    echo ${FILE#*.}
}


###
# Retourne le propriétaire d'un fichier ou répertoire
##
function filesystem_getOwner()
{
    logger_debug "system_getOwnerOfFile ($1)"
    echo $(stat -c %U $1)
}


###
# Vérifie si un fichier peut être créé
# @param $1 : Nom du fichier
# @return bool
##
function filesystem_isCreateFile()
{
    logger_debug "filesystem_isCreateFile ($1)"
    [[ -w $(dirname $1) ]] && return 0
    return 1
}


###
# Affiche la taille d'un fichier en mode compréhensible
# @param $1 : Nom du fichier
##
function filesystem_getSizeFileHuman()
{
    logger_debug "filesystem_getSizeFileHuman ($1)"
    [[ ! -f $1 ]] && echo -n "ERROR" && return
    echo -n $(du -h $1 | awk '{print $1}')
}


###
# Extrait une archive dans un emplacement désiré
# @param $1 : Nom du fichier
# @param $2 : Emplacement
# @param $3 : Paramètre supplémentaire
# @return   : Nom du fichier compressé
##
function filesystem_extractTAR()
{
    logger_debug "filesystem_unpackTAR ($1, $2, $3)"
    local OPTS=""

    [[ ${OLIX_OPTION_VERBOSE} == true ]] && OPTS="${OPTS} --verbose"
    [[ -n $3 ]] && OPTS="${OPTS} $3"
    logger_info "Extraction de $1 vers $2"
    logger_debug "tar --extract ${OPTS} --file=$1 --directory=$2"

    tar --extract ${OPTS} --file=$1 --directory=$2 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}