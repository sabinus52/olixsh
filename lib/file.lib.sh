###
# Librairies de la gestion de système de fichiers
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Crée le fichier d'exclusion pour la synchronisation
# @param $1 : Nom du fichier exclude
# @param $2 : Liste des exclusions
##
function file_createFileExclude()
{
    logger_debug "file_createFileExclude($1, $2)"
    local EXCLUDE
    echo "" > $1
    IFS='|'
    for I in $2; do
      echo $I >> $1
    done
    unset IFS
    sed -i "s/\\\//g" $1
}


###
# Fait une synchronisation depuis un serveur distant
# @param $1 : Port
# @param $2 : Chemin source (path | host+path)
# @param $3 : Chemin destination (path | host+path)
# @param $4 : Exclusion
# @param $5 : Paramètres supplémentaires
##
function file_synchronize()
{
    logger_debug "filesystem_synchronize ($1, $2, $3, $4, $5)"
    local FILE_EXCLUDE=$(core_makeTemp)
    local PARAM=$5
    file_createFileExclude "${FILE_EXCLUDE}" "$4"

    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="${PARAM} --progress"
    rsync ${PARAM} --rsh="ssh -p $1" --archive --compress --delete --exclude-from=${FILE_EXCLUDE} $2/ $3/ 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?

    rm -f ${FILE_EXCLUDE}
    [[ $RET -ne 0 ]] && return 1
    return 0
}


###
# Archive un repertoire
# @param $1 : Nom du repertoire
# @param $2 : Nom de l'archive
# @param $3 : Exclusion
# @param $4 : Autres options
##
function file_makeArchive()
{
    logger_debug "file_makeArchive ($1, $2, $3, $4)"
    local PWDTMP PARAM RET
    local FILE_EXCLUDE=$(core_makeTemp)
    file_createFileExclude "${FILE_EXCLUDE}" "$3"
    
    PWDTMP=$(pwd)
    cd $1 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd ${PWDTMP} && return 1

    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    [[ -n $4 ]] && PARAM="${PARAM} $4"
    
    logger_debug "tar ${PARAM} --create --file $2 --exclude-from ${FILE_EXCLUDE} ."
    tar ${PARAM} --create --file $2 --exclude-from ${FILE_EXCLUDE} . 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?
    [[ ${RET} -ne 0 ]] && cd ${PWDTMP} && return ${RET}
    
    rm -f ${FILE_EXCLUDE}
    [[ $RET -ne 0 ]] && return 1
    return 0
}


###
# Extrait une archive dans un emplacement désiré
# @param $1 : Nom du fichier
# @param $2 : Emplacement
# @param $3 : Paramètre supplémentaire
# @return   : Nom du fichier compressé
##
function file_extractArchive()
{
    logger_debug "file_extractArchive ($1, $2, $3)"
    local OPTS=""

    [[ ${OLIX_OPTION_VERBOSE} == true ]] && OPTS="${OPTS} --verbose"
    [[ -n $3 ]] && OPTS="${OPTS} $3"
    logger_info "Extraction de $1 vers $2"
    logger_debug "tar --extract ${OPTS} --file=$1 --directory=$2"

    tar --extract ${OPTS} --file=$1 --directory=$2 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Compression au format GZ d'un fichier
# @param $1 : Nom du fichier
# @return string : Nom du fichier compressé
##
function file_compressGZ()
{
    logger_debug "file_compressGZ ($1)"
    OLIX_FUNCTION_RESULT=$1

    gzip --force $1 1> ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1

    OLIX_FUNCTION_RESULT="$1.gz"
    return 0
}


###
# Compression au format BZ2 d'un fichier
# @param $1 : Nom du fichier
# @return string : Nom du fichier compressé
##
function file_compressBZ2()
{
    logger_debug "file_compressBZ2 ($1)"
    OLIX_FUNCTION_RESULT=$1

    bzip2 --force $1 1> ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1

    OLIX_FUNCTION_RESULT="$1.bz2"
    return 0
}



###
# Purge normal correspondant aux derniers jours
# @param $1 : Emplacement des fichiers à purger
# @param $2 : Masque correspondant aux fichiers à effacer
# @param $3 : Nombre de jours de retention
# @param $4 : Fichier qui contiendra la liste des fichiers purgés
##
function file_purgeStandard()
{
    local FREDIRECT
    [[ -z $4 ]] && FREDIRECT="/dev/null" || FREDIRECT=$4
    logger_debug "file_purgeStandard ($1, $2, $3, $FREDIRECT)"
    #find $1 -name "$2*" -mtime +$3 -fprintf ${FREDIRECT} "%f\n" -delete > /dev/null 2> ${OLIX_LOGGER_FILE_ERR}
    find $1 -maxdepth 1 -name "$2*" -mtime +$3 -printf "%f\n" -delete |sort > ${FREDIRECT} 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Purge logarithmique correspondant aux derniers jours
# @param $1 : Emplacement des fichiers à purger
# @param $2 : Masque correspondant aux fichiers à effacer
# @param $3 : Fichier qui contiendra la liste des fichiers purgés
##
function file_purgeLogarithmic()
{
    local FILE
    local I
    [[ -z $3 ]] && FREDIRECT="/dev/null" || FREDIRECT=$3
   logger_debug "file_purgeLogarithmic ($1, $2, $FREDIRECT)"
    #for (( I=2010 ; I<=`date '+%Y'` ; I++ )); do
    #    FILE=$1$I-01-01$2
    #    find $FILE* 2> /dev/null
    #    find $FILE* -exec touch \{\} \; 2> /dev/null
    #done
    for (( I=1 ; I<=12 ; I++ )); do
        FILE=$2$(date --date "$I months ago" +%Y-%m)-01
        #find $1 -name $FILE* 2> /dev/null
        find $1 -maxdepth 1 -name $FILE* -exec touch \{\} \; 2> /dev/null
    done
    for (( I=1 ; I<=60 ; I++ )); do
        if [ $(date --date "$I days ago" +%u) -eq 3 ]; then
            FILE=$2$(date --date "$I days ago" +%F)
            #find $1 -name $FILE* 2> /dev/null
            find $1 -maxdepth 1 -name $FILE* -exec touch \{\} \; 2> /dev/null
        fi
    done
    for (( I=1 ; I<=7 ; I++ )); do
        FILE=$2$(date --date "$I days ago" +%F)
        #find $1 -name $FILE* 2> /dev/null
        find $1 -maxdepth 1 -name $FILE* -exec touch \{\} \; 2> /dev/null
    done
    #find $1 -name "$2*" -mtime +0 -fprintf ${FREDIRECT} "%f\n" -delete > /dev/null 2> ${OLIX_LOGGER_FILE_ERR}
    find $1 -maxdepth 1 -name "$2*" -mtime +0 -printf "%f\n" -delete |sort > ${FREDIRECT} 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}
