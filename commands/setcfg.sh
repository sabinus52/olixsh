###
# Modification d'une valeur d'un paramètre dans le fichier de configuration d'un module
# ==============================================================================
# @package olixsh
# @command setcfg
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies necessaires
##
load "utils/fileconfig.sh"


###
# Constantes
##
# Nom du module
OLIX_MODULE_NAME=$1
# Paramètre
OLIX_MODULE_PARAM_NAME=$2
# Valeur du paramètre
OLIX_MODULE_PARAM_VALUE=$3



###
# Test si ROOT
##
info "Test si root"
System.logged.isRoot || critical "Seulement root peut executer cette opération"


###
# Vérification des paramètres
##
if ! Module.installed $OLIX_MODULE_NAME; then
    command_usage_setcfg
    echo
    error "Le module ${OLIX_MODULE_NAME} est inéxistant ou non installé"
    return
fi
if [[ -z $OLIX_MODULE_PARAM_NAME ]]; then
    command_usage_setcfg $OLIX_MODULE_NAME
    echo
    error "Le nom du paramètre à modifier est manquant"
    return
fi


info "Modification du paramètre '${OLIX_MODULE_PARAM_NAME}' dans le module ${OLIX_MODULE_NAME}"


###
# Vérification
##
# Vérifie si le fichier de conf est copié dans /etc/olixsh
if ! $(Config.exists $OLIX_MODULE_NAME); then
    # Dans ce cas installe le fichier de conf dans /etc/olixsh
    Fileconfig.install $OLIX_MODULE_NAME
    [[ $? -ne 0 ]] && critical "Impossible de déployer le fichier de configuration du module ${OLIX_MODULE_NAME}"
fi


###
# Récupération du nom réel et du type du paramètre puis vérification qu'il existe
##
OLIX_MODULE_PARAM_REALNAME=$(Config.param.system $OLIX_MODULE_NAME $OLIX_MODULE_PARAM_NAME)
# Vérification
if [[ -z $OLIX_MODULE_PARAM_REALNAME ]]; then
    command_usage_setcfg $OLIX_MODULE_NAME
    echo
    error "Le nom du paramètre '${OLIX_MODULE_PARAM_NAME}' à modifier est inconnu"
    return
fi



###
# Modification du paramètre
##
Fileconfig.param.set "$OLIX_MODULE_NAME" "$OLIX_MODULE_PARAM_NAME" "$OLIX_MODULE_PARAM_VALUE"
RET=$?
OLIX_MODULE_PARAM_VALUE=$OLIX_FUNCTION_RETURN
[[ $RET -eq 104 ]] && critical "Valeur '${OLIX_MODULE_PARAM_NAME}=${OLIX_MODULE_PARAM_VALUE}' non admise"
[[ $RET -eq 103 ]] && critical "Paramètre ${OLIX_MODULE_PARAM_REALNAME} non trouvé"
[[ $RET -eq 102 ]] && critical "Impossible de modifier le fichier de configuration en lecture seule"
[[ $RET -eq 101 ]] && critical "Le fichier de configuration à modifier est absent"
[[ $RET -ne 0 ]] && critical


###
# FIN
##
echo -e "${CVERT}Configuration ${CCYAN}${OLIX_MODULE_PARAM_NAME}=${Ccyan}${OLIX_MODULE_PARAM_VALUE}${CVERT} effectuée avec succès${CVOID}"
