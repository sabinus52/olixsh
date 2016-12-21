###
# Gestion des fonctions système
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Nom de l'utilisateur connecté
##
function System.logged.name()
{
    echo $LOGNAME
}


###
# UID de l'utilisateur connecté
##
function System.logged.id()
{
    id -u $(System.logged.name)
}


###
# Vérifie si c'est root qui est connecté
##
function System.logged.isRoot()
{
    [[ $(id -u) != 0 ]] && return 1
    return 0
}


###
# Retourne le nombre de connexion
##
function System.logged.length()
{
    who | wc -l
}


###
# Returne si un utilisateur existe
# @param $1 : Nom de l'utilisateur
##
function System.user.exists()
{
    cut -d : -f 1 /etc/passwd | grep ^$1$ > /dev/null && return 0
    return 1
}


###
# Returne si un groupe existe
# @param $1 : Nom du groupe
##
function System.group.exists()
{
    cut -d : -f 1 /etc/group | grep ^$1$ > /dev/null && return 0
    return 1
}


###
# Retourne si un binaire existe
# @param $1 : Nom du binaire
##
function System.binary.exists()
{
    which $1 > /dev/null 2>&1 && return 0
    return 1
}


###
# Créer un fichier temporaire
##
function System.file.temp()
{
    echo -n $(mktemp /tmp/olix.XXXXXXXXXX)
}


###
# Retourne le temps d'execution
##
function System.exec.time()
{
    echo -n $((SECONDS-OLIX_CORE_EXEC_START))
}


###
# Retourne l'architecture de l'OS
##
function System.arch()
{
    [[ $(uname -m) == 'x86_64' ]] && echo '64' || echo '32'
}


###
# Retourne la famille de l'OS
##
function System.os.family()
{
    local OS=$(uname | tr '[:upper:]' '[:lower:]')
    if [[ "$OS" == "windowsnt" ]]; then
        OS=windows
    elif [[ "$OS" == "darwin" ]]; then
        OS=mac
    fi
    echo -n $OS
}


###
# Retourne le nom de la distribution de l'OS
##
function System.os.name()
{
    local NAME='unknow'
    local I
    if System.binary.exists 'lsb_release'; then
        NAME=$(lsb_release -is 2>/dev/null | tr -d '"')
        [[ "$NAME" == "SUSE LINUX" ]] && NAME="sles"
    elif File.exists '/etc/os-release'; then
        NAME=$(File.content.value '/etc/os-release' 'ID')
    else
        for I in /etc/*[_-]version /etc/*[_-]release; do
            File.exists $I || continue
            [[ "$I" == "/etc/centos-release" ]] && NAME='centos' && break
            [[ "$I" == "/etc/redhat-release" ]] && NAME='redhat' && break
            [[ "$I" == "/etc/SuSE-release" ]] && NAME='sles' && break
        done
    fi
    echo $(String.lower $NAME)
}


###
# Retourne le nom complet de la distribution
##
function System.os.prettyname()
{
    local NAME='OS inconnu'
    local I
    if System.binary.exists 'lsb_release'; then
        NAME=$(lsb_release -ds 2>/dev/null | tr -d '"')
    elif File.exists '/etc/os-release'; then
        NAME=$(File.content.value '/etc/os-release' 'PRETTY')
    else
        for I in /etc/*[_-]version /etc/*[_-]release; do
            File.exists $I || continue
            [[ "$I" == "/etc/centos-release" ]] && NAME=$(head -n1 $I) && break
            [[ "$I" == "/etc/redhat-release" ]] && NAME=$(head -n1 $I) && break
            [[ "$I" == "/etc/SuSE-release" ]] && NAME=$(head -n1 $I) && break
        done
    fi
    echo $NAME
}


###
# Retourne la version de l'OS
##
function System.os.version()
{
    local VERSION='0.0'
    local I
    if System.binary.exists 'lsb_release'; then
        VERSION=$(lsb_release -rs 2>/dev/null | tr -d '"')
    elif File.exists '/etc/os-release'; then
        VERSION=$(File.content.value '/etc/os-release' 'VERSION_ID')
    else
        for I in /etc/*[_-]version /etc/*[_-]release; do
            File.exists $I || continue
            if [[ "$I" == "/etc/centos-release" || "$I" == "/etc/redhat-release" ]]; then
                VERSION=$(grep -o '[0-9]\.[0-9]' "$I" 2>/dev/null)
                [[ -z $VERSION ]] && VERSION=$(grep -o '[0-9].' "$I" 2>/dev/null)
                break
            fi
            if [[ "$I" == "/etc/SuSE-release" ]]; then
                VERSION=$(cat /etc/SuSE-release | grep "^VERSION" | grep -oP "\=\s+\K\d+").$(cat /etc/SuSE-release | grep "^PATCHLEVEL" | grep -oP "\=\s+\K\d+")
                break
            fi
        done
    fi
    echo $VERSION
}
