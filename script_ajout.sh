#!/bin/bash
DIALOG=${DIALOG=dialog}
LC_CTYPE=fr_FR.UTF-8
fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
trap "rm -f $fichtemp" 0 1 2 5 15

$DIALOG --title "Informations" --clear \
	--backtitle "Sauvegardeur" \
	--msgbox "Ce script ajoute les répertoire voulu par l'amdinistrateur dans le script de \n\
sauvegarde OU créer et configure le script de sauvegarde. \n\
\n\
Ce script fait partie intégrante du dépôt GitHub de tonyontheroad. \n\
L'ensemble du dépôt sous la license GNU GPL v3.0. \n\
\n\
Libre à vous de vous en servir, de le partager, de le modifier. \n\
\n\
J'invite les administrateurs et utilisateurs à lire ce script et ainsi en \n\
apprendre plus sur les commandes que j'emplois (je ne réinvente pas l'eau \n\
chaude). \n\
\n\
Aussi si vous pensez que je peux améliorer mon code, vous pouvez me \n\
contacter via mon GitHub : \n\
	https://github.com/tonyontheroad" 25 90

# ------------------------------------------------------------------------------------
# ---------------------- INITIALISATION ----------------------------------------------
# ------------------------------------------------------------------------------------

# Vérification de l'existance du script de sauvegarde :
if [ -f "./sauvegarde.sh" ];then
	newScript=false
elif [ ! -f "./sauvegarde.sh" ];then
	newScript=true
fi

# Confirmation pour la création si le fichier sauvegarde.sh n'existe pas :
if $newScript;then
	$DIALOG --title "Création sauvegarde.sh" --clear \
		--backtitle "Sauvegardeur" \
		--yesno "Le fichier sauvegarde.sh n'existe pas ! Voulez-vous le créer ?" 25 90
	case $? in
		1)	clear && exit 1;;
		255)	clear && exit 1;;
	esac
fi

# Création du script de sauvegarde si celui-ci est absent dans le dossier :
if $newScript;then
	# echo "création du fichier sauvegarde.sh"

	touch ./sauvegarde.sh
	echo $'#!/bin/bash
# Ce script sauvegarde les répertoire voulu par l amdinistrateur via le script de
# configuration.
#
# Ce script fait partie intégrante du dépôt GitHub de tonyontheroad.
# L ensemble du dépôt sous la license GNU GPL v3.0.
#
# Libre à vous de vous en servir, de le partager, de le modifier.
#
# J invite les administrateurs et utilisateurs à lire ce script et ainsi en
# apprendre plus sur les commandes que j emplois (je ne réinvente pas l eau
# chaude).
#
# Aussi si vous pensez que je peux améliorer mon code, vous pouvez me
# contacter via mon GitHub :
# 	https://github.com/tonyontheroad
#' > ./sauvegarde.sh
	echo -e "echo -e \042Rapport d'exécution de sauvegarde.\\\n\042 > ./mail.txt" >> ./sauvegarde.sh
	chmod +x ./sauvegarde.sh
fi
# ------------------------------------------------------------------------------------
# ---------------------------- MENU --------------------------------------------------
# ------------------------------------------------------------------------------------

funMenu(){ $DIALOG --title "Menu" \
	--backtitle "Sauvegardeur" \
	--menu "Faites votre choix :" 25 90 4 \
	"Afficher" "Consulter les sauvegardes déjà paramétrées" \
	"Ajouter" "Ajouter une sauvegarde" \
	"Mail" "Activer ou modifier l'adresse mail pour les rapports" \
	"Quitter" "Quitter le script" 2>$fichtemp
valret=$?
choixMenu=$(<$fichtemp)
case $valret in
	1)	clear && exit 1;;
	255)	clear && exit 1;;
esac

if [ $choixMenu = "Afficher" ];then
	# --- LISTING ---
	funAffich (){
	# Liste des sauvegardes actuellements configurées:
	$(echo -e "Liste des sauvegardes configurées :\n" > $fichtemp)
	$(cat sauvegarde.sh | grep '# dossier :\|# fichier :' >> $fichtemp)
	existant=$(<$fichtemp)
	$DIALOG --title "Eléments courant à sauvegarder" \
		--backtitle "Sauvegardeur" \
		--msgbox "$existant" 25 90
	
	funMenu
	}
	funAffich


# ---------------------------- AJOUTER -----------------------------------------------

elif [ $choixMenu = "Ajouter" ];then
	funAjout (){
	# Demande du répertoire ou fichier à ajouter au script de sauvegarde :
	echo "" > $fichtemp
	$DIALOG --title "Ajout d'une sauvegarde" \
		--backtitle "Sauvegardeur" \
		--fselect $HOME/ 25 90 2> $fichtemp
	chemin=$(<$fichtemp)
	
	echo "" > $fichtemp
	$DIALOG --title "Ajout d'une sauvegarde" \
		--backtitle "Sauvegardeur" \
		--inputbox "Donnez un alias à cette nouvelle sauvegarde :" 25 90 2> $fichtemp
	alias=$(<$fichtemp)
	
	# --- TEST ---
	
	if [ -d $chemin ];then
		ajoutDossier=true
		ajoutFichier=false
		typeChemin="Dossier"
		# echo "Ceci est un dossier"
	fi
	##
	if [ -f $chemin ];then
		ajoutFichier=true
		ajoutDossier=false
		typeChemin="Fichier"
		# echo "Ceci est un fichier"
	fi
	##
	if ! $ajoutDossier && ! $ajoutFichier;then
		$DIALOG --title "Chemin inexistant" \
			--backtitle "Sauvegardeur" \
			--msgbox "Le fichier ou dossier indiqué n'existe pas !" 25 90
	fi
	
	# --- CONFIRM ---
	
	$DIALOG --title "Confirmer l'ajout" \
		--backtitle "Sauvegardeur" \
		--yesno "Confirmez-vous l'ajout des informations suivantes :\n \
	chemin : $chemin\n \
	alias : $alias\n \
	type : $typeChemin" 25 90
	
	case $? in
		1) clear && exit 1;;
		255) clear && exit 1;;
	esac
	
	if [ -f "$alias.1.tar.gz" ];then
		$DIALOG --title "Déjà existant" \
			--backtitle "Sauvegardeur" \
			--msgbox "L'archive existe déjà !" 25 90
	fi
	
	if cat ./sauvegarde | grep $chemin;then
		if $ajoutDossier;then
			$DIALOG --title "Déjà existant" \
				--backtitle "Sauvegardeur" \
				--msgbox "Vous avez déjà une sauvegarde pour ce dossier !" 25 90
		fi
		if $ajoutFichier;then
			$DIALOG --title "Déjà existant" \
				--backtitle "Sauvegardeur" \
				--msgbox "Vous avez déjà une sauvegarde pour ce fichier !" 25 90
		fi
	fi
	
	# ------------------------------------------------------------------------------------
	# ----------------------- EXECUTION --------------------------------------------------
	# ------------------------------------------------------------------------------------
	
	tar --create --file=./"$alias".1.tar.gz --listed-incremental=./"$alias".list "$chemin"
	echo -e $alias"Incr=\`ls | sed -nr 's/^.*"$alias"\.([0-9]+)\.tar.gz/\1/p' | awk 'max==\042\042 || \$1 > max {max=\$1} END {print max}'\`" >> ./sauvegarde.sh
	
	# ------------------------------------------------------------------------------------
	# ------------------- INSCRIPTION DES PARAMETRES -------------------------------------
	# ------------------------------------------------------------------------------------
	
	if $ajoutDossier;then
		echo -e "\n#-----------------------------------------------------------------------------" >> sauvegarde.sh
		echo "# dossier : "$alias" "$chemin >> ./sauvegarde.sh
	fi
	##
	if $ajoutFichier;then
		echo -e "\n#-----------------------------------------------------------------------------" >> sauvegarde.sh
		echo "# fichier : "$alias" "$chemin >> ./sauvegarde.sh
	fi
	
	echo -e "let \042"$alias"Incr_1 = $"$alias"Incr + 1\042" >> ./sauvegarde.sh
	echo -e "nomFichier"$alias"="$alias".$"$alias"Incr_1.tar.gz" >> ./sauvegarde.sh
	echo -e "tar --create --file=./\$nomFichier"$alias" --listed-incremental=./"$alias".txt "$chemin >> sauvegarde.sh
	
	if $mail;then
		echo "date=\`date -I\`" >> ./sauvegarde.sh
		echo "heure=\`date | cut -c16-23\`" >> ./sauvegarde.sh
		echo -e "echo -e \042Le script de sauvegarde sur `uname -n` pour l'alias $alias s'est correctement effectué le \$date à \$heure.\\\n\042 >> ./mail.txt" >> ./sauvegarde.sh
	fi
	##
	if cat ./sauvegarde.sh | grep "mail -s";then
		sed -e '/mail -s/d' ./sauvegarde.sh > ./sauv.tmp
		cat ./sauv.tmp > ./sauvegarde.sh
		rm ./sauv.tmp
		echo -e "mail -s \042[Sauvegarde] effectuée sur \`uname -n\`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
	elif ! cat ./sauvegarde.sh | grep "mail -s";then
		echo -e "mail -s \042[Sauvegarde] effectuée sur \`uname -n\`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
	fi
	
	$DIALOG --title "Ajouté avec succès" \
		--backtitle "Sauvegardeur" \
		--msgbox "Fichier sauvegarde.sh mis à jour avec succès" 25 90
	
	funMenu
	}
	funAjout


# ---------------------------- MAIL --------------------------------------------------

elif [ $choixMenu = "Mail" ];then
	# --- MAIL ---
	funMail ()
	{
		fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
		trap "rm -f $fichtemp" 0 1 2 5 15

		$DIALOG --title "Rapport mail" --clear \
			--backtitle "Sauvegardeur" \
			--yesno "Voulez-vous activer la fonction d'envoi de rapport par mail ?\n
		(Le service mail est nécessaire pour cette fonction).\n\n \
		Pour modifier l'adresse mail existante, répondez oui" 25 90
		case $? in
			0)	mail=true;;
			1)	mail=false;;
			255)	clear && exit 1;;
		esac
		
		if $mail;then
			$DIALOG --title "Rapport mail" --clear \
				--backtitle "Sauvegardeur" \
				--inputbox "Quelle est l'adresse du destinataire du rapport ?" 25 90 2> $fichtemp
			adresseDest=$(<$fichtemp)
		elif ! $mail && ! $newScript;then
			adresseDest=$(< cat sauvegarde.sh | grep "mail -s" | sed -nr 's/.* ([a-z]+\@[a-z]+\.[a-z]+).*/\1/p')
		fi
		
		if cat ./sauvegarde.sh | grep "mail -s";then
			sed -e '/mail -s/d' ./sauvegarde.sh > ./sauv.tmp
			cat ./sauv.tmp > ./sauvegarde.sh
			rm ./sauv.tmp
			echo -e "mail -s \042[Sauvegarde] effectuée sur \`uname -n\`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
		elif ! cat ./sauvegarde.sh | grep "mail -s";then
			echo -e "mail -s \042[Sauvegarde] effectuée sur \`uname -n\`\042 $adresseDest < ./mail.txt" >> sauvegarde.sh
		fi

		funMenu
	}
	funMail

# ---------------------------- QUITTER -----------------------------------------------

elif [ $choixMenu = "Quitter" ];then
	clear && exit 1
fi

}

funMenu
