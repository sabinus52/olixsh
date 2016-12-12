###
# Mise à jour d'oliXsh sur le système
# ==============================================================================
# @package olixsh
# @command update
# @author Olivier <sabinus52@gmail.com>
##


###
# Chargement des utilitaires
## 
load "utils/fileconfig.sh"
load "utils/module.sh"


###
# Constantes
##
# Force l'activation des warnings
OLIX_OPTION_WARNINGS=true


info "Exécution de la mise à jour d'oliXsh"


###
# Test si c'est le propriétaire
##
info "Test si c'est le propriétaire"
checkOlixshOwner
[[ $? -ne 0 ]] && critical "Seul l'utilisateur \"$(Core.owner)\" peut exécuter ce script"


echo -e "${CBLANC}Mise à jour de oliXsh${CVOID}"
echo -e "${CBLANC}---------------------${CVOID}"


###
# Télécharge la mise à jour d'Olix
##
Module.download "olixsh"
[[ $? -ne 0 ]] && critical "Impossible de télécharger la mise à jour oliXsh"


###
# Déploiement de la mise à jour
##
info "Déploiement de la mise à jour"

Compression.tar.extract "/tmp/olix.tar.gz" "/tmp" "--gzip"
[[ $? -ne 0 ]] && critical "Impossible d'extraire l'archive téléchargée"

DIRTAR="/tmp/$(tar -tf /tmp/olix.tar.gz | grep -o '^[^/]\+' | sort -u)"
debug "TAR DIR SOURCE=${DIRTAR}"
info "Copie des fichiers à mettre à jour"

cp $DIRTAR/completion/olixmain $OLIX_ROOT/completion > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/conf/modules.lst $OLIX_ROOT/conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/conf/olixsh.conf $OLIX_ROOT/conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/core/* $OLIX_ROOT/core > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp -r $DIRTAR/lib/* $OLIX_ROOT/lib > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/commands/* $OLIX_ROOT/commands > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp -r $DIRTAR/utils/* $OLIX_ROOT/utils > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/olixsh $OLIX_ROOT > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/LICENSE $OLIX_ROOT > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/VERSION $OLIX_ROOT > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"

cp $DIRTAR/README.md $OLIX_ROOT > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de déployer la mise à jour oliXsh"



###
# FIN
##
echo -e "${CVERT}La mise àjour oliXsh s'est terminée avec succès${CVOID}"
