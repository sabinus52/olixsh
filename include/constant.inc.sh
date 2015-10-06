###
# Détermination des variables globales et communes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Paramètres du coeur
##
# Nom du fichier de l'interpréteur
OLIX_CORE_SHELL_NAME="olixsh"
# Lien vers l'interpréteur olixsh
OLIX_CORE_SHELL_LINK="/usr/bin/olixsh"
# Dossier de configuration
OLIX_CORE_PATH_CONFIG="/etc/olixsh"


###
# Dossiers
##
# Emplacement des modules installés
OLIX_MODULE_DIR="modules"


###
# Commandes
##
OLIX_COMMAND_LIST="install update remove"


###
# Modules
##
# Emplacement du fichier contenant la liste des modules existants
OLIX_MODULE_REPOSITORY="conf/modules.lst"
# Emplacement du fichier contenant la liste des modules utilisateurs
OLIX_MODULE_REPOSITORY_USER="conf/mymodules.lst"
# Fichier de conf utilisé par le module
OLIX_MODULE_FILECONF=""


###
# Initialisation des paramètres par défaut des options
##
OLIX_OPTION_VERBOSEDEBUG=false
OLIX_OPTION_VERBOSE=false
OLIX_OPTION_WARNINGS=true
OLIX_OPTION_COLOR=true
OLIX_OPTION_HELP=false
OLIX_OPTION_LIST=false


###
# Jour et heure d'ecoute
##
OLIX_SYSTEM_TIME=$(date '+%X')
OLIX_SYSTEM_DATE=$(date '+%F')


###
# Liste des binaires requis
##
OLIX_BINARIES_REQUIRED="logger gzip tar wget"
