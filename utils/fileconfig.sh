###
# Fonctions pour le traitement d'installation 
# et de mise à jour des fichiers de configuration
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Installe le template du fichier de configuration dans /etc/olixsh
# @param $1 : Nom du module
##
function Fileconfig.install()
{
    debug "Fileconfig.install ($1)"

    local SOURCE=$(Config.template $1)
    local DESTINATION=$(Config.fileName $1)

    debug "cp $SOURCE $DESTINATION"
    cp $SOURCE $DESTINATION 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Affecte une valeur à un paramètre du fichier de configuration
# @param $1 : Nom du module
# @param $2 : Nom du paramètre
# @param $2 : Valeur du paramètre
##
function Fileconfig.param.set()
{
    debug "Fileconfig.param.set ($1, $2, $3)"
    local VALUE=$3

    if [[ -z $VALUE ]]; then
        # Si valeur non saisie en paramètre, on la demande
        Fileconfig.param.read $1 $2
        VALUE=$OLIX_FUNCTION_RETURN
    else
        # Sinon on vérifie la valeur
        Fileconfig.param.check $1 $2 $VALUE
        [[ $? -ne 0 ]] && return 104
    fi

    OLIX_FUNCTION_RETURN=$VALUE
    Config.param.set "$1" "$2" "$VALUE"
    return $?
}



###################################################################################################


###
# Vérifie la valeur du paramètre saisi
# @param $1 : Nom du module
# @param $2 : Nom du paramètre
# @param $3 : Valeur du paramètre
##
function Fileconfig.param.check()
{
    debug "utils_fileconfig_checkParam ($1, $2, $3)"
    local TYPE=$(Config.param.type $1 $2)

    case $TYPE in

        select)
            local VALUES="$(Config.param.values $1 $2)"
            ! String.list.contains "$3" "$VALUES" && return 1
            ;;

        digit)
            ! String.digit $2 && return 1
            ;;

        file)
            [[ ! -f $2 && ! -r $2 ]] && return 1
            ;;

    esac
    return 0
}


###
# Demande la valeur du paramètre
# @param $1 : Nom du module
# @param $2 : Nom du paramètre
##
function Fileconfig.param.read()
{
    debug "Fileconfig.param.read ($1, $2)"

    # Valeur par défaut dans le fichier de conf
    local DEFAULT=$(Config.param.default $1 $2)
    local TYPE=$(Config.param.type $1 $2)
    
    case $TYPE in

        select)
            Read.choices "$(Config.param.label $1 $2)" "$DEFAULT" "$(Config.param.values $1 $2)"
            ;;
        password)
            Read.password "$(Config.param.label $1 $2)"
            ;;
        file)
            Read.file "$(Config.param.label $1 $2)" "$DEFAULT"
            ;;
        digit)
            Read.digit "$(Config.param.label $1 $2)" "$DEFAULT"
            ;;
        *)
            Read "$(Config.param.label $1 $2)" "$DEFAULT"
            ;;

    esac
}
