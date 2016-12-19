###
# Librairies pour la gestion de rapport vide
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies necessaires
##
load "utils/filesystem.sh"


# Rapport désactivé par défaut
OLIX_REPORT_FORMAT=false
OLIX_REPORT_PREFIX=
OLIX_REPORT_FILENAME=
OLIX_REPORT_TTL=10
OLIX_REPORT_EMAIL=



###
# Initialise le rapport
# @param $1 : Type du rapport texte ou html
# @param $2 : Chemin du fichier du rapport
# @param $3 : Prefix du fichier de rapport
# @param $4 : Rétention des rapports
# @param $5 : Email sur lequel sera envoyé le rapport
##
function Report.initialize()
{
    debug "Report.initialize ($1, $2, $3, $4, $5)"
    local DIRECTORY EXTENSION

    case $(String.lower $1) in
        html)   load "utils/report/report.html.sh"
                EXTENSION=".html";;
        text)   load "utils/report/report.text.sh"
                EXTENSION=".txt";;
        *)      warning "Type de rapport non défini"
                return;;
    esac

    # Test du dossier
    local DIRECTORY=$2
    if [[ ! -d $DIRECTORY ]]; then
        warning "Le dossier '${DIRECTORY}' n'existe pas, utilisation de /tmp"
        DIRECTORY="/tmp"
    fi

    OLIX_REPORT_FORMAT=$1
    OLIX_REPORT_PREFIX=$3
    OLIX_REPORT_FILENAME="$DIRECTORY/$OLIX_REPORT_PREFIX-$OLIX_SYSTEM_DATE-$(date '+%H%M%S')$EXTENSION"
    [[ -n $4 ]] && OLIX_REPORT_TTL=$4
    OLIX_REPORT_EMAIL=$5

    info "Rapport dans le fichier : ${OLIX_REPORT_FILENAME}"
    echo > $OLIX_REPORT_FILENAME
    Report.print.header
}


###
# Finalise le rapport et l'envoi par mail le cas échéant
# @param $1 : Sujet du mail
##
function Report.terminate()
{
    debug "Report.terminate ($1)"

    [[ -z $OLIX_REPORT_FILENAME ]] && return

    Report.print.footer

    # Purge des anciens rapports
    info "Purge des logs de rapport"
    Filesystem.purge.standard "$(dirname $OLIX_REPORT_FILENAME)" "$OLIX_REPORT_PREFIX" "$OLIX_REPORT_TTL"

    # Envoi mail
    if [[ ! -z $OLIX_REPORT_EMAIL ]]; then
        info "Envoi du mail à ${OLIX_REPORT_EMAIL}"
        Mail.send "$OLIX_REPORT_FORMAT" "$OLIX_REPORT_EMAIL" "$OLIX_REPORT_FILENAME" "$1"
        [[ $? -ne 0 ]] && warning "Impossible d'envoyer l'email à ${OLIX_REPORT_EMAIL}"
    fi
}


###
# Rapport d'erreur
# @param $1 : Message d'erreur
##
function Report.error()
{
    debug "Report.error ($1)"

    [[ -n $1 ]] && Report.print.echo "$1" "color:red;"
    [[ -s $OLIX_LOGGER_FILE_ERR ]] && Report.print.file "$OLIX_LOGGER_FILE_ERR" "color:red;"
    Report.terminate "ERREUR"
    return 0
}


###
# Rapport d'avertissement
# @param $1 : Message d'avertissement
##
function Report.warning()
{
    debug "Report.warning ($1)"

    [[ -n $1 ]] && Report.print.echo "$1" "color:red;"
    [[ -s $OLIX_LOGGER_FILE_ERR ]] && Report.print.file "$OLIX_LOGGER_FILE_ERR" "color:red;"
    return 0
}



function Report.print.header() { echo > /dev/null; }

function Report.print.footer() { echo > /dev/null; }

function Report.print.head1() { echo > /dev/null; }

function Report.print.head2() { echo > /dev/null; }

function Report.print.line() { echo > /dev/null; }

function Report.print.echo() { echo > /dev/null; }

function Report.print.result() { echo > /dev/null; }

function Report.print.value() { echo > /dev/null; }

function Report.print.file() { echo > /dev/null; }
