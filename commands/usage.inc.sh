###
# Usage des commandes OLIXSH
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage de la commande INSTALL
##
command_usage_install()
{
    debug "command_usage_install ()"
    Print.version
    echo
    echo -e "Installation des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}install ${CJAUNE}module${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    echo -e "${Cjaune} olixsh ${CVOID}      : Installation de oliXsh sur le système"
    local I
    while read I; do
        Print.usage.item $I "$(Module.label $I)"
    done < <(Module.all.available)
}


###
# Usage de la commande UPDATE
##
command_usage_update()
{
    debug "command_usage_update ()"
    Print.version
    echo
    echo -e "Mise à jour des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}update ${CJAUNE}[module] [--all]${CVOID}"
    echo
    echo -e "${CBLANC} --all${CVOID} : Tout mettre à jour"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    echo -e "${Cjaune} olixsh ${CVOID}      : Mise à jour de oliXsh"
    local I
    while read I; do
        Print.usage.item $I "$(Module.label $I)"
    done < <(Module.all.installed)
}


###
# Usage de la commande REMOVE
##
command_usage_remove()
{
    debug "command_usage_remove ()"
    Print.version
    echo
    echo -e "Suppression des modules oliXsh"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}remove ${CJAUNE}module${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
    local I
    while read I; do
        Print.usage.item $I "$(Module.label $I)"
    done < <(Module.all.installed)
}


###
# Usage de la commande SETCFG
# @param $1 : Nom du module
##
command_usage_setcfg()
{
    debug "command_usage_setcfg ($1)"
    local I
    Print.version
    echo
    echo -e "Modification d'une valeur d'un paramètre dans le fichier de configuration d'un module"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}setcfg ${CJAUNE}module parameter [value]${CVOID}"
    echo
    if [[ -z $1 ]]; then
        echo -e "${CJAUNE}Liste des MODULES disponibles${CVOID} :"
        echo -e "${Cjaune} olixsh ${CVOID}      : Configuration principale"
        while read I; do
            Print.usage.item $I "$(Module.label $I)"
        done < <(Module.all.installed)
    else
        echo -e "${CJAUNE}Liste des PARAMETER disponibles${CVOID} :"
        while read I; do
            Print.usage.item $I "$(Config.param.label $1 $I)" 15
        done < <(Config.parameters $1)
    fi
}
