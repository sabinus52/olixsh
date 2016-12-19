###
# Librairies du gestionnaire de log
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Vérifie si le daemon logger existe
##
function Logger.checkLogger()
{
    if [[ ! -x /usr/bin/logger ]]; then
        OLIX_LOGGER=false
    fi
}


###
# Sauvegarde les messages dans le syslog
# @param $1 : Niveau du log
# @param $2 : Message
##
function Logger.syslog()
{
    local LEVEL="$1"
    local MESSAGE="$2"
    if [[ "${OLIX_LOGGER}" == "true" ]]; then
        /usr/bin/logger -t "oliXsh[$$]" -p "${OLIX_LOGGER_FACILITY}.${LEVEL}" -- "${LEVEL} * ${MESSAGE}"  
    fi
    echo "${OLIX_SYSTEM_DATE} ${OLIX_SYSTEM_TIME} [${LEVEL}] ${MESSAGE}" >> ${OLIX_LOGGER_FILE}
}


###
# Log le message et l'affiche eventuellement
# @param $1 : Niveau de log (debug info warning err crit)
# @param $2 : Message
##
function Logger.log()
{
    local SWITCH
    local LEVEL=$1
    shift
    local MESSAGE="$@"

    # Affecte le niveau d'erreur par défaut
    if [[ "$LEVEL" != "debug" ]]\
    && [[ "$LEVEL" != "info" ]]\
    && [[ "$LEVEL" != "warning" ]]\
    && [[ "$LEVEL" != "err" ]]\
    && [[ "$LEVEL" != "crit" ]]; then
        LEVEL="info"
    fi
    
    # Determine s'il y aura affichage ou pas
    case "$LEVEL" in
        debug)   SWITCH=$OLIX_OPTION_VERBOSEDEBUG;;
        info)    SWITCH=$OLIX_OPTION_VERBOSE;;
        warning) SWITCH=$OLIX_OPTION_WARNINGS;;
        *)       SWITCH=true;;
    esac
    
    # Affiche le message sur la sortie standard
    if [[ $SWITCH == true ]]; then
        Logger.print "$LEVEL" "$MESSAGE"
    fi
    # Log dans un fichier
    Logger.syslog "$LEVEL" "$OLIX_LOGGER_BUFFER$MESSAGE"
    # Purge le buffer
    OLIX_LOGGER_BUFFER=""
}


function Logger.print()
{
    local LEVEL=$1
    shift
    local MESSAGE="$@"

    case "$LEVEL" in
        debug)      echo -e "${CGRIS}$MESSAGE${CVOID}" >&2;;
        info)       echo -e "${Ccyan}$MESSAGE${CVOID}" >&2;;
        warning)    echo -e "${Cjaune}$MESSAGE${CVOID}" >&2;;
        err)        echo -e "${Crouge}$MESSAGE${CVOID}" >&2;;
        crit)       echo -e "${CROUGE}$MESSAGE${CVOID}" >&2;;
    esac
}


###
# Mode DEBUG
##
function Logger.debug()
{
    if [[ "$OLIX_LOGGER_LEVEL" == "debug" ]]; then
        Logger.log "debug" "DEBUG: $@"
    fi
    return 0
}
alias debug='Logger.debug'


###
# Mode INFO
##
function Logger.info()
{
    if [[ "$OLIX_LOGGER_LEVEL" == "debug" ]]\
    || [[ "$OLIX_LOGGER_LEVEL" == "info" ]]; then
        Logger.log "info" "$@"
    fi
    return 0
}
alias info='Logger.info'


###
# Mode WARNING
##
function Logger.warning()
{
    if [[ "$OLIX_LOGGER_LEVEL" == "debug" ]]\
    || [[ "$OLIX_LOGGER_LEVEL" == "info" ]]\
    || [[ "$OLIX_LOGGER_LEVEL" == "warning" ]]; then
        Logger.log "warning" "WARNING: $@"
        Function.exists "Report.warning" && Report.warning "$@"
    fi
    return 0
}
alias warning='Logger.warning'


###
# Mode ERROR
# Tous les erreurs sont envoyés dans le syslog
##
function Logger.error()
{
    local ERRFILE
    if [[ -s $OLIX_LOGGER_FILE_ERR ]]; then
        ERRFILE=$(cat $OLIX_LOGGER_FILE_ERR)
        Logger.log "err" "ERROR: ${ERRFILE}"
        Function.exists "Report.error" && Report.error "${ERRFILE}"
    else
        Logger.log "err" "ERROR: $@"
        Function.exists "Report.error" && Report.error "$@"
    fi
    return 0
}
alias error='Logger.error'


###
# Mode CRITICAL
# Tous les erreurs sont envoyés dans le syslog
# plus arret du sript
##
function Logger.critical()
{
    local ERRFILE
    if [[ -s $OLIX_LOGGER_FILE_ERR ]]; then
        ERRFILE=$(cat $OLIX_LOGGER_FILE_ERR)
        Logger.log "crit" "CRITICAL: ${ERRFILE}"
        Function.exists "Report.error" && Report.error "${ERRFILE}"
    else
        Logger.log "crit" "CRITICAL: $@"
        Function.exists "Report.error" && Report.error "$@"
    fi
    die 1 "$@"
}
alias critical='Logger.critical'
