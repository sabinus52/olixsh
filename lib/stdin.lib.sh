###
# Librairies des entrées
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Lecture d'une saisie standard'
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
##
function stdin_read()
{
    local RESPONSE
    OLIX_STDIN_RETURN=$2
    echo -e $1
    echo -en "[${CBLANC}${OLIX_STDIN_RETURN}${CVOID}] ? "
    read RESPONSE
    [[ ! -z ${RESPONSE} ]] && OLIX_STDIN_RETURN=${RESPONSE}
}


###
# Lecture de la saisie d'un fichier
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
##
function stdin_readFile()
{
    local RESPONSE
    OLIX_STDIN_RETURN=$2
    while true; do
        echo -e $1
        echo -en "[${CBLANC}${OLIX_STDIN_RETURN}${CVOID}] ? "
        read -e -p "" RESPONSE
        [[ ! -z ${RESPONSE} ]] && OLIX_STDIN_RETURN=${RESPONSE}
        [[ -f ${OLIX_STDIN_RETURN} && -r ${OLIX_STDIN_RETURN} ]] && break
        logger_warning "Le fichier '${OLIX_STDIN_RETURN}' est absent"
    done
}


###
# Lecture de la saisie d'un répertoire
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
##
function stdin_readDirectory()
{
    local RESPONSE
    OLIX_STDIN_RETURN=$2
    while true; do
        echo -e $1
        echo -en "[${CBLANC}${OLIX_STDIN_RETURN}${CVOID}] ? "
        read -e -p "" RESPONSE
        [[ ! -z ${RESPONSE} ]] && OLIX_STDIN_RETURN=${RESPONSE}
        [[ -d ${OLIX_STDIN_RETURN} && -w ${OLIX_STDIN_RETURN} ]] && break
        logger_warning "Le répertoire '${OLIX_STDIN_RETURN}' est inaccessible"
    done
}


###
# Demande de confirmation par oui ou non
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut (true|false)
##
function stdin_readYesOrNo()
{
    local RESPONSE
    OLIX_STDIN_RETURN=$2
    while true; do
        echo -en $1
        if [[ ${OLIX_STDIN_RETURN} == true ]]; then
            echo -en " [${CBLANC}O/n${CVOID}] ? "
        else
            echo -en " [${CBLANC}o/N${CVOID}] ? "
        fi
        read RESPONSE
        [[ ! -z ${RESPONSE} ]] && OLIX_STDIN_RETURN=${RESPONSE}
        case ${OLIX_STDIN_RETURN} in
            y|yes|Y|o|O|oui|true)
                OLIX_STDIN_RETURN=true
                break
                ;;
            n|N|no|non|false)
                OLIX_STDIN_RETURN=false
                break
                ;;
        esac
    done
}


###
# Lecture d'un mot de passe
# @param $1 : Message à afficher
##
function stdin_readPassword()
{
    local RESPONSE
    OLIX_STDIN_RETURN=
    echo -en "$1 ? "
    read -s RESPONSE
    echo
    OLIX_STDIN_RETURN=${RESPONSE}
}


###
# Saisie d'un mot de passe et de sa confirmation
# @param $1 : Message à afficher
##
function stdin_readDoublePassword()
{
    local RESPONSE1 RESPONSE2
    OLIX_STDIN_RETURN=
    while true; do
        echo -e "$1"
        echo -n "Mot de passe ? "
        read -s RESPONSE1
        echo
        echo -n "Confirme mot de passe ? "
        read -s RESPONSE2
        echo
        [[ "${RESPONSE1}" == "${RESPONSE2}" ]] && break
    done
    OLIX_STDIN_RETURN=${RESPONSE1}
}


###
# Lecture d'un choix de sélection
# @param $1 : Message à afficher
# @param $2 : Liste de choix
# @param $3 : Valeur par défaut
# @return string OLIX_STDIN_RETURN
##
function stdin_readSelect()
{
    logger_debug "stdin_readSelect ($1, $2, $3)"

    OLIX_STDIN_RETURN=$3
    while true; do
        echo -e $1
        echo -e "Choix : $2"
        echo -en "[${CBLANC}${OLIX_STDIN_RETURN}${CVOID}] ? "
        read RESPONSE
        [[ ! -z ${RESPONSE} ]] && OLIX_STDIN_RETURN=${RESPONSE}
        core_contains "${OLIX_STDIN_RETURN}" "$2" && break
    done
}


###
# Demande des infos d'un connexion distante
# @param $1 : Host du serveur
# @param $2 : Port du serveur
# @param $3 : User du serveur
# @return OLIX_STDIN_SERVER_HOST : Host du serveur
# @return OLIX_STDIN_SERVER_PORT : Port du serveur
# @return OLIX_STDIN_SERVER_USER : User du serveur
##
function stdin_readConnexionServer()
{
    logger_debug "stdin_readConnexionServer ($1, $2, $3)"
    OLIX_STDIN_RETURN_HOST=$1
    OLIX_STDIN_RETURN_PORT=$2
    OLIX_STDIN_RETURN_USER=$3
    
    # Verifie si un cache existe pour éviter de resaisir
    local FCACHE="/tmp/cache.$USER"
    [[ -r ${FCACHE} ]] && source ${FCACHE} && logger_debug $(cat ${FCACHE})
    echo > ${FCACHE}

    stdin_read "Host du serveur" ${OLIX_STDIN_RETURN_HOST}
    OLIX_STDIN_RETURN_HOST=${OLIX_STDIN_RETURN}
    echo "OLIX_STDIN_RETURN_HOST=${OLIX_STDIN_RETURN_HOST}" >> ${FCACHE}
    stdin_read "Port du serveur" ${OLIX_STDIN_RETURN_PORT}
    OLIX_STDIN_RETURN_PORT=${OLIX_STDIN_RETURN}
    echo "OLIX_STDIN_RETURN_PORT=${OLIX_STDIN_RETURN_PORT}" >> ${FCACHE}
    stdin_read "Utilisateur de connexion" ${OLIX_STDIN_RETURN_USER}
    OLIX_STDIN_RETURN_USER=${OLIX_STDIN_RETURN}
    echo "OLIX_STDIN_RETURN_USER=${OLIX_STDIN_RETURN_USER}" >> ${FCACHE}
}
