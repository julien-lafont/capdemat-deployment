# Mise à jour automatique CapDémat

> Script de mise à jour automatique pour CapDémat<br />
> **VERSION ALPHA : A UTILISER A VOS RISQUES ET PERILS ;)**

## Disclaimer
* Le projet doit être compilé avec Jenkins (configuration habituelle)
* Le script automatise seulement les tâches basiques et lourdement répétitives d'une mise à jour: téléchargement des livrables, sauvegarde du fichiers de conf, sauvegarde des BDDs, remplacement des fichiers, start/stop server...
* Le script n'a pas pour objectif de gérer tous les cas d'utilisation ([principe du 80/20](http://fr.wikipedia.org/wiki/Principe_de_Pareto))
* De fait, le script n'automatise pas la mise à jour des assets, le passage de scripts sql, le remplacement de fichiers spécifiques... Mais ces opérations peuvent être exécutés manuellement à la fin de la livraison.

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

Le script se déroule en 4 phases :
 * Mise à jour automatique du script si une version plus récente est disponible sur GIT
 * Chargement et vérification de la configuration, de l'environnement (à améliorer)
 * Paramétrage interactif de la livraison (quel build ? quel version ? sauvegarder les BDD ? relancer le serveur à la fin ?)
 * Lancement de la procédure de mise à jour

Au lancement du script, plusieurs vérifications sont exécutées pour vérifier que la configuration du script est correcte, et que l'environnement CapDémat est compatible.
Pour lancer uniquement cette vérification, rajouter `--test`

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
