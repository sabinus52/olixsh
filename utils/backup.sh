###
# Librairies pour la gestion des sauvegardes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies necessaires
##
load "utils/compression.sh"
load "utils/filesystem.sh"
load "utils/ftp.sh"


###
# Paramètres
##
OLIX_BACKUP_FILE=
OLIX_BACKUP_FILE_PREFIX=

OLIX_BACKUP_PATH="/tmp"
OLIX_BACKUP_COMPRESS="GZ"
OLIX_BACKUP_TTL="5"

OLIX_BACKUP_FTP=false
OLIX_BACKUP_FTP_HOST=
OLIX_BACKUP_FTP_PORT="21"
OLIX_BACKUP_FTP_USER=
OLIX_BACKUP_FTP_PASS=
OLIX_BACKUP_FTP_PATH=


###
# Initialisation du backup
# @param $1  : Emplacement du backup.
# @param $3  : Compression
# @param $4  : Rétention pour la purge
##
function Backup.initialize()
{
    debug "Backup.initialize ($1, $2, $3)"
    [[ -z $1 ]] && return
    OLIX_BACKUP_PATH=$1
    [[ -z $2 ]] && return
    OLIX_BACKUP_COMPRESS=$2
    [[ -z $3 ]] && return
    OLIX_BACKUP_TTL=$3
}


###
# Retourne le chemin où du fichier sera sauvegardé
##
function Backup.path()
{
    echo -n $OLIX_BACKUP_PATH
}


###
# Finalise la sauvegarde d'un fichier -> Compression -> transfert FTP -> Purge
# @param $1 : Nom du fichier sauvegardé
# @pâram $2 : Prefix du fichier
##
function Backup.continue()
{
    debug "Backup.continue ($1)"
    OLIX_BACKUP_FILE=$1
    OLIX_BACKUP_FILE_PREFIX=$2

    utils_backup_compress || return 1

    utils_backup_ftp || return 1 

    utils_backup_move || return 1

    utils_backup_purge || return 1

    return 0
}


###
# Fait une sauvegarde d'un répertoire
# @param $1  : Nom du dossier
# @param $2  : Fichier à exclure
##
function Backup.directory()
{
    debug "Backup.directory ($1, $2)"
    local DIR=$1
    local EXCLUDE=$2
    local START=$SECONDS

    Print.head2 "Sauvegarde du dossier %s" "$DIR"

    local OLIX_BACKUP_FILE="$(Backup.path)/backup-$(basename $DIR)-${OLIX_SYSTEM_DATE}.tar"
    info "Sauvegarde Dossier (${DIR}) -> ${OLIX_BACKUP_FILE}"

    Compression.tar.create "$DIR" "$OLIX_BACKUP_FILE" "$EXCLUDE"
    Print.result $? "Archivage du dossier" "$(File.size.human $OLIX_BACKUP_FILE)" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1

    Backup.continue "$OLIX_BACKUP_FILE" "backup-$(basename ${DIR})-"

    return $?
}


###
# Synchronisation avec le serveur FTP
##
function Backup.ftp.synchronize()
{
    debug "Backup.ftp.synchronize ()"

    [[ -z $1 ]] && return 0
    [[ $1 == false ]] && return 0

    Print.head2 "Synchronisation avec le serveur FTP %s" "${OLIX_BACKUP_FTP_HOST}"
    START=$SECONDS

    Ftp.synchronize "$OLIX_BACKUP_FTP" "$OLIX_BACKUP_FTP_HOST" "$OLIX_BACKUP_FTP_USER" "$OLIX_BACKUP_FTP_PASS" \
                    "$OLIX_BACKUP_FTP_PATH" "$OLIX_BACKUP_PATH"

    Print.result $? "Synchronisation avec le serveur FTP" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1

    Print.file "$OLIX_FUNCTION_RESULT" "font-size:0.8em;"
    return 0
}



###################################################################################################


###
# Compression d'un fichier de sauvegarde
##
function utils_backup_compress()
{
    debug "utils_backup_compress ()"
    local RET
    local START=$SECONDS

    case $(String.lower $OLIX_BACKUP_COMPRESS) in
        bz|bz2)
            Compression.bzip.compress $OLIX_BACKUP_FILE
            RET=$?
            OLIX_BACKUP_FILE=$OLIX_FUNCTION_RESULT
            ;;
        gz)
            Compression.gzip.compress $OLIX_BACKUP_FILE
            RET=$?
            OLIX_BACKUP_FILE=$OLIX_FUNCTION_RESULT
            ;;
        null)
            return 0
            ;;
        *)
            warning "Le type de compression \"${OLIX_BACKUP_COMPRESS}\" n'est pas disponible"
            return 0
            ;;
    esac
    
    Print.result ${RET} "Compression du fichier" "$(File.size.human $OLIX_BACKUP_FILE)" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Transfert le fichier backup vers un serveur FTP
##
function utils_backup_ftp()
{
    debug "utils_backup_ftp ()"
    local START=$SECONDS

    [[ -z $1 ]] && warning "Pas de transfert FTP configuré" && return 0
    [[ $1 == false ]] && warning "Pas de transfert FTP configuré" && return 0

    Ftp.put "$OLIX_BACKUP_FTP" "$OLIX_BACKUP_FTP_HOST" "$OLIX_BACKUP_FTP_USER" \
            "$OLIX_BACKUP_FTP_PATH" "$OLIX_BACKUP_FILE"

    Print.result $? "Transfert vers le serveur de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Déplace le fichier backup de /tmp ver le repertoire de backup défini
##
function utils_backup_move()
{
    debug "utils_backup_move ()"
    local START=$SECONDS
    
    # Si meme dossier que la destination
    [[ $(dirname $OLIX_BACKUP_FILE) == $(dirname $OLIX_BACKUP_PATH/empty) ]] && return 0

    mv $OLIX_BACKUP_FILE $OLIX_BACKUP_PATH/ > ${OLIX_LOGGER_FILE_ERR} 2>&1

    Print.result $? "Déplacement vers le dossier de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Purge des anciens fichiers
##
function utils_backup_purge()
{
    debug "backup_purge ()"

    local LIST_FILE_PURGED=$(System.file.temp)
    local RET

    case $OLIX_BACKUP_TTL in
        LOG|log)
            Filesystem.purge.standard $OLIX_BACKUP_PATH $OLIX_BACKUP_FILE_PREFIX $LIST_FILE_PURGED
            RET=$?;;
        *)  
            Filesystem.purge.standard $OLIX_BACKUP_PATH $OLIX_BACKUP_FILE_PREFIX $OLIX_BACKUP_TTL $LIST_FILE_PURGED
            RET=$?;;
    esac

    Print.value "Purge des anciennes sauvegardes" "$(cat $LIST_FILE_PURGED | wc -l)"
    Print.file $LIST_FILE_PURGED
    [[ ${RET} -ne 0 ]] && warning && return 1

    Print.value "Liste des sauvegardes restantes" "$(find $OLIX_BACKUP_PATH -maxdepth 1 -name "$OLIX_BACKUP_FILE_PREFIX*" | wc -l)"
    find $OLIX_BACKUP_PATH -maxdepth 1 -name "$OLIX_BACKUP_FILE_PREFIX*" -printf "%f\n" |sort > $LIST_FILE_PURGED
    RET=$?
    Print.file $LIST_FILE_PURGED

    [[ $RET -ne 0 ]] && error && return 1
    rm -f $LIST_FILE_PURGED
    return 0
}
