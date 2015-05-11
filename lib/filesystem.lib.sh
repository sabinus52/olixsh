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
# Copie un fichier de configuration dans son emplacement
# @param $1 : Fichier de configuration à lier
# @param $2 : Lien de destination
##
function filesystem_copyFileConfiguration()
{
    logger_debug "filesystem_copyFileConfiguration ($1, $2)"
    [[ ! -f $1 ]] && logger_error "Le fichier '$1' n'existe pas"
    logger_debug "cp $1 $2"
    cp $1 $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    return 0
}


###
# Crée un lien avec mon fichier de configuration
# @param $1 : Fichier de configuration à lier
# @param $2 : Lien de destination
##
function filesystem_linkNodeConfiguration()
{
    logger_debug "filesystem_linkNodeConfiguration ($1, $2)"
    [[ ! -f $1 ]] && logger_error "Le fichier '$1' n'existe pas"
    logger_debug "ln -sf $(readlink -f $1) $2"
    ln -sf $(readlink -f $1) $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    return 0
}
