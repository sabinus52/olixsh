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
   local PARAM
   [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"

   gzip ${PARAM} --force $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
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
   local PARAM
   [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"

   bzip2 ${PARAM} --force $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
   [[ $? -ne 0 ]] && return 1

   OLIX_FUNCTION_RESULT="$1.bz2"
   return 0
}
