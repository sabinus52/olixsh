###
# Librairies de la gestion des fichiers de conf au format YAML
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Prefix de la configuration pour les variables de sortie
OLIX_YAML_PREFIX=""



###
# Parse un fichier YAML
# @param $1 : Nom du fichier
# @param $2 : Prefix des variables de sortie
function Yaml.parse()
{
    debug "Yaml.parse ($1, $2)"
    eval $(utils_yaml_evalParseFile "$1" "$2")
    OLIX_YAML_PREFIX=$2
}


###
# Retourne un paramètre du fichier YML
# @param $1 : Clé du paramètre "param1.param2"
##
function Yaml.get()
{
    debug "Yaml.get ($1)"
    local PARAM=${1//./__}

    eval "local VALUE=\$${OLIX_YAML_PREFIX}${PARAM^^}"
    debug "YML : $1=${VALUE}"
    echo -n "$VALUE"
}


###
# Retourne un paramètre recommandé du fichier YML
# @param $1 : Clé du paramètre "param1.param2"
# @param $3 : Valeur par défaut
##
function utils_yaml_require()
{
    debug "utils_yaml_require ($1, $2)"
    
    local VALUE=$(utils_yaml_get "$1")
    if [[ -z $VALUE ]]; then
        [[ -z $2 ]] && return
        utils_yaml_warning "$1" "$2"
        echo -n "$2"
    else
        echo -n $VALUE
    fi
}



###################################################################################################


###
# Parse un fichier YAML
# @param $1 : Nom du fichier
# @param $2 : Prefix des variables de sortie
# @notuse : yaml_parseFile => eval $(yaml_evalParseFile config.yml "config_")
# @link : https://gist.github.com/pkuczynski/8665367
##
function utils_yaml_evalParseFile()
{
    local PREFIX=$2
    local S='[[:space:]]*' W='[a-zA-Z0-9_]*' FS=$(echo @|tr @ '\034')
    sed -ne "s|^\($S\)\($W\)$S:$S\"\(.*\)\"$S\$|\1$FS\2$FS\3|p" \
        -e "s|^\($S\)\($W\)$S:$S\(.*\)$S\$|\1$FS\2$FS\3|p"  $1 |
    awk -F$FS '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'${PREFIX}'",toupper(vn), toupper($2), $3);
        }
    }'
}


###
# Indique un avertissement pour la configuration
# @param $1 : Clé de la configuration (variable)
# @param $2 : Valeur par défaut
##
function utils_yaml_warning()
{
    debug "utils_yaml_warning ($1, $2)"
    warning "La configuration YAML:$1 n'est pas renseignée, utilisation de la valeur \"$2\" par défaut."  
}
