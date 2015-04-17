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
}



