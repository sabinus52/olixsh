###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


# Rapport désactivé par défaut
OLIX_REPORT_FORMAT=false
OLIX_REPORT_FILENAME=""
OLIX_REPORT_EMAIL=""



###
# Initialise le rapport
# @param $1 : Type du rapport texte ou html
# @param $2 : Chemin du fichier du rapport
# @param $3 : Nom du fichier de rapport
# @param $4 : Email sur lequel sera envoyé le rapport
##
function report_initialize()
{
    logger_debug "report_initialize ($1, $2, $3, $4)"

    case $1 in
        HTML|html)  source lib/report.html.lib.sh;;
        TEXT|text)  source lib/report.text.lib.sh;;
        *)          logger_warning "Type de rapport non défini"
                    return;;
    esac

    # Test du dossier
    local DIR=$2
    if [[ ! -d $2 ]]; then
        logger_warning "Le dossier '$2' n'existe pas utilisation de /tmp"
        DIR="/tmp"
    fi

    OLIX_REPORT_FORMAT=$1
    OLIX_REPORT_FILENAME="$DIR/$3${OLIX_REPORT_EXTENSION}"
    OLIX_REPORT_EMAIL=$4

    echo > ${OLIX_REPORT_FILENAME}
    report_printHeader
}


###
# Finalise le rapport et l'envoi pas mail le cas échéant
# @param $1 : Sujet du mail
##
function report_terminate()
{
    logger_debug "report_terminate ($1)"

    report_printFooter

    if [[ ! -z ${OLIX_REPORT_EMAIL} ]]; then
        core_sendMail "${OLIX_REPORT_FORMAT}" "${OLIX_REPORT_EMAIL}" "${OLIX_REPORT_FILENAME}" "$1"
        [[ $? -ne 0 ]] && logger_warning "Impossible d'envoyer l'email à ${OLIX_REPORT_EMAIL}"
    fi
}


###
# Rapport d'erreur
# @param $1 : Message d'erreur
##
function report_error()
{
    logger_debug "report_error ($1)"

    [[ -n $1 ]] && report_print "$1" "color:red;"
    [[ -s ${OLIX_LOGGER_FILE_ERR} ]] && report_printFile "${OLIX_LOGGER_FILE_ERR}" "color:red;"
    report_terminate "${OLIX_REPORT_FORMAT}" "ERREUR"
    return 0
}


###
# Rapport d'avertissement
# @param $1 : Message d'avertissement
##
function report_warning()
{
    logger_debug "report_warning ($1)"

    [[ -n $1 ]] && report_print "$1" "color:red;"
    [[ -s ${OLIX_LOGGER_FILE_ERR} ]] && report_printFile "${OLIX_LOGGER_FILE_ERR}" "color:red;"
    return 0
}


function report_printHead1() { echo > /dev/null; }

function report_printHead2() { echo > /dev/null; }

function report_printLine() { echo > /dev/null; }

function report_print() { echo > /dev/null; }

function report_printMessageReturn() { echo > /dev/null; }

function report_printInfo() { echo > /dev/null; }

function report_printFile() { echo > /dev/null; }
