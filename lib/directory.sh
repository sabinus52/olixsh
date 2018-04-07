###
# Gestion des propriétés des répertoires
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# @param : Nom du fichier
##



###
# Si le dossier existe
##
function Directory.exists()
{
    [[ -z $1 ]] && return 1
    [[ -d $1 ]] && return 0 || return 1
}


###
# Si le dossier est en lecture
##
function Directory.readable()
{
    [[ -z $1 ]] && return 1
    [[ -r $1 ]] && return 0 || return 1
}


###
# Si le dossier est en ecriture
##
function Directory.writable()
{
    [[ -z $1 ]] && return 1
    [[ -w $1 ]] && return 0 || return 1
}


###
# Propriétaire et groupe d'appartenance du fichier
##
function Directory.owner()
{
    Directory.exists $1 && echo $(stat -c %U $1)
}
alias Directory.user='Directory.owner'

function Directory.group()
{
    Directory.exists $1 && echo $(stat -c %G $1)
}
