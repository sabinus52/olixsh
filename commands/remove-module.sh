###
# Suppression des modules oliXsh
# ==============================================================================
# @package olixsh
# @command remove
# @author Olivier <sabinus52@gmail.com>
##


###
# Chargement des utilitaires
##
load "utils/module.sh"


###
# Paramètres et Constantes
##
# Nom du module
OLIX_MODULE_NAME=$1
# Force l'activation des warnings
OLIX_OPTION_WARNINGS=true


info "Exécution de la suppression du module ${OLIX_MODULE_NAME}"


###
# Test si c'est le propriétaire
##
info "Test si c'est le propriétaire"
checkOlixshOwner
[[ $? -ne 0 ]] && critical "Seul l'utilisateur \"$(Core.owner)\" peut exécuter ce script"


echo -e "${CBLANC}Suppression du module ${CVIOLET}$OLIX_MODULE_NAME${CVOID}"
echo -e "${CBLANC}--------------------------------------${CVOID}"



###
# Vérification du module
##
info "Vérification du module ${OLIX_MODULE_NAME}"
! $(Module.exists $OLIX_MODULE_NAME) && critical "Le module '${OLIX_MODULE_NAME}' est inéxistant"

info "Vérification si le module est installé"
! $(Module.installed $OLIX_MODULE_NAME) && critical "Le module '${OLIX_MODULE_NAME}' n'est pas installé"



###
# Suppression du fichier de l'auto-completion
##
Module.remove.completion $OLIX_MODULE_NAME
[[ $? -ne 0 ]] && critical "Impossible de supprimer le fichier de completion du module ${OLIX_MODULE_NAME}"


###
# Suppression du fichier de configuration
##
Module.remove.config $OLIX_MODULE_NAME
[[ $? -ne 0 ]] && critical "Impossible de supprimer le fichier de configuration du module ${OLIX_MODULE_NAME}"


###
# Suppression du dossier du module
##
Module.remove.path $OLIX_MODULE_NAME
[[ $? -ne 0 ]] && critical "Impossible de supprimer le module ${OLIX_MODULE_NAME}"


###
# FIN
##
echo -e "${CVERT}La suppression du module ${CVIOLET}$OLIX_MODULE_NAME${CVERT} s'est terminée avec succès${CVOID}"
