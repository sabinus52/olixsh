###
# Librairies de gestions des containeurs Docker
# ==============================================================================
# @package olixsh
# @author Olivier
##


###
# Paramètres
##
OLIX_DOCKER_NAME=


###
# Vérifie si le binaire est installé
##
function Docker.installed()
{
    debug "Docker.installed ()"
    System.binary.exists 'docker'
    return $?
}


###
# Vérifie si on peut parler avec le démon Docker
##
function Docker.running()
{
    debug "Docker.daemon ()"
    docker info > /dev/null 2>&1
    return $?
}


###
# Vérifie si un containeur existe
# @param $1 : Nom du containeur
##
function Docker.Container.exists()
{
    debug "Docker.Container.exists ($1)"
    docker inspect $1 > /dev/null 2>&1
    return $?
}


###
# Vérifie si un containeur est en cours d'éxécution
# @param $1 : Nom du containeur
##
function Docker.Container.running()
{
    debug "Docker.Container.running ($1)"
    local RUNNING
    RUNNING=$(docker inspect --format="{{.State.Running}}" $1 2>&1)
    [[ "${RUNNING}" == "true" ]] && return 0
    return 1
}
