###
# Fonctions d'utilitaires divers
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Fait une synchronisation depuis un serveur distant
# @param $1 : Port
# @param $2 : Chemin source (path | host+path)
# @param $3 : Chemin destination (path | host+path)
# @param $4 : Exclusion
# @param $5 : Paramètres supplémentaires
##
function Filesystem.synchronize()
{
    debug "Filesystem.synchronize ($1, $2, $3, $4, $5)"
    local PARAM=$5
    local FILE_EXCLUDE=$(File.exclude.create "$4")

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="$PARAM --progress"
    rsync $PARAM --rsh="ssh -p $1" --archive --compress --delete --exclude-from=$FILE_EXCLUDE $2/ $3/ 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?

    File.exists $FILE_EXCLUDE && rm -f $FILE_EXCLUDE
    return $?
}


###
# Purge normal correspondant aux derniers jours
# @param $1 : Emplacement des fichiers à purger
# @param $2 : Masque correspondant aux fichiers à effacer
# @param $3 : Nombre de jours de retention
# @param $4 : Fichier qui contiendra la liste des fichiers purgés
##
function Filesystem.purge.standard()
{
    local FREDIRECT
    [[ -z $4 ]] && FREDIRECT="/dev/null" || FREDIRECT=$4
    debug "Filesystem.purge.standard ($1, $2, $3, $FREDIRECT)"
    #find $1 -name "$2*" -mtime +$3 -fprintf ${FREDIRECT} "%f\n" -delete > /dev/null 2> ${OLIX_LOGGER_FILE_ERR}
    find $1 -mindepth 1 -maxdepth 1 -name "$2*" -mtime +$3 -printf "%f\n" -delete |sort > $FREDIRECT 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Purge logarithmique correspondant aux derniers jours
# @param $1 : Emplacement des fichiers à purger
# @param $2 : Masque correspondant aux fichiers à effacer
# @param $3 : Fichier qui contiendra la liste des fichiers purgés
##
function Filesystem.purge.logarithmic()
{
    local FILE
    local I
    [[ -z $3 ]] && FREDIRECT="/dev/null" || FREDIRECT=$3
    debug "Filesystem.purge.logarithmic ($1, $2, $FREDIRECT)"
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
    find $1 -maxdepth 1 -name "$2*" -mtime +0 -printf "%f\n" -delete |sort > $FREDIRECT 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}
