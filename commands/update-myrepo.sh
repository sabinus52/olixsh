###
# Mise à jour du dépot personnalisé
# ==============================================================================
# @package olixsh
# @command update
# @author Olivier <sabinus52@gmail.com>
##


###
# Chargement des utilitaires
##
load "utils/module.sh"


###
# Constantes
##
# Force l'activation des warnings
OLIX_OPTION_WARNINGS=true


info "Exécution de la mise à jour du fichier personnalisé des dépots des modules"


###
# Test si c'est le propriétaire
##
info "Test si c'est le propriétaire"
checkOlixshOwner
[[ $? -ne 0 ]] && critical "Seul l'utilisateur \"$(Core.owner)\" peut exécuter ce script"


###
# Vérification si il y a un dépot utilisateur
##
if [[ -z $OLIX_MODULE_REPOSITORY_URL ]]; then
    warning "Pas d'URL de dépot personnalisé configuré"
    return
fi

echo -e "${CBLANC}Mise à jour du fichier personnalisé des dépots des modules${CVOID}"
echo -e "${CBLANC}----------------------------------------------------------${CVOID}"


###
# Télécharge et installe
##
Module.install.myrepository
[[ $? -ne 0 ]] && critical "Impossible de télécharger le fichier personnalisé des dépots des modules"


###
# FIN
##
echo -e "${CVERT}La mise à jour du fichier personnalisé s'est terminée avec succès${CVOID}"
