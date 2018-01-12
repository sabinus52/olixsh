###
# Librairies de l'installation et mise à jour des modules
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies necessaires
##
load "utils/compression.sh"
load "utils/fileconfig.sh"



###
# Télécharge le module
# @param $1 : Nom du module
##
function Module.download()
{
    debug "Module.download ($1)"

    local URL=$(Module.url $1)
    info "Téléchargement du module à l'adresse ${URL}"

    local OPTS="--tries=3 --timeout=30 --no-check-certificate"
    [[ $OLIX_OPTION_VERBOSEDEBUG == true ]] && OPTS="$OPTS --debug"
    [[ $OLIX_OPTION_VERBOSE == false ]] && OPTS="$OPTS --quiet"
    OPTS="$OPTS --output-document=/tmp/olix.tar.gz"
    debug "wget ${OPTS} ${URL}"

    wget $OPTS $URL
    return $?
}



###
# Installation complète du module
# @param $1 : Nom du module
##
function Module.install()
{
    debug "Module.install ($1)"
    local UPDATE=false

    info "Vérification si le module est installé"
    if $(Module.installed $1); then
        info "Le module '$1' est déjà installé"
        Module.remove.path $1
        UPDATE=true
    fi

    # Traitement
    Module.download $1
    [[ $? -ne 0 ]] && critical "Impossible de télécharger le module $1"
    Module.install.deploy $1
    [[ $? -ne 0 ]] && critical "Impossible de déployer le module $1"
    Module.install.completion $1
    [[ $? -ne 0 ]] && critical "Impossible de déployer le fichier de completion du module $1"
    if [[ $UPDATE == false ]]; then
        Fileconfig.install $1
        [[ $? -ne 0 ]] && critical "Impossible de déployer le fichier de configuration du module $1"
    else
        Fileconfig.update $1
        [[ $? -ne 0 ]] && critical "Une erreur s'est produite pendant la mise à jour du fichier de configuration $(Config.fileName $1). Une sauvegarde est disposnible dans ${OLIX_CORE_PATH_CONFIG}"
    fi

    source $(Module.script "$1")

    local BINARIES
    Function.exists "olixmodule_$1_require_binary" && BINARIES="${BINARIES} $(olixmodule_$1_require_binary)"

    # Dépendances
    if Function.exists "olixmodule_$1_require_module"; then
        for I in $(olixmodule_$1_require_module); do
            info "Installation de la dépendance $I"
            Module.install $I
        done
    fi

    # Test des binaires présents
    for I in $BINARIES; do
        debug "which $I"
        ! System.binary.exists $I && warning "Le binaire \"$I\" n'est pas présent"
    done

    # Traitement à faire après l'installation
    if [[ $UPDATE == false ]]; then
        Function.exists "olixmodule_$1_after_install" && olixmodule_$1_after_install
    fi
}


###
# Vérification du module
# @param $1 : Nom du module
# @param $2 : Commande
##
function Module.install.check()
{
    debug "Module.install.check ($1, $2)"

    info "Vérification du module $1"
    if ! $(Module.exists $1); then
        critical "Le module '$1' est inéxistant"
    fi

    info "Vérification si le module est installé"
    if [[ "$2" == "install" ]]; then
        if $(Module.installed $1); then
            warning "Le module '$1' est déjà installé"
            echo -e "Essayer : ${CBLANC}$(basename ${OLIX_ROOT_SCRIPT}) update $1${CVOID} pour mettre à jour"
            die 1
        fi
    else
        if ! $(Module.installed $1); then
            warning "Le module '$1' n'est pas installé"
            echo -e "Essayer : ${CBLANC}$(basename ${OLIX_ROOT_SCRIPT}) install $1${CVOID} pour installer le module"
            die 1
        fi
    fi
}


###
# Déploiement du module dans le dossier /modules
# @param $1 : Nom du module
##
function Module.install.deploy()
{
    debug "Module.install.deploy ($1)"

    Compression.tar.extract "/tmp/olix.tar.gz" "$OLIX_MODULE_PATH" "--gzip"
    [[ $? -ne 0 ]] && return 1

    local DIRTAR=$(tar -tf /tmp/olix.tar.gz | grep -o '^[^/]\+' | sort -u)
    info "Renommage de '${DIRTAR}' vers '$1'"
    mv $OLIX_MODULE_PATH/$DIRTAR $OLIX_MODULE_PATH/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Installe le fichier de completion
# @param $1 : Nom du module
##
function Module.install.completion()
{
    debug "Module.install.completion ($1)"
    Module.remove.completion $1
    [[ ! -r $OLIX_MODULE_PATH/$1/conf/completion ]] && return 0
    info "Installation du fichier de completion"
    debug "ln -s $OLIX_MODULE_PATH/$1/conf/completion $OLIX_ROOT/completion/$1"
    ln -s $OLIX_MODULE_PATH/$1/conf/completion $OLIX_ROOT/completion/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}


###
# Installe le fichier de dépot utilisateur
##
function Module.install.myrepository()
{
    debug "Module.install.myrepository ()"

    local OPTS="--tries=3 --timeout=30 --no-check-certificate"
    [[ $OLIX_OPTION_VERBOSEDEBUG == true ]] && OPTS="$OPTS --debug"
    [[ $OLIX_OPTION_VERBOSE == false ]] && OPTS="$OPTS --quiet"
    OPTS="$OPTS --output-document=/tmp/olix.tar.gz"
    debug "wget ${OPTS} --output-document=${OLIX_MODULE_REPOSITORY_USER} ${OLIX_MODULE_REPOSITORY_URL}"

    wget $OPTS --output-document=$OLIX_MODULE_REPOSITORY_USER $OLIX_MODULE_REPOSITORY_URL
    return $?
}


###
# Supprime le fichier de completion
# @param $1 : Nom du module
##
function Module.remove.completion()
{
    debug "Module.remove.completion ($1)"
    if [[ -L $OLIX_ROOT/completion/$1 || -f $OLIX_ROOT/completion/$1 ]]; then
        info "Suppression du fichier de completion completion/$1"
        debug "rm -f ${OLIX_ROOT}/completion/$1"
        rm -f $OLIX_ROOT/completion/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
        return $?
    fi
    return 0
}


###
# Supprime le fichier de configuration
# @param $1 : Nom du module
##
function Module.remove.config()
{
    debug "Module.remove.config ($1)"
    local FILE=$(Config.fileName $1)
    if [[ -f ${FILE} ]]; then
        info "Suppression du fichier de configuration ${FILE}"
        debug "rm -f ${FILE}"
        rm -f $FILE > ${OLIX_LOGGER_FILE_ERR} 2>&1
        return $?
    fi
    return 0
}


###
# Supprime le dossier du module
# @param $1 : Nom du module
##
function Module.remove.path()
{
    debug "Module.remove.path ($1)"
    info "Suppression du dossier du module modules/$1"
    debug "rm -rf ${OLIX_MODULE_PATH}/$1"
    rm -rf $OLIX_MODULE_PATH/$1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    return $?
}
