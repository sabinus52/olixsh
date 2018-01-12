###
# Gestion des fichiers de configuration
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nom du module
##



###
# Retourne le nom du fichier de configuration du module ou principal
##
function Config.fileName()
{
    echo -n "$OLIX_CORE_PATH_CONFIG/$1.conf"
}


###
# Retourne le nom du template original de configuration du module ou principal
##
function Config.template()
{
    if [[ "$1" == "olixsh" ]]; then
        echo -n "$OLIX_ROOT/conf/$1.conf"
    else
        echo -n "$OLIX_MODULE_PATH/$1/conf/$1.conf"
    fi
}


###
# Vérifie si le fichier de configuration existe
##
function Config.exists()
{
    [[ -r $(Config.fileName $1) ]] && return 0 || return 1
}


###
# Vérifie si la configuration du module a été effectuée et la charge en mode silencieux
##
function Config.load()
{
    debug "config_load ($1)"
    local FILECONF=$(Config.fileName $1)
    info "Charge le fichier de configuration ${FILECONF}"
    [[ -r $FILECONF ]] && source $FILECONF && return 0
    warning "Fichier de configuration ${FILECONF} introuvable -> Chargement de celui par défaut"
    source $(Config.template $1)
    return $?
}


###
# Retourne la liste des noms de paramètres simplifiés d'un fichier de configuration
##
function Config.parameters()
{
    local FILECONF=$(Config.fileName $1)
    [[ ! -r $FILECONF ]] && return

    grep "^# @name" $FILECONF | sed "s/^# @name //"
}


###
# Affecte une valeur dans un paramètre du fichier de conf du module
# @param $2 : Nom du paramètre
# @param $3 : Valeur du paramètre
##
function Config.param.set()
{
    debug "Config.param.set ($1, $2, $3)"

    local FILECONF=$(Config.fileName $1)
    [[ ! -r $FILECONF ]] && return 101
    [[ ! -w $FILECONF ]] && return 102

    local PARAM=$(Config.param.system $1 $2)
    grep "^$PARAM\s*=" $FILECONF > /dev/null || return 103

    # Gestion des slash "/"
    local REPLACE=$(echo $3 | sed 's/\//\\\//g')

    sed -i "s/^\($PARAM\s*=\s*\).*\$/\1\"$REPLACE\"/" $FILECONF 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Récupère la valeur du paramètre de configuration dans le fichier de conf
# @param $2 : Nom du paramètre
##
function Config.param.get()
{
    debug "Config.param.get ($1, $2)"

    local FILECONF=$(Config.fileName $1)
    [[ ! -r $FILECONF ]] && return 101
    [[ ! -w $FILECONF ]] && return 102

    local REALNAME=$(Config.param.system $1 $2)
    #set -x
    eval String.explode.value $(grep "^$REALNAME=" $FILECONF)
    #set +x
    return 0
}


###
# Retourne une méta donnée associés au paramètre d'un fichier de configuration
# @param $2 : Nom du paramètre
# @param $3 : Nom de la métadonnée
##
function Config.param.metadata()
{
    local FILECONF=$(Config.template $1)
    [[ ! -r $FILECONF ]] && return 1

    grep "^# @$3 $2=" $FILECONF | sed "s/^# @$3 $2=//"
    return $PIPESTATUS
}


###
# Retourne le paramètre système associés au paramètre d'un fichier de configuration
##
function Config.param.system()
{
    Config.param.metadata $1 $2 "param"
    return $?
}

###
# Retourne le label associés au paramètre d'un fichier de configuration
##
function Config.param.label()
{
    Config.param.metadata $1 $2 "label"
    return $?
}

###
# Retourne le type de valeur associés au paramètre d'un fichier de configuration
##
function Config.param.type()
{
    Config.param.metadata $1 $2 "type"
    return $?
}

###
# Retourne les valeurs possibles associés au paramètre d'un fichier de configuration
##
function Config.param.values()
{
    Config.param.metadata $1 $2 "values"
    return $?
}

###
# Retourne la valeur par defaut associés au paramètre d'un fichier de configuration
##
function Config.param.default()
{
    local FILECONF=$(Config.template $1)
    [[ ! -r $FILECONF ]] && return 1

    local REALNAME=$(Config.param.system $1 $2)

    eval String.explode.value $(grep "^$REALNAME=" $FILECONF)
    #grep "^$2=" ${FILECONF} | sed "s/^$REALNAME=//"
    #return ${PIPESTATUS}
}


###
# Récupère dynamiquement la valeur d'un paramètre
# @param $2 : Nom du paramètre
##
function Config.dynamic.get()
{
    local REALNAME=$(Config.param.system $1 $2)
    eval echo -n \$$(String.upcase "$REALNAME")
}


###
# Affecte une valeur dans un paramètre dynamiquement
# @param $2 : Nom du paramètre
# @param $3 : Valeur du paramètre
##
function Config.dynamic.set()
{
    local REALNAME=$(Config.param.system $1 $2)
    eval "$(String.upcase "$REALNAME")=\"$3\""
}
