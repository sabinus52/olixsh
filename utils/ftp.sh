###
# Librairies de gestions des transferts FTP
# ==============================================================================
# @package olixsh
# @author Olivier
##


###
# Vérifie si le binaire est installé
# @param $1 : Nom du binaire
##
function Ftp.installed()
{
    debug "Ftp.installed ($1)"
    System.binary.exists $1
}


###
# Transfert d'un fichier sur un serveur FTP
# @param $1 : Type de FTP
# @param $2 : Host du serveur FTP
# @param $3 : Utilisateur du serveur FTP
# @param $4 : Mot de passe du serveur FTP
# @param $5 : Dossier de dépôt du serveur FTP
# @param $6 : Nom du fichier à transferer
##
function Ftp.put()
{
    debug "Ftp.put ($1, $2, $3, $4, $5, $6)"
    case $(String.lower $1) in
        lftp)   Ftp.lftp.put  "$2" "$3" "$4" "$5" "$6";;
        ncftp)  Ftp.ncftp.put "$2" "$3" "$4" "$5" "$6";;
        *)      warning "Le type de transfert FTP \"$1\" n'existe pas";;
    esac
    return $?
}


###
# Transfert d'un fichier sur un serveur FTP par LFTP
# @param $1 : Host du serveur FTP
# @param $2 : Utilisateur du serveur FTP
# @param $3 : Mot de passe du serveur FTP
# @param $4 : Dossier de dépôt du serveur FTP
# @param $5 : Nom du fichier à transferer
##
function Ftp.lftp.put()
{
    debug "Ftp.lftp.put ($1, $2, $3, $4, $5)"
    lftp ftp://$2:$3@$1 -e "put -O $4 $5; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Transfert d'un fichier sur un serveur FTP par NCFTP
# @param $1 : Host du serveur FTP
# @param $2 : Utilisateur du serveur FTP
# @param $3 : Mot de passe du serveur FTP
# @param $4 : Dossier de dépôt du serveur FTP
# @param $5 : Nom du fichier à transferer
##
function Ftp.ncftp.put()
{
    debug "ftp_putNCFTP ($1, $2, $3, $4, $5)"
    ncftpput -C -u $2 -p $3 $1 $5 .$4/$(basename $5) > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local
# @param $1 : Type de FTP
# @param $2 : Host du serveur FTP
# @param $3 : Utilisateur du serveur FTP
# @param $4 : Mot de passe du serveur FTP
# @param $5 : Dossier de dépôt du serveur FTP
# @param $6 : Dossier local
##
function Ftp.synchronize()
{
    debug "Ftp.synchronize ($1, $2, $3, $4, $5, $6)"
    case $(String.lower $1) in
        lftp)   Ftp.lftp.synchronize  "$2" "$3" "$4" "$5" "$6";;
        ncftp)  Ftp.ncftp.synchronize "$2" "$3" "$4" "$5" "$6";;
        *)      warning "Le type de transfert FTP \"$1\" n'existe pas";;
    esac
    return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local par LFTP
# @param $1 : Host du serveur FTP
# @param $2 : Utilisateur du serveur FTP
# @param $3 : Mot de passe du serveur FTP
# @param $4 : Dossier de dépôt du serveur FTP
# @param $5 : Dossier local
# @return OLIX_FUNCTION_RESULT : Sortie du traitement
##
function Ftp.lftp.synchronize()
{
    debug "Ftp.lftp.synchronize ($1, $2, $3, $4, $5)"
    local STDOUT=$(System.file.temp)
    OLIX_FUNCTION_RESULT=$STDOUT
    lftp ftp://$2:$3@$1 -e "mirror -e --only-missing -v -R $5 $4; quit" 2>> ${OLIX_LOGGER_FILE_ERR} | tee $STDOUT
    return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local par NCFTP
# @param $1 : Host du serveur FTP
# @param $2 : Utilisateur du serveur FTP
# @param $3 : Mot de passe du serveur FTP
# @param $4 : Dossier de dépôt du serveur FTP
# @param $5 : Nom du fichier à transferer
# @return OLIX_FUNCTION_RESULT : Sortie du traitement
##
function Ftp.ncftp.synchronize()
{
    debug "Ftp.ncftp.synchronize ($1, $2, $3, $4, $5)"

    local LISTFTP=$(ncftpls -l -u $2 -p $3 ftp://$1$4)
    local LISTLOCAL=$(ls $5)
    local STDOUT=$(System.file.temp)
    OLIX_FUNCTION_RESULT=$STDOUT

    # Ajoute les fichiers manquants sur le serveur FTP
    for J in $LISTLOCAL; do
        if ! echo "$LISTFTP" | grep "$J" > /dev/null; then
            echo "Transfert du fichier $J" | tee -a $STDOUT
            ncftpput -C -u $2 -p $3 $1 $5/$J .$4/$J > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
        fi
    done

    # Supprime les fichiers en trop sur le serveur FTP
    while IFS='\n' read LINE; do
        J=$(echo $LINE | awk '{print $9}')
        if ! echo $LISTLOCAL | grep "$J" > /dev/null; then
            echo "Suppression de l'ancien fichier $J" | tee -a $STDOUT
            ncftp -u $2 -p $3 ftp://$1 > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR} <<EOF
                delete $4/$J
                bye
EOF
        fi
    done < <(echo "$LISTFTP")

    return 0
}
