###
# Librairies des sorties d'affichage
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Retourne le padding d'un texte avec une taille fixe complétée par des caratères
# @param $1 : Texte de début pour le clacul du padding
# @param $2 : Taille de la chaine
# @param $3 : Caractère à compléter
##
function stdout_strpad()
{
    logger_debug "stdout_strpad ($1, $2, $3)"
    local PAD=$(printf '%0.1s' "$3"{1..60})
    printf '%*.*s' 0 $(($2 - ${#1} )) "${PAD}"
}


###
# Affiche la version
##
function stdout_printVersion()
{
    logger_debug "stdout_printVersion ()"
    local VERSION
    VERSION="Version ${CVERT}${OLIX_VERSION}${CVOID}"
    echo -e "${CVIOLET}oliXsh${CVOID} ${VERSION}, for Linux"
    echo -e "Copyright (c) 2013, $(date '+%Y') Olivier (Sabinus52). All rights reserved."
    echo -e "Link GitHub : ${Ccyan}https://github.com/sabinus52/olixsh${CVOID}"
}


###
# Affiche l'usage de oliXsh
##
function stdout_printUsage()
{
    logger_debug "stdout_printUsage ()"
    stdout_printVersion
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${Ccyan}[OPTIONS] ${CJAUNE}COMMAND|MODULE ${Cjaune}[PARAMETER]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC}  --help|-h          ${CVOID} : "; echo "Affiche cet écran d'aide."
    echo -en "${CBLANC}  --version          ${CVOID} : "; echo "Affiche le numéro de version."
    echo -en "${CBLANC}  --verbose|-v       ${CVOID} : "; echo "Mode verbeux."
    echo -en "${CBLANC}  --debug|-d         ${CVOID} : "; echo "Mode debug très verbeux."
    echo -en "${CBLANC}  --no-warnings      ${CVOID} : "; echo "Désactive les messages d'alerte."
    echo
    echo -e "${CJAUNE}COMMANDS${CVOID}"
    command_printList
    echo
    echo -e "${CJAUNE}MODULES${CVOID}"
    module_printListInstalled
}


###
# Affiche l'erreur de module non trouvé
##
function stdout_printNoCommandNoModule()
{
    logger_debug "stdout_printNoCommandNoModule ($1)"
    logger_warning "La commande ou le module \"$1\" n'existe pas"
}


###
# Affiche un message d'en-tête de niveau 1
# @param $1     : Message
# @param $2..$9 : Valeurs à inclure dans le message
##
function stdout_printHead1()
{
    local MSG=$1
    shift
    logger_debug "stdout_printHead1 ($MSG, $*)"
    echo
    echo -e "${CVIOLET}$(printf "$MSG" "${CCYAN}$1${CVIOLET}" "${CCYAN}$2${CVIOLET}" "${CCYAN}$3${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}===============================================================================${CVOID}"
    type "report_printHead1" >/dev/null 2>&1 && report_printHead1 "${MSG}" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function stdout_printHead2()
{
    logger_debug "stdout_printHead2 ($1, $2)"
    echo
    echo -e "${CVIOLET}$(printf "$1" "${CCYAN}$2${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    type "report_printHead2" >/dev/null 2>&1 && report_printHead2 "$1" "$2"
}


###
# Afficher une ligne
##
function stdout_printLine()
{
    logger_debug "stdout_printLine ()"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    type "report_printLine" >/dev/null 2>&1 && report_printLine
}


###
# Affiche un message standard
# @param $1 : Message à afficher
# @param $2 : Couleur du message
##
function stdout_print()
{
    logger_debug "stdout_print ($1, $2)"
    echo -e "$2$1${CVOID}"
    type "report_print" >/dev/null 2>&1 && report_print "$1"
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
# @param $4 : Temps d'execution
##
function stdout_printMessageReturn()
{
    logger_debug "stdout_printMessageReturn ($1, $2, $3, $4)"
    echo -en $2; stdout_strpad "$2" 64 " "; echo -n " :"
    if [[ $1 -ne 0 ]]; then
        echo -e " ${CROUGE}ERROR${CVOID}"
    elif [[ -z $3 ]]; then
        echo -en " ${CVERT}OK${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    else
        echo -en " ${CVERT}$3${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    fi
    type "report_printMessageReturn" >/dev/null 2>&1 && report_printMessageReturn "$1" "$2" "$3" "$4"
    return $1
}


###
# Affiche un message d'information simple
# @param $1 : Message
# @param $2 : Valeur
##
function stdout_printInfo()
{
    logger_debug "stdout_printInfo ($1, $2)"
    echo -en $1; stdout_strpad "$1" 64 " "; echo -n " :"
    echo -e " ${CBLEU}$2${CVOID}"
    type "report_printInfo" >/dev/null 2>&1 && report_printInfo "$1" "$2"
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
##
function stdout_printFile()
{
    logger_debug "stdout_printFile ($1)"
    cat $1
    type "report_printFile" >/dev/null 2>&1 && report_printFile "$1"
}
