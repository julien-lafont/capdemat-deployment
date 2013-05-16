# Mise à jour automatique CapDémat

> Script de mise à jour automatique pour CapDémat<br />
> **VERSION ALPHA : A UTILISER A VOS RISQUES ET PERILS ;)**

## Pré-requis
* Le projet doit être compilé avec Jenkins (configuration habituele)
* Le script automatise seulement les tâches habituelles et simples d'une mise à jour: téléchargement des livrables, sauvegarde des fichiers de conf, sauvegarde des BDDs, remplacement des fichiers, start/stop server...
* Le script n'automatise pas mise à jour des assets, le passage de scripts sql... Mais ces opérations peuvent être exécutées manuellement en parallèle

## Installation

    cd /home/capdemat/xxx
    git clone https://github.com/studiodev/capdemat-deployment.git
    mv capdemat-deployment scripts
    cd scripts
    cp config.properties.sample config.properties
    vim config.properties

## Utilisation

Compiler le projet sur Jenkins (ou avec [jenkins-cli](https://github.com/studiodev/jenkins-cli)), puis lancer sur le serveur

    /home/capdemat/xxx/scripts/update.sh

Pour tester seulement la configuration, lancer le script avec `--test`.

## License

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
Version 2, December 2004
 
Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
 
Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.
 
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
0. You just DO WHAT THE FUCK YOU WANT TO.
