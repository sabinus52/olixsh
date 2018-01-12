###
# Librairies pour la gestion de rapport au format TEXT
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# En tête du rapport
##
Report.print.header()
{
    debug "Report.print.header ()"
    echo >> $OLIX_REPORT_FILENAME
}


###
# Pied de page du rapport
##
Report.print.footer()
{
    debug "Report.print.footer ()"
    echo >> $OLIX_REPORT_FILENAME
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1     : Message
# @param $2..$9 : Valeur à inclure dans le message
##
function Report.print.head1()
{
    debug "Report.print.head1 ($1, $2, $3, $4, $5)"
    echo >> $OLIX_REPORT_FILENAME
    echo " $(printf "$1" "$2" "$3" "$4")" >> $OLIX_REPORT_FILENAME
    echo "===============================================================================" >> $OLIX_REPORT_FILENAME
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function Report.print.head2()
{
    debug "Report.print.head2 ($1, $2)"
    echo >> $OLIX_REPORT_FILENAME
    echo " $(printf "$1" "$2")" >> $OLIX_REPORT_FILENAME
    echo "-------------------------------------------------------------------------------" >> $OLIX_REPORT_FILENAME
}


###
# Afficher une ligne
##
function Report.print.line()
{
    debug "Report.print.line ()"
    echo "-------------------------------------------------------------------------------" >> $OLIX_REPORT_FILENAME
}


###
# Affiche un message standard
# @param $1 : Message à afficher
##
function Report.print.echo()
{
    debug "Report.print.echo ($1)"
    echo $1 >> $OLIX_REPORT_FILENAME
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
# @param $4 : Temps d'execution
##
function Report.print.result()
{
    debug "Report.print.result ($1, $2, $3, $4)"
    echo -en $2 >> $OLIX_REPORT_FILENAME; String.pad "$2" 64 " " >> $OLIX_REPORT_FILENAME; echo -n " :" >> $OLIX_REPORT_FILENAME
    if [[ $1 -ne 0 ]]; then
        echo " ERROR" >> $OLIX_REPORT_FILENAME
    elif [[ -z $3 ]]; then
        echo -n " OK" >> $OLIX_REPORT_FILENAME
        [[ ! -z $4 ]] && echo " ($4s)" >> $OLIX_REPORT_FILENAME || echo  >> $OLIX_REPORT_FILENAME
    else
        echo -n " $3" >> $OLIX_REPORT_FILENAME
        [[ ! -z $4 ]] && echo " ($4s)" >> $OLIX_REPORT_FILENAME || echo  >> $OLIX_REPORT_FILENAME
    fi
    return $1
}


###
# Affiche un message d'information simple
# @param $1 : Message
# @param $2 : Valeur
##
function Report.print.value()
{
    debug "Report.print.value ($1, $2)"
    echo -en $1 >> $OLIX_REPORT_FILENAME; String.pad "$1" 64 " " >> $OLIX_REPORT_FILENAME; echo -n " :" >> $OLIX_REPORT_FILENAME
    echo " $2" >> $OLIX_REPORT_FILENAME
}


###
# Affiche une liste d'élément
# @param $1 : Message à afficher
##
function Report.print.list()
{
    debug "Report.print.list ($1)"
    local I
    for I in $1; do
        echo $I >> $OLIX_REPORT_FILENAME
    done
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
##
function Report.print.file()
{
    debug "Report.print.file ($1)"
    cat $1 >> $OLIX_REPORT_FILENAME
}
