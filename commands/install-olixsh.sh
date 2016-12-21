###
# Installation de oliXsh sur le système
# ==============================================================================
# @package olixsh
# @command install
# @author Olivier <sabinus52@gmail.com>
##


###
# Chargement des utilitaires
## 
load "utils/fileconfig.sh"


###
# Constantes
##
OLIX_COMMAND_COMPLETION="/etc/bash_completion.d/olixsh.sh"
OLIX_BINARIES_REQUIRED="logger gzip tar wget"

# Force l'activation des warnings
OLIX_OPTION_WARNINGS=true
ISERROR=false


info "Exécution de l'installation d'oliXsh"


###
# Test si ROOT
##
info "Test si root"
System.logged.isRoot || logger_critical "Seulement root peut executer l'installation d'oliXsh"


echo -e "${CBLANC}Installation de oliXsh dans le système${CVOID}"
echo -e "${CBLANC}--------------------------------------${CVOID}"


###
# Vérification des binaires requis
##
info "Vérification des binaires requis"
for I in $OLIX_BINARIES_REQUIRED; do
    debug "which $I"
    if ! System.binary.exists $I; then
        warning "Le binaire \"$I\" n'est pas présent"
        ISERROR=true
    fi
done
[[ $ISERROR == true ]] && echo && warning "ATTENTION !!! Ces binaires sont requis pour le bon fonctionnement de oliXsh" && echo
unset I



###
# Effectue un lien vers l'interpréteur olixsh depuis /bin/olixsh pour l'installation
##
info "Création du lien ${OLIX_CORE_SHELL_LINK}"
debug "ln -sf $OLIX_ROOT/${OLIX_CORE_SHELL_NAME} ${OLIX_CORE_SHELL_LINK}"
ln -sf $OLIX_ROOT/$OLIX_CORE_SHELL_NAME $OLIX_CORE_SHELL_LINK > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && critical "Impossible de créer le lien ${OLIX_CORE_SHELL_LINK}"



###
# Créer le dossier où seront les fichiers de configuration par défaut /etc/olixsh
##
info "Création du dossier de configuration ${OLIX_CORE_PATH_CONFIG}"
if [[ ! -d $OLIX_CORE_PATH_CONFIG ]]; then
    debug "mkdir -p ${OLIX_CORE_PATH_CONFIG}"
    mkdir -p $OLIX_CORE_PATH_CONFIG > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && critical "Impossible de créer le dossier de configuration ${OLIX_CORE_PATH_CONFIG}"
else
    debug "/etc/olixsh déjà créé"
fi



###
# Copie du template du fichier de conf olixsh.conf
##
info "Copie du fichier de configuration olixsh.conf dans /etc"
if [[ ! -f  $(Config.fileName "olixsh") ]]; then
    Fileconfig.install "olixsh"
    [[ $? -ne 0 ]] && critical "Impossible de copier le fichier de configuration 'olixsh.conf' dans ${OLIX_CORE_PATH_CONFIG}"
else
    debug "$(Config.fileName "oliXsh") déjà présent"
fi



###
# Créer le fichier de la completion
##
info "Création du fichier ${OLIX_COMMAND_COMPLETION}"
if [[ -d $(dirname $OLIX_COMMAND_COMPLETION) ]]; then

    debug "cat > ${OLIX_COMMAND_COMPLETION}"
    cat > $OLIX_COMMAND_COMPLETION <<EOT
OLIX_ROOT_COMP=$OLIX_ROOT
if [[ -r $OLIX_ROOT/completion/olixmain ]]; then
    source $OLIX_ROOT/completion/olixmain
    complete -F _olixsh olixsh
fi
EOT
    [[ $? -ne 0 ]] && warning "Impossible de créer le fichier ${OLIX_COMMAND_COMPLETION}" && warning "La completion ne sera pas active !"

else
    warning "Apparement aucune completion n'a été trouvée !"
fi



###
# FIN
##
echo -e "${CVERT}L'installation oliXsh s'est terminée avec succès${CVOID}"
