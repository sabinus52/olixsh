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