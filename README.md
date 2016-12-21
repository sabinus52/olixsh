oliXsh
=======
Shell Tools for Ubuntu Server and manager of projects


Installation d'oliXsh
---------------------

Installation en mode direct
``` bash
curl -s https://raw.githubusercontent.com/sabinus52/olixsh/master/install.sh | bash -s -- [DOSSIER_DE_DESTINATION]
```
avec *[DOSSIER_DE_DESTINATION]* le dossier d'installation (Par défaut `/opt`)

ou récupérer les sources depuis le dépôt Git :
``` bash
git clone https://github.com/sabinus52/olixsh.git
```
ou bien
``` bash
wget https://github.com/sabinus52/olixsh/archive/[version].tar.gz
tar xzf [version].tar.gz -C [dest dir]
mv [dest dir]/olixsh-[version] [dest dir]/olixsh
```

Exécution du script pour l'installation dans le système
```
sudo ./olixsh install olixsh
```


Mise à jour d'oliXsh
--------------------

Exécution du script pour mettre à jour oliXsh
```
olixsh update olix
```

Il est possible de définir une autre adresse de mise à jour.
Pour cela créer le fichier `mymodules.lst` dans le répertoire **conf** et
ajouter la ligne suivante
```
olixsh|nouvelle url|
```
**L'url http ou https doit pointer vers un fichier en `.tar.gz`**


Gestion des module oliXsh
-------------------------------

Pour installer un module
```
olixsh install nom_du_module
```

Pour mettre à jour d'un module
```
olixsh update nom_du_module
```

Il est possible d'ajouter ces propres modules. Il suffit de les déclarer 
dans le fichier `mymodules.lst` situés dans le répertoire **conf**
(si ce fichier n'existe pas, il faudra le créer) sour la forme :
```
nom_du_module|url_de_téléchargement_du_module|intitulé_du_module
```
*Les urls http ou https doivent pointer vers un fichier en `.tar.gz`*


Tout mettre à jour automatiquement
----------------------------------

Exécution du script pour tout mettre à jour (oliXsh + tous les modules installés)
```
olixsh update --all
```

Cette commande peut être mise dans un cron.
Définir un mail pour être alerté lors d'un problème.
Exemple de configuration du cron :
```
MAILTO=email@domain.tld
52 02 * * 0   /opt/olixsh/olixsh --no-warnings update --all > /dev/null
```


Aide
----

```
olixsh --help
```
ou
```
olixsh {command} help
```
