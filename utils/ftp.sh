###
# Librairies de gestions des transferts FTP
# ==============================================================================
# @package olixsh
# @author Olivier
##


###
# Paramètres
##
OLIX_FTP_HOST=
OLIX_FTP_USER=
OLIX_FTP_PASS=
OLIX_FTP_CONNECTION=



###
# Vérifie si le binaire est installé
##
function Ftp.installed()
{
    debug "Ftp.installed ()"
    System.binary.exists 'lftp'
    return $?
}


###
# Transfert d'un fichier sur un serveur FTP
# @param $1 : Host du serveur FTP
# @param $2 : Utilisateur du serveur FTP
# @param $3 : Mot de passe du serveur FTP
##
function Ftp.initialize()
{
    debug "Ftp.initialize ($1, $2, $3)"
    [[ $# -ne 3 ]] && error "Paramètres manquants dans FTP.initialize" && return

    OLIX_FTP_HOST=$1
    OLIX_FTP_USER=$2
    OLIX_FTP_PASS=$3
    OLIX_FTP_CONNECTION=$(Ftp.getConnection)
    debug "FTP chaine de connexion : $OLIX_FTP_CONNECTION"
}


###
# Retourne la chaine de connexion
##
function Ftp.getConnection()
{
    echo -n "ftp://$OLIX_FTP_USER:$OLIX_FTP_PASS@$OLIX_FTP_HOST"
}


###
# Vérifie la connection FTP
##
function Ftp.check.connection()
{
    debug "Ftp.check.connection ()"
    lftp $OLIX_FTP_CONNECTION -e "dir; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Verifie si un dossier distant existe
# @param $1 : Dossier distant
##
function Ftp.check.directory()
{
    debug "Ftp.check.directory ($1)"
    lftp $OLIX_FTP_CONNECTION -e "cd $1; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Verifie si un dossier distant est en écriture
# @param $1 : Dossier distant
##
function Ftp.check.writable()
{
    debug "Ftp.check.writable ($1)"
    lftp $OLIX_FTP_CONNECTION -e "cd $1; mkdir _testolix_; rmdir _testolix_; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Transfert d'un fichier sur un serveur FTP
# @param $1 : Nom du fichier à transferer
# @param $2 : Dossier de dépôt du serveur FTP
##
function Ftp.put()
{
    debug "Ftp.put ($1, $2)"
    lftp $OLIX_FTP_CONNECTION -e "put -O $2 $1; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Suppresion d'un fichier sur un serveur FTP
# @param $1 : Nom du fichier
##
function Ftp.remove()
{
    debug "Ftp.remove ($1)"
    lftp $OLIX_FTP_CONNECTION -e "rm $1; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Création d'un dossier sur un serveur FTP
# @param $1 : Nom du dossier à créer
# @param $2 : Dossier de dépôt du serveur FTP
##
function Ftp.mkdir()
{
    debug "Ftp.mkdir ($1, $2)"
    lftp $OLIX_FTP_CONNECTION -e "cd $2; mkdir $1; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Suppression d'un dossier sur un serveur FTP
# @param $1 : Nom du dossier à supprimer
##
function Ftp.rmdir()
{
    debug "Ftp.rmdir ($1)"
    lftp $OLIX_FTP_CONNECTION -e "rm -r $1; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}
