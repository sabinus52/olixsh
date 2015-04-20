###
# Gestion de la configuration des différents fichier
# ==============================================================================
# @package olixsh
# @author Olivier
##


OLIX_CONFIG_DIR="conf"


###
# Retourne le nomm du fichier de configuration du module
# @param $1 : Nom du module
##
function config_getFilenameModule()
{
    echo -n "${OLIX_CONFIG_DIR}/$1.conf"
}


###
# Vérifie qu'un fichier de configuration existe pour un module
# @param $1 : Nom du module
##
function config_isModuleExist()
{
    logger_debug "config_isModuleExist ($1)"
    [[ -r $(config_getFilenameModule $1) ]] && return 0
    return 1
}