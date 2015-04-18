###
# Librairies de gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Emplacement du fichier contenant la liste des modules existants
OLIX_MODULE_REPOSITORY="conf/modules.lst"

# Emplacement des modules installés
OLIX_MODULE_DIR="modules"



###
# Affiche la liste des modules disponibles
##
function module_printList()
{
    logger_debug "module_printList ()"
    local MODULE
    while read I; do
        IFS='|' read -ra MODULE <<< "$I"
        echo -en "${Cjaune} ${MODULE[0]} ${CVOID} "
        stdout_strpad "${MODULE[0]}" 10 " "
        echo -e " : ${MODULE[2]}"
    done < <(grep -v "^#" ${OLIX_MODULE_REPOSITORY})
}


###
# Retourne la liste des modules disponibles
##
function module_getListAvailable()
{
    logger_debug "module_getListAvailable ()"
    local MODULE
    while read I; do
        IFS='|' read -ra MODULE <<< "$I"
        echo -n "${MODULE[0]} "
    done < <(grep -v "^#" ${OLIX_MODULE_REPOSITORY})
}


###
# Retourne le liste des modules activés ou déjà installés
##
function module_getListEnabled()
{
    logger_debug "module_getListEnabled ()"
    echo $(ls -d ${OLIX_MODULE_DIR}/*/ | cut -f2 -d'/')
}


###
# Test si le module existe
# @param $1 : Nom du module
##
function module_isExist()
{
    logger_debug "module_isExist ($1)"
    grep "^$1|" ${OLIX_MODULE_REPOSITORY} >/dev/null 2>&1 && return 0
    return 1
}


###
# Test si le module est déjà installé
# @param $1 : Nom du module
##
function module_isInstalled()
{
    logger_debug "module_isInstalled ($1)"
    [[ -d ${OLIX_MODULE_DIR}/$1 ]] && return 0
    return 1
}


