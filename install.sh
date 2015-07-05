###
# Installation automatique d'oliXsh
# Usage : curl -s https://raw.githubusercontent.com/sabinus52/olixsh2/master/install.sh | bash -s -- [DOSSIER_DE_DESTINATION]
##

# Paramètres
REPOSITORY="https://github.com/sabinus52/olixsh2/archive/master.tar.gz"
TARBALL="/tmp/olixsh.tar.gz"
DIRNAME="olixsh"
DESTINATION="/opt"
[[ -n $1 ]] && DESTINATION=$1

[[ $(id -u) != 0 ]] && echo "Il est préférable d'être \"root\"" && exit 1


# Téléchargement
echo "Téléchargement des sources à l'adresse (${REPOSITORY})"
wget --tries=3 --timeout=30 --no-check-certificate --output-document=${TARBALL} ${REPOSITORY}
[[ $? -ne 0 ]] && echo "Erreur lors du téléchargement des sources" && exit 1


# Extraction dans le dossier de destination
echo "Extraction de l'archive vers ${DESTINATION}"
if [[ -d ${DESTINATION}/${DIRNAME} ]]; then
    rm -rf ${DESTINATION}/${DIRNAME}
    [[ $? -ne 0 ]] && echo "Impossible de supprimer le dossier ${DESTINATION}/${DIRNAME}" && exit 1
fi
mkdir ${DESTINATION}/${DIRNAME}
if [[ $? -ne 0 ]]; then
    echo "Impossible de créer le dossier ${DESTINATION}/${DIRNAME}"
    rm -f ${TARBALL}
    exit 1
fi
tar --extract --file=${TARBALL}  --strip-components=1 --directory=${DESTINATION}/${DIRNAME}
if [[ $? -ne 0 ]]; then
    echo "Erreur lors du l'extraction de l'archive"
    rm -f ${TARBALL}
    exit 1
fi
rm -f ${TARBALL}

# Installation
cd ${DESTINATION}/${DIRNAME}
./olixsh install olix
