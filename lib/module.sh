###
# Gestion d'un module
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nom du module
##



###
# Retourne le nom du script principal d'un module
##
function Module.script.main()
{
    echo -n "$OLIX_MODULE_PATH/$1/conf/olixmod.sh"
}
alias Module.script='Module.script.main'


###
# Retourne le nom du script de l'action d'un module
# @param $2 : Action du module
##
function Module.script.action()
{
    echo -n "$OLIX_MODULE_PATH/$1/$2.sh"
}


###
# Retourne si le module existe
##
function Module.exists()
{
    local RESULT
    RESULT=$(Module.metaData $1)
    [[ "$RESULT" == "" ]] && return 1
    return 0
}


###
# Retourne si le module est déjà installé
##
function Module.installed()
{
    [[ "$1" == "olixsh" ]] && return 0
    [[ -r $(Module.script $1) ]] && return 0
    return 1
}


###
# Récupère les métadonnées d'un module 
##
function Module.metaData()
{
    local RESULT=""
    [[ -f $OLIX_MODULE_REPOSITORY_USER ]] && RESULT=$(grep "^$1|" $OLIX_MODULE_REPOSITORY_USER)
    [[ -z $RESULT ]] && RESULT=$(grep "^$1|" $OLIX_MODULE_REPOSITORY)
    echo -n "$RESULT"
}


###
# Recupère le label du module
##
function Module.label()
{
    local SCRIPT RESULT
    local MODULE URL LABEL

    # Verifie si le module est déjà installé
    SCRIPT=$(Module.script $1)
    if [[ -f $SCRIPT ]]; then
        # Récupère le label dans le script
        RESULT=$(grep "^# @label " $SCRIPT)
        RESULT=${RESULT/\# \@label/}
        echo -n $RESULT
    else
        # Récupère dans module.lst
        RESULT=$(Module.metaData $1)
        #IFS='|' read MODULE URL LABEL <<< ${RESULT}
        IFS='|' read MODULE URL LABEL < <(echo "$RESULT")
        echo $LABEL
    fi
}


###
# Recupère l'URL de téléchargement du module
##
function Module.url()
{
    local RESULT
    local MODULE URL LABEL
    local PROTOCOL URI

    RESULT=$(Module.metaData $1)
    IFS='|' read MODULE URL LABEL < <(echo -e "$RESULT")
    IFS=':' read PROTOCOL URI < <(echo -e "$URL")
    if [[ $PROTOCOL == "github" ]]; then
        debug "GITHUB=https:$URI"
        URL=$(curl -s https:$URI | grep 'tarball_url' | cut -d\" -f4)
    fi
    echo -n $URL
}



###
# Retourne le liste des modules déjà installés
##
function Module.all.installed()
{
    find $OLIX_MODULE_PATH -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort
}


###
# Retourne la liste des modules disponibles
##
function Module.all.available()
{
    local FILES="$OLIX_MODULE_REPOSITORY"
    [[ -r $OLIX_MODULE_REPOSITORY_USER ]] && FILES="$FILES $OLIX_MODULE_REPOSITORY_USER"
    cat $FILES | grep -v "^#" | grep -v "^olixsh" | cut -d '|' -f1 | sort | uniq
}
