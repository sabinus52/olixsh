###
# Librairies des entrées
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
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
        #[ ! -d ${IO_PATH_DEST_CONFIG} ] && mkdir -p ${IO_PATH_DEST_CONFIG}
        [[ -f ${OLIX_STDIN_RETURN} && -r ${OLIX_STDIN_RETURN} ]] && break
        logger_warning "Le fichier '${OLIX_STDIN_RETURN}' est absent"
    done
}