###
# Fonctions des sorties d'affichage et d'usage
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Affiche la version
##
function Print.version()
{
    local VERSION
    VERSION="Version ${CVERT}$OLIX_VERSION${CVOID}"
    echo -e "${CVIOLET}oliXsh${CVOID} $VERSION, for Linux"
    echo -e "Copyright (c) 2013, $(date '+%Y') Olivier (Sabinus52). All rights reserved."
    echo -e "Link GitHub : ${Ccyan}https://github.com/sabinus52/olixsh${CVOID}"
}


###
# Affiche l'usage de oliXsh
##
function Print.usage()
{
    Print.version
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${Ccyan}[OPTIONS] ${CJAUNE}COMMAND|MODULE ${Cjaune}[PARAMETER]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC}  --help|-h          ${CVOID} : "; echo "Affiche cet écran d'aide."
    echo -en "${CBLANC}  --version          ${CVOID} : "; echo "Affiche le numéro de version."
    echo -en "${CBLANC}  --verbose|-v       ${CVOID} : "; echo "Mode verbeux."
    echo -en "${CBLANC}  --debug|-d         ${CVOID} : "; echo "Mode debug très verbeux."
    echo -en "${CBLANC}  --no-warnings      ${CVOID} : "; echo "Désactive les messages d'alerte."
    echo -en "${CBLANC}  --no-color         ${CVOID} : "; echo "Désactive les messages en couleur."
    echo
    echo -e "${CJAUNE}COMMANDS${CVOID}"
    Print.commands
    echo
    echo -e "${CJAUNE}MODULES${CVOID}"
    local I
    while read I; do
        Print.usage.item $I "$(Module.label $I)"
    done < <(Module.all.installed)
}


###
# Affiche le menu des commands
##
function Print.commands()
{
    echo -e "${Cjaune} install ${CVOID}     : Installation des modules oliXsh"
    echo -e "${Cjaune} update  ${CVOID}     : Mise à jour des modules oliXsh "
    echo -e "${Cjaune} remove  ${CVOID}     : Suppression d'un module oliXsh "
}


###
# Affiche un item d'usage 
##
function Print.usage.item()
{
    local PAD=10
    [[ -n $3 ]] && PAD=$3
    echo -en "${Cjaune} $1 ${CVOID} "
    String.pad "$1" $PAD " "
    echo " : $2"
}


###
# Affiche un message d'en-tête de niveau 1
# @param $1     : Message
# @param $2..$9 : Valeurs à inclure dans le message
##
function Print.head1()
{
    local MSG=$1
    shift
    debug "Print.head1 ($MSG, $*)"
    echo
    echo -e "${CVIOLET}$(printf "$MSG" "${CCYAN}$1${CVIOLET}" "${CCYAN}$2${CVIOLET}" "${CCYAN}$3${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}===============================================================================${CVOID}"
    Function.exists "Report.print.head1" && Report.print.head1 "${MSG}" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function Print.head2()
{
    debug "Print.head2 ($1, $2)"
    echo
    echo -e "${CVIOLET}$(printf "$1" "${CCYAN}$2${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    Function.exists "Report.print.head2" && Report.print.head2 "$1" "$2"
}


###
# Afficher une ligne
##
function Print.line()
{
    debug "Print.line ()"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    Function.exists "Report.print.line" && Report.print.line
}


###
# Affiche un message standard
# @param $1 : Message à afficher
# @param $2 : Couleur du message
##
function Print.echo()
{
    debug "Print.echo ($1, $2)"
    echo -e "$2$1${CVOID}"
    Function.exists "Report.print.echo" && Report.print.echo "$1"
}


###
# Affiche un message d'information simple
# @param $1 : Message
# @param $2 : Valeur
##
function Print.value()
{
    debug "Print.value ($1, $2)"
    echo -en $1; String.pad "$1" 64 " "; echo -n " :"
    echo -e " ${CBLEU}$2${CVOID}"
    Function.exists "Report.print.value" && Report.print.value "$1" "$2"
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
# @param $4 : Temps d'execution
##
function Print.result()
{
    debug "Print.result ($1, $2, $3, $4)"
    echo -en $2; String.pad "$2" 64 " "; echo -n " :"
    if [[ $1 -ne 0 ]]; then
        echo -e " ${CROUGE}ERROR${CVOID}"
    elif [[ -z $3 ]]; then
        echo -en " ${CVERT}OK${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    else
        echo -en " ${CVERT}$3${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    fi
    Function.exists "Report.print.result" && Report.print.result "$1" "$2" "$3" "$4"
    return $1
}


###
# Affiche le message d'information de retour d'un check
# @param $1 : Valeur de retour
# @param $2 : Message
##
function Print.check()
{
    debug "Print.check ($1, $2)"
    echo -en $2; String.pad "$2" 64 " "; echo -n " :"
    if [[ $1 -gt 100 ]]; then
        echo -e " ${CROUGE}ERROR${CVOID}"
    elif [[ $1 -eq 0 ]]; then
        echo -e " ${CVERT}OK${CVOID}"
    else
        echo -e " ${CJAUNE}WARNING${CVOID}"
    fi
    Function.exists "Report.print.result" && Report.print.result "$1" "$2"
    return $1
}


###
# Affiche une liste d'élément
# @param $1 : Message à afficher
##
function Print.list()
{
    debug "Print.list ($1, $2)"
    local I
    for I in $1; do
        echo $I
    done
    Function.exists "Report.print.list" && Report.print.list "$1" $2
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
##
function Print.file()
{
    debug "Print.file ($1)"
    cat $1
    Function.exists "Report.print.file" && Report.print.file "$1"
}
