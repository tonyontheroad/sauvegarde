#!/bin/bash
LC_CTYPE=fr_FR.UTF-8
# Ce script ajoute les répertoire voulu par l'amdinistrateur dans le script de
# sauvegarde OU créer et configure le script de sauvegarde.
#
# Ce script fait partie intégrante du dépôt GitHub de tonyontheroad.
# L'ensemble du dépôt sous la license GNU GPL v3.0.
#
# Libre à vous de vous en servir, de le partager, de le modifier.
#
# J'invite les administrateurs et utilisateurs à lire ce script et ainsi en
# apprendre plus sur les commandes que j'emplois (je ne réinvente pas l'eau
# chaude).
#
# Aussi si vous pensez que je peux améliorer mon code, vous pouvez me
# contacter via mon GitHub :
# 	https://github.com/tonyontheroad

# -----------------------------------------------------------------------------
#
# Vérification de l'existance du script de sauvegarde :
if [ -f "./sauvegarde.sh" ];then
	newScript=false
fi

# Confirmation pour la création si le fichier sauvegarde.sh n'existe pas :
if $newScript;then
	read -p "Le fichier sauvegarde.sh n'existe pas ! Faut-il le créer ? (O/n) : " on
	if echo "$on" | grep -iq "^n" ;then 
		exit 1
	fi
fi

# Création du script de sauvegarde si celui-ci est absent dans le dossier :
if $newScript;then
	echo "création du fichier sauvegarde.sh"

	touch ./sauvegarde.sh
	echo $'#!/bin/bash\n\n# Ce script sauvegarde les répertoire voulu par l amdinistrateur via le script de\n# configuration.\n#\n# Ce script fait partie intégrante du dépôt GitHub de tonyontheroad.\n# L ensemble du dépôt sous la license GNU GPL v3.0.\n#\n# Libre à vous de vous en servir, de le partager, de le modifier.\n#\n# J invite les administrateurs et utilisateurs à lire ce script et ainsi en\n# apprendre plus sur les commandes que j emplois (je ne réinvente pas l eau\n# chaude).\n#\n# Aussi si vous pensez que je peux améliorer mon code, vous pouvez me\n# contacter via mon GitHub :\n# 	https://github.com/tonyontheroad\n#\n' > ./sauvegarde.sh
	echo -e "echo -e \042Rapport d'exécution de sauvegarde.\\\n\042 > ./mail.txt" >> ./sauvegarde.sh
	chmod +x ./sauvegarde.sh

	read -p "Voulez-vous envoyer un mail automatique lors de la sauvegarde ? (o/N) : " activeMail
	if echo "$activeMail" | grep -iq "^o" ;then
		read -p "Adresse du destinataire : " adresseDest
		mail=true
	fi
	
fi

# Liste des sauvegardes actuellements configurées:
echo -e "\nListe des sauvegardes configurées :\n"
cat sauvegarde.sh | grep '# dossier :\|# fichier :'
echo ""

# Demande du répertoire ou fichier à ajouter au script de sauvegarde :
read -p "Nom du dossier/fichier ajouter à la sauvegarde : " ajout
read -p "Donnez un alias pour "$ajout" : " ajoutAlias
if [ -d $ajout ];then
	ajoutDossier=true
	ajoutFichier=false
	echo "Ceci est un dossier"
fi
if [ -f $ajout ];then
	ajoutFichier=true
	ajoutDossier=false
	echo "Ceci est un fichier"
fi
if ! $ajoutDossier && ! $ajoutFichier;then
	echo "Le fichier ou dossier indiqué n'existe pas !"
	exit 1
fi

read -p "Voulez-vous ajouter : "$ajout" ? (o/N) : " confirmAjout
if echo "$confirmAjout" | grep -iq "^n";then
	exit 1
else
	if [ -f "$ajoutAlias.1.tar.gz" ];then
		echo "L'archive existe déjà !"
		exit 1
	fi
	echo "Ajout dans le script sauvegarde.sh de "$ajout
	
	if $ajoutDossier;then
		echo -e "\n#-----------------------------------------------------------------------------" >> sauvegarde.sh
		echo "# dossier : "$ajoutAlias" "$ajout >> ./sauvegarde.sh
	fi
	if $ajoutFichier;then
		echo -e "\n#-----------------------------------------------------------------------------" >> sauvegarde.sh
		echo "# fichier : "$ajoutAlias" "$ajout >> ./sauvegarde.sh
	fi
	if [ -f "$ajoutAlias.1.tar.gz" ];then
		echo "L'archive existe déjà !"
		exit 1
	fi
	tar --create --file=./"$ajoutAlias".1.tar.gz --listed-incremental=./"$ajoutAlias".list "$ajout"
	echo -e $ajoutAlias"Incr=\`ls | sed -nr 's/^.*"$ajoutAlias"\.([0-9]+)\.tar.gz/\1/p' | awk 'max==\042\042 || \$1 > max {max=\$1} END {print max}'\`" >> ./sauvegarde.sh
	echo -e "let \042"$ajoutAlias"Incr_1 = $"$ajoutAlias"Incr + 1\042" >> ./sauvegarde.sh
	echo -e "nomFichier"$ajoutAlias"="$ajoutAlias".$"$ajoutAlias"Incr_1.tar.gz" >> ./sauvegarde.sh
	echo -e "tar --create --file=./\$nomFichier"$ajoutAlias" --listed-incremental=./"$ajoutAlias".txt "$ajout >> sauvegarde.sh
	if $mail;then
		echo "date=\`date -I\`" >> ./sauvegarde.sh
		echo "heure=\`date | cut -c16-23\`" >> ./sauvegarde.sh
		echo -e "echo -e \042Le script de sauvegarde sur `uname -n` pour l'alias \$ajoutAlias s'est correctement effectué le \$date à \$heure.\\\n\042 >> ./mail.txt" >> ./sauvegarde.sh
	fi
	if cat ./sauvegarde.sh | grep "mail -s";then
		sed '/mail -s/d' ./sauvegarde.sh
		echo -e "mail -s \042[Sauvegarde] effectuée sur `uname -n`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
	elif ! cat ./sauvegarde.sh | grep "mail -s";then
		echo -e "mail -s \042[Sauvegarde] effectuée sur `uname -n`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
	fi
fi
