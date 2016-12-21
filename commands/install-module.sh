###
# Installation d'un module oliXsh
# ==============================================================================
# @package olixsh
# @command install
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


info "Exécution de l'installation du module ${OLIX_MODULE_NAME}"


###
# Test si c'est le propriétaire
##
info "Test si c'est le propriétaire"
checkOlixshOwner
[[ $? -ne 0 ]] && critical "Seul l'utilisateur \"$(Core.owner)\" peut exécuter ce script"


echo -e "${CBLANC}Installation du module ${CVIOLET}$OLIX_MODULE_NAME${CVOID}"
echo -e "${CBLANC}--------------------------------------${CVOID}"



###
# Vérification du module
##
Module.install.check $OLIX_MODULE_NAME "install"


###
# Installation du module
##
Module.install $OLIX_MODULE_NAME


###
# FIN
##
echo -e "${CVERT}L'installation du module ${CVIOLET}$OLIX_MODULE_NAME${CVERT} s'est terminée avec succès${CVOID}"
