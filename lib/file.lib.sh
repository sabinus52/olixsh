###
# Librairies de la gestion de système de fichiers
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Parse un fichier YAML
# @param $1 : Nom du fichier
# @param $2 : Prefix des variables de sortie
# @use : eval $(file_parseYaml config.yml "config_")
# @link : https://gist.github.com/pkuczynski/8665367
##
function file_parseYaml()
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
         printf("%s%s%s=\"%s\"\n", "'$PREFIX'",toupper(vn), toupper($2), $3);
      }
   }'
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
function file_purgeLogarithmic() {
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
