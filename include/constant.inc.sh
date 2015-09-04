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


###
# Couleurs
##
Cgris='\e[0;30m'
CGRIS='\e[1;30m'
Crouge='\e[0;31m'
CROUGE='\e[1;31m'
Cvert='\e[0;32m'
CVERT='\e[1;32m'
Cjaune='\e[0;33m'
CJAUNE='\e[1;33m'
Cbleu='\e[0;34m'
CBLEU='\e[1;34m'
Cviolet='\e[0;35m'
CVIOLET='\e[1;35m'
Ccyan='\e[0;36m'
CCYAN='\e[1;36m'
Cblanc='\e[0;37m'
CBLANC='\e[1;37m'
CVOID='\e[0;0m'
