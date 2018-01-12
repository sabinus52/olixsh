###
# Librairies de gestions des transferts SCP
# ==============================================================================
# @package olixsh
# @author Olivier
##


###
# Paramètres
##
OLIX_SCP_HOST=
OLIX_SCP_USER=
OLIX_SCP_PASS=
OLIX_SCP_CONNECTION=
OLIX_SCP_PARAM=


###
# Vérifie si le binaire est installé
##
function Scp.installed()
{
    debug "Scp.installed ()"
    System.binary.exists 'scp'
    return $?
}


###
# Transfert d'un fichier sur un serveur SSH
# @param $1 : Host du serveur SSH
# @param $2 : Utilisateur du serveur SSH
# @param $3 : Clé publique
##
function Scp.initialize()
{
    debug "Scp.initialize ($1, $2, $3)"
    [[ $# -ne 3 ]] && error "Paramètres manquants dans Scp.initialize" && return

    OLIX_SCP_HOST=$1
    OLIX_SCP_USER=$2
    OLIX_SCP_PASS=$3
    OLIX_SCP_CONNECTION=$(Scp.getConnection)
    OLIX_SCP_PARAM=$(Scp.getParam)
    debug "SCP chaine de connexion : $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION"
}


###
# Retourne la chaine de connexion
##
function Scp.getConnection()
{
    echo -n "$OLIX_SCP_USER@$OLIX_SCP_HOST"
}


###
# Retourne les paramètres de connexion SSH
##
function Scp.getParam()
{
    debug "Scp.getParam ()"
    local PARAM
    [[ -n $OLIX_SCP_PASS ]] && PARAM="-i $OLIX_SCP_PASS"
    echo -n $PARAM
}


###
# Vérifie la connection FTP
##
function Scp.check.connection()
{
    debug "Scp.check.connection ()"
    ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "test -d /" 2>/dev/null
    return $?
}


###
# Verifie si un dossier ou fichier existe
# @param $1 : Dossier ou fichier distant
##
function Scp.check.exists()
{
    debug "Scp.check.exists ($1)"
    local TESTSCP
    TESTSCP=$(ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "[ -e $1 ] || echo 'ko'")
    [[ $? -ne 0 ]] && return 9
    [[ -z $TESTSCP ]] && return 0 || return 1
}


###
# Verifie si un dossier ou fichier existe
# @param $1 : Dossier ou fichier distant
##
function Scp.check.file()
{
    debug "Scp.check.file ($1)"
    local TESTSCP
    TESTSCP=$(ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "[ -f $1 ] || echo 'ko'")
    [[ $? -ne 0 ]] && return 9
    [[ -z $TESTSCP ]] && return 0 || return 1
}


###
# Verifie si un dossier distant existe
# @param $1 : Dossier distant
##
function Scp.check.directory()
{
    debug "Scp.check.directory ($1)"
    local TESTSCP
    TESTSCP=$(ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "[ -d $1 ] || echo 'ko'")
    [[ $? -ne 0 ]] && return 9
    [[ -z $TESTSCP ]] && return 0 || return 1
}


###
# Verifie si un dossier distant est en écriture
# @param $1 : Dossier distant
##
function Scp.check.writable()
{
    debug "Scp.check.writable ($1)"
    local TESTSCP
    TESTSCP=$(ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "[ -w $1 ] || echo 'ko'")
    [[ $? -ne 0 ]] && return 9
    [[ -z $TESTSCP ]] && return 0 || return 1
}


###
# Transfert d'un fichier sur un serveur SSH
# @param $1 : Nom du fichier à transferer
# @param $2 : Dossier de dépôt du serveur SSH
##
function Scp.put()
{
    debug "Scp.put ($1, $2)"
    debug "scp $OLIX_SCP_PARAM $1 $OLIX_SCP_CONNECTION:$2"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        scp $OLIX_SCP_PARAM -- $1 $OLIX_SCP_CONNECTION:$2 2>> ${OLIX_LOGGER_FILE_ERR}
    else
        scp $OLIX_SCP_PARAM -- $1 $OLIX_SCP_CONNECTION:$2 > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    fi
    return $?
}


###
# Suppresion d'un fichier sur un serveur SSH
# @param $1 : Nom du fichier
##
function Scp.remove()
{
    debug "Scp.remove ($1)"
    [[ $1 == "/" ]] && return 1
    ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "rm -rf $1" 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Création d'un dossier sur un serveur SSH
# @param $1 : Nom du fichier à créer
# @param $2 : Dossier de dépôt du serveur SSH
##
function Scp.mkdir()
{
    debug "Scp.mkdir ($1, $2)"
    ssh -n -- $OLIX_SCP_PARAM $OLIX_SCP_CONNECTION "mkdir -p $2/$1" 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}
