###
# Liste des constantes et paramètres de shell oliXsh
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
# Pointeur de temps de départ du script
OLIX_CORE_EXEC_START=$SECONDS


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
# Variable contenant une valeur de retour d'une fonction
##
OLIX_FUNCTION_RETURN=


###
# Paramètres par défaut du Logger
##
OLIX_LOGGER=false            # Si on enregistre le log dans un fichier syslog
OLIX_LOGGER_LEVEL="debug"    # Niveau de log
OLIX_LOGGER_FACILITY="user"  # Origine de l'erreur
OLIX_LOGGER_FILE="/tmp/olixsh.log" # Fichier de log principal
OLIX_LOGGER_BUFFER=""       # Buffer du log
OLIX_LOGGER_FILE_ERR=$(mktemp --dry-run /tmp/olix.XXXXXXXXXX.err) # Fichier de sortie d'erreur


###
# Paramètres par défaut des modules
##
# Emplacement des modules installés
OLIX_MODULE_PATH="$OLIX_ROOT/modules"
# Emplacement du fichier contenant la liste des modules existants
OLIX_MODULE_REPOSITORY="$OLIX_ROOT/conf/modules.lst"
# Url de dépôt
OLIX_MODULE_REPOSITORY_URL="https://raw.githubusercontent.com/sabinus52/olixsh/master/conf/modules.lst"
# Emplacement du fichier contenant la liste des modules utilisateurs
OLIX_MODULE_REPOSITORY_USER="$OLIX_CORE_PATH_CONFIG/mymodules.lst"
# Fichier de conf utilisé par le module
OLIX_MODULE_FILECONF=


###
# Jour et heure d'ecoute
##
OLIX_SYSTEM_TIME=$(date '+%X')
OLIX_SYSTEM_DATE=$(date '+%F')
