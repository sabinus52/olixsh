###
# Fonctions de compression
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne l'extension du compression d'un TAR
# @param $1 : Mode de compression
##
function Compression.tar.extension()
{
    case $(String.lower $1) in
        bz|bz2) echo -n ".tbz";;
        gz)     echo -n ".tgz";;
        *)      echo -n ".tar";;
    esac
}


###
# Retourne l'option de compression d'un TAR
# @param $1 : Mode de compression
##
function Compression.tar.mode()
{
    case $(String.lower $1) in
        bz|bz2) echo -n "--bzip2";;
        gz)     echo -n "--gzip";;
    esac
}


###
# Archive un repertoire
# @param $1 : Nom du repertoire
# @param $2 : Nom de l'archive
# @param $3 : Exclusion
# @param $4 : Autres options
##
function Compression.tar.create()
{
    debug "Compression.tar.create ($1, $2, $3, $4)"
    local PWDTMP PARAM RET
    local FILE_EXCLUDE=$(File.exclude.create "$3")
    
    PWDTMP=$(pwd)
    cd $1 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd $PWDTMP && return 1

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="--verbose"
    [[ -n $4 ]] && PARAM="$PARAM $4"
    
    debug "tar ${PARAM} --create --file $2 --exclude-from ${FILE_EXCLUDE} ."
    tar $PARAM --create --file $2 --exclude-from $FILE_EXCLUDE . 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?

    cd $PWDTMP
    File.exists $FILE_EXCLUDE && rm -f $FILE_EXCLUDE
    return $RET
}


###
# Extrait une archive dans un emplacement désiré
# @param $1 : Nom du fichier
# @param $2 : Emplacement
# @param $3 : Paramètre supplémentaire
##
function Compression.tar.extract()
{
    debug "Compression.tar.extract ($1, $2, $3)"
    local OPTS=""

    [[ $OLIX_OPTION_VERBOSE == true ]] && OPTS="$OPTS --verbose"
    [[ -n $3 ]] && OPTS="$OPTS $3"
    info "Extraction de $1 vers $2"
    debug "tar --extract ${OPTS} --file=$1 --directory=$2"

    tar --extract $OPTS --file=$1 --directory=$2 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Compression au format GZ d'un fichier
# @param $1 : Nom du fichier
# @return string : Nom du fichier compressé
##
function Compression.gzip.compress()
{
    debug "Compression.gzip.compress ($1)"
    OLIX_FUNCTION_RESULT=$1

    gzip --force $1 1> ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1

    OLIX_FUNCTION_RESULT="$1.gz"
    return 0
}


###
# Compression au format BZ2 d'un fichier
# @param $1 : Nom du fichier
# @return string : Nom du fichier compressé
##
function Compression.bzip.compress()
{
    debug "Compression.bzip.compress ($1)"
    OLIX_FUNCTION_RESULT=$1

    bzip2 --force $1 1> ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1

    OLIX_FUNCTION_RESULT="$1.bz2"
    return 0
}
