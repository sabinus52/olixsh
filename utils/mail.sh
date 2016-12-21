###
# Librairies de gestion de mail
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Envoi d'un mail
# @param $1 : Format html ou text
# @param $2 : Email
# @param $3 : Chemin du fichier contenant le contenu du mail
# @param $4 : Sujet du mail
##
function Mail.send()
{
    debug "Mail.send ($1, $2, $3, $4)"

    local SUBJECT SERVER
    #SERVER="${OLIX_CONF_SERVER_NAME}"
    #[[ -z ${SERVER} ]] && SERVER=${HOSTNAME}
    SERVER=$HOSTNAME
    SUBJECT="[$SERVER:$OLIX_MODULE_NAME] $4"

    if [[ "$1" == "html" || "$1" == "HTML" ]]; then
        mailx -s "$SUBJECT" -a "Content-type: text/html; charset=UTF-8" $2 < $3
    else
        mailx -s "$SUBJECT" $2 < $3
    fi
    return $?
}
