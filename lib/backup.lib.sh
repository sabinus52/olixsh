###
# Librairies pour la gestion des sauvegardes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


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
    report_printMessageReturn ${RET} "Compression du fichier" "$(filesystem_getSizeFileHuman ${OLIX_FUNCTION_RESULT})" "$((SECONDS-START))"

    [[ $? -ne 0 ]] && report_warning && logger_warning2 && return 1
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
    report_printInfo "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    stdout_printFile "${LIST_FILE_PURGED}"
    report_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:Olive;"
    [[ ${RET} -ne 0 ]] && report_warning && logger_warning2 && return 1

    stdout_printInfo "Liste des sauvegardes restantes" "$(find $1 -maxdepth 1 -name "$2" | wc -l)"
    report_printInfo "Liste des sauvegardes restantes" "$(find $1 -maxdepth 1 -name "$2" | wc -l)"
    find $1 -maxdepth 1 -name "$2" -printf "%f\n" |sort > ${LIST_FILE_PURGED}
    RET=$?
    stdout_printFile "${LIST_FILE_PURGED}"
    report_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:SteelBlue;"

    [[ $RET -ne 0 ]] && report_warning && logger_warning2 && return 1
    rm -f ${LIST_FILE_PURGED}
    return 0
}
