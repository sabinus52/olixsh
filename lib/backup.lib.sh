###
# Librairies pour la gestion des sauvegardes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Finalise la sauvegarde d'un fichier -> Compression -> transfert FTP -> Purge
# @param $1  : Nom du fichier à sauvegarder
# @param $2  : Emplacement du backup
# @param $3  : Compression
# @param $4  : Rétention pour la purge
# @param $5  : Préfixe du fichier
# @param $6  : FTP type utilisé (false|lftp|ncftp)
# @param $7  : Host du FTP
# @param $8  : Utilisateur du FTP
# @param $9  : Password du FTP
# @param $10 : Chemin du FTP
##
function backup_finalize()
{
    logger_debug "backup_finalize ($1)"
    local FILE=$1
    local DIRBCK=$2
    local COMPRESS=$3
    local PURGE=$4
    local PREFIX=$5
    shift
    local FTP=$5
    local FTP_HOST=$6
    local FTP_USER=$7
    local FTP_PASS=$8
    local FTP_PATH=$9

    backup_compress "${COMPRESS}" "${FILE}"
    [[ $? -ne 0 ]] && return 1
    FILE=${OLIX_FUNCTION_RESULT}

    backup_transfertFTP "${FTP}" "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_PATH}" "${FILE}"
    [[ $? -ne 0 ]] && return 1

    backup_moveArchive "${FILE}" "${DIRBCK}"
    [[ $? -ne 0 ]] && return 1

    backup_purge "${DIRBCK}" "${PREFIX}" "${PURGE}"
    [[ $? -ne 0 ]] && return 1

    return 0
}


###
# Déplace le fichier backup de /tmp ver le repertoire de backup défini
# @param $1 : Nom du fichier à transferer
# @param $2 : Dossier de backup de destination
##
function backup_moveArchive()
{
    logger_debug "backup_moveArchive ($1, $2)"
    local START=${SECONDS}
    
    # Si meme dossier que la destination
    [[ $(dirname $1) == $(dirname $2/empty) ]] && return 0

    mv $1 $2/ > ${OLIX_LOGGER_FILE_ERR} 2>&1

    stdout_printMessageReturn $? "Déplacement vers le dossier de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1
    return 0
}


###
# Compression d'un fichier de sauvegarde
# @param $1 : Type de compression
# @param $2 : Fichier à compresser
# @return OLIX_FUNCTION_RESULT : Nom du fichier compressé
##
function backup_compress()
{
    logger_debug "backup_compress ($1, $2)"
    local RET
    local START=${SECONDS}

    case $1 in
        BZ|bz|BZ2|bz2)
            file_compressBZ2 $2
            RET=$?
            ;;
        GZ|gz)
            file_compressGZ $2
            RET=$?
            ;;
        NULL|null)
            OLIX_FUNCTION_RESULT=$2
            return 0
            ;;
        *)
            logger_warning "Le type de compression \"$1\" n'est pas disponible"
            OLIX_FUNCTION_RESULT=$2
            return 0
            ;;
    esac
    
    stdout_printMessageReturn ${RET} "Compression du fichier" "$(filesystem_getSizeFileHuman ${OLIX_FUNCTION_RESULT})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1
    return 0
}


###
# Transfert le fichier backup vers un serveur FTP
# $1 : Type de FTP
# $2 : Host du serveur FTP
# $3 : Utilisateur du serveur FTP
# $4 : Mot de passe du serveur FTP
# $5 : Dossier de dépôt du serveur FTP
# $6 : Nom du fichier à transferer
##
function backup_transfertFTP()
{
    logger_debug "backup_transfertFTP ($1, $2, $3, $4, $5, $6)"
    local START=${SECONDS}

    [[ -z $1 ]] && logger_warning "Pas de transfert FTP configuré" && return 0
    [[ $1 == false ]] && logger_warning "Pas de transfert FTP configuré" && return 0

    ftp_put "$1" "$2" "$3" "$4" "$5" "$6"

    stdout_printMessageReturn $? "Transfert vers le serveur de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1
    return 0
}


###
# Purge des anciens fichiers
# @param $1 : Dossier à analyser
# @param $2 : Masque des fichiers à purger
# @param $3 : Retention
##
function backup_purge()
{
    local LIST_FILE_PURGED=$(core_makeTemp)
    logger_debug "backup_purge ($1, $2, $3)"
    local RET

    case $3 in
        LOG|log)
            file_purgeLogarithmic "$1" "$2" "${LIST_FILE_PURGED}"
            RET=$?;;
        *)  
            file_purgeStandard "$1" "$2" "$3" "${LIST_FILE_PURGED}"
            RET=$?;;
    esac

    stdout_printInfo "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    stdout_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:Olive;"
    [[ ${RET} -ne 0 ]] && logger_warning && return 1

    stdout_printInfo "Liste des sauvegardes restantes" "$(find $1 -maxdepth 1 -name "$2" | wc -l)"
    find $1 -maxdepth 1 -name "$2" -printf "%f\n" |sort > ${LIST_FILE_PURGED}
    RET=$?
    stdout_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:SteelBlue;"

    [[ $RET -ne 0 ]] && logger_error && return 1
    rm -f ${LIST_FILE_PURGED}
    return 0
}


###
# Fait une sauvegarde d'un répertoire
# @param $1  : Nom du dossier
# @param $2  : Fichier à exclure
# @param $3  : Emplacement du backup
# @param $4  : Compression
# @param $5  : Rétention pour la purge
# @param $6  : FTP type utilisé (false|lftp|ncftp)
# @param $7  : Host du FTP
# @param $8  : Utilisateur du FTP
# @param $9  : Password du FTP
# @param $10 : Chemin du FTP
##
function backup_directory()
{
    local DIR=$1
    local EXCLUDE=$2
    shift
    local DIRBCK=$2
    local COMPRESS=$3
    local PURGE=$4
    local FTP=$5
    local FTP_HOST=$6
    local FTP_USER=$7
    local FTP_PASS=$8
    local FTP_PATH=$9
    logger_debug "backup_directory (${DIR}, ${EXCLUDE}, $2, $3, $4, $5, $6 ,$6, $7, $8, $9)"

    stdout_printHead2 "Sauvegarde du dossier %s" "${DIR}"

    local FILEBCK="${DIRBCK}/backup-$(basename ${DIR})-${OLIX_SYSTEM_DATE}.tar"
    logger_info "Sauvegarde Dossier (${DIR}) -> ${FILEBCK}"

    local START=${SECONDS}

    file_makeArchive "${DIR}" "${FILEBCK}" "${EXCLUDE}"
    stdout_printMessageReturn $? "Archivage du dossier" "$(filesystem_getSizeFileHuman ${FILEBCK})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1

    backup_finalize "${FILEBCK}" "${DIRBCK}" "${COMPRESS}" "${PURGE}" "dump-${BASE}-*" \
        "${FTP}" "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_PATH}"

    return $?
}


###
# Synchronisation avec le serveur FTP
# @param $1 : Emplacement du backup
# @param $2 : FTP type utilisé (false|lftp|ncftp)
# @param $3 : Host du FTP
# @param $4 : Utilisateur du FTP
# @param $5 : Password du FTP
# @param $6 : Chemin du FTP
##
function backup_synchronizeFTP()
{
    logger_debug "backup_synchronizeFTP ($1, $2, $3, $4, $5, $6)"
    local REPOSITORY=$1
    local FTP=$2
    local FTP_HOST=$3
    local FTP_USER=$4
    local FTP_PASS=$5
    local FTP_PATH=$6

    [[ -z ${FTP} ]] && return 0
    [[ ${FTP} == false ]] && return 0

    stdout_printHead2 "Synchronisation avec le serveur FTP %s" "${FTP_HOST}"
    START=${SECONDS}

    ftp_synchronize "${FTP}" "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_PATH}" "${REPOSITORY}"

    stdout_printMessageReturn $? "Synchronisation avec le serveur FTP" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1

    stdout_printFile "${OLIX_FUNCTION_RESULT}" "font-size:0.8em;"
    return 0
}
