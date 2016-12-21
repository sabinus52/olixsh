###
# Librairies des entrées
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Lecture d'une saisie standard
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
##
function Read.string()
{
    local RESPONSE
    OLIX_FUNCTION_RETURN=$2
    [[ -n $1 ]] && echo -e $1
    echo -en "[${CBLANC}$OLIX_FUNCTION_RETURN${CVOID}] ? "
    read RESPONSE
    [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
}
alias 'Read=Read.string'


###
# Lecture d'un entier
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
##
function Read.digit()
{
    local RESPONSE
    OLIX_FUNCTION_RETURN=$2
    while true; do
        [[ -n $1 ]] && echo -e $1
        echo -en "[${CBLANC}$OLIX_FUNCTION_RETURN${CVOID}] ? "
        read RESPONSE
        [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
        String.digit "$OLIX_FUNCTION_RETURN" && break
    done
}


###
# Demande de confirmation par oui ou non
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut (true|false)
##
function Read.confirm()
{
    local RESPONSE
    OLIX_FUNCTION_RETURN=$2
    while true; do
        [[ -n $1 ]] && echo -en $1
        if [[ $OLIX_FUNCTION_RETURN == true ]]; then
            echo -en " [${CBLANC}O/n${CVOID}] ? "
        else
            echo -en " [${CBLANC}o/N${CVOID}] ? "
        fi
        read RESPONSE
        [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
        case $OLIX_FUNCTION_RETURN in
            y|yes|Y|o|O|oui|true)
                OLIX_FUNCTION_RETURN=true
                break
                ;;
            n|N|no|non|false)
                OLIX_FUNCTION_RETURN=false
                break
                ;;
        esac
    done
}


###
# Lecture d'un mot de passe
# @param $1 : Message à afficher
##
function Read.password()
{
    local RESPONSE
    OLIX_FUNCTION_RETURN=
    [[ -n $1 ]] && echo -en "$1 ? "
    read -s RESPONSE
    echo
    OLIX_FUNCTION_RETURN=$RESPONSE
}


###
# Saisie d'un mot de passe et de sa confirmation
# @param $1 : Message à afficher
##
function Read.passwordx2()
{
    local RESPONSE1 RESPONSE2
    OLIX_FUNCTION_RETURN=
    while true; do
        [[ -n $1 ]] && echo -e "$1"
        echo -n "Mot de passe ? "
        read -s RESPONSE1
        echo
        echo -n "Confirme mot de passe ? "
        read -s RESPONSE2
        echo
        [[ "$RESPONSE1" == "$RESPONSE2" ]] && break
    done
    OLIX_FUNCTION_RETURN=$RESPONSE1
}


###
# Lecture de la saisie d'un fichier
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
# @param $3 : Si test fichier exist
##
function Read.file()
{
    local RESPONSE CHECK
    OLIX_FUNCTION_RETURN=$2
    [[ $3 == false ]] && CHECK=false
    while true; do
        [[ -n $1 ]] && echo -e $1
        echo -en "[${CBLANC}$OLIX_FUNCTION_RETURN${CVOID}] ? "
        read -e -p "" RESPONSE
        [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
        [[ $CHECK == false ]] && break;
        [[ -f $OLIX_FUNCTION_RETURN && -r $OLIX_FUNCTION_RETURN ]] && break
        warning "Le fichier '${OLIX_FUNCTION_RETURN}' est absent"
    done
}


###
# Lecture de la saisie d'un répertoire
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
# @param $3 : Si test dossier exist
##
function Read.directory()
{
    local RESPONSE CHECK
    OLIX_FUNCTION_RETURN=$2
    [[ $3 == false ]] && CHECK=false
    while true; do
        [[ -n $1 ]] && echo -e $1
        echo -en "[${CBLANC}$OLIX_FUNCTION_RETURN${CVOID}] ? "
        read -e -p "" RESPONSE
        [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
        [[ $CHECK == false ]] && break;
        [[ -d $OLIX_FUNCTION_RETURN ]] && break
        warning "Le répertoire '${OLIX_FUNCTION_RETURN}' est inaccessible"
    done
}


###
# Lecture d'un choix de sélection
# @param $1 : Message à afficher
# @param $2 : Valeur par défaut
# @param $3 : Liste de choix
##
function Read.choices()
{
    local RESPONSE
    OLIX_FUNCTION_RETURN=$2
    while true; do
        [[ -n $1 ]] && echo -e $1
        echo -e "Choix : $3"
        echo -en "[${CBLANC}$OLIX_FUNCTION_RETURN${CVOID}] ? "
        read RESPONSE
        [[ ! -z $RESPONSE ]] && OLIX_FUNCTION_RETURN=$RESPONSE
        String.list.contains "$3" "$OLIX_FUNCTION_RETURN" && break
    done
}


###
# Demande des infos d'un connexion distante
# @param $1 : Host du serveur
# @param $2 : Port du serveur
# @param $3 : User du serveur
# @return OLIX_RETURN_HOST : Host du serveur
# @return OLIX_RETURN_PORT : Port du serveur
# @return OLIX_RETURN_USER : User du serveur
##
function Read.connection()
{
    debug "Read.connection ($1, $2, $3)"
    OLIX_RETURN_HOST=$1
    OLIX_RETURN_PORT=$2
    OLIX_RETURN_USER=$3

    # Verifie si un cache existe pour éviter de resaisir
    local FCACHE="/tmp/cache.$LOGNAME"
    [[ -r $FCACHE ]] && source $FCACHE && debug $(cat $FCACHE)

    Read.string "Host du serveur" $OLIX_RETURN_HOST
    OLIX_RETURN_HOST=$OLIX_FUNCTION_RETURN
    echo "OLIX_RETURN_HOST=$OLIX_RETURN_HOST" > $FCACHE
    Read.digit "Port du serveur" $OLIX_RETURN_PORT
    OLIX_RETURN_PORT=$OLIX_FUNCTION_RETURN
    echo "OLIX_RETURN_PORT=$OLIX_RETURN_PORT" >> $FCACHE
    Read.string "Utilisateur de connexion" $OLIX_RETURN_USER
    OLIX_RETURN_USER=$OLIX_FUNCTION_RETURN
    echo "OLIX_RETURN_USER=$OLIX_RETURN_USER" >> $FCACHE
}
