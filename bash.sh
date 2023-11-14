#!/bin/bash

# je crée une function qui va me permetre de verifie is un utilisateur existe
utilisateur_exist() {
  if id "$1" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Menu principal qui sera afficher lorqu'on va lancé le programe

while true; do
# clear va nettoyé tout les ecriture precedentes a chaque fois que la boucle tourne
  clear
  echo "Menu principal"
  echo "1. Ajout d'un utilisateur"
  echo "2. Modification d'un utilisateur"
  echo "3. Suppression d'un utilisateur"
  echo "4. Sortie du script"
  echo "Choisissez une option (1/2/3/4) : "
  read  choice
#   read -p "Choisissez une option (1/2/3/4) : " $choice

  case $choice in
    1)
      # Ajout d'un utilisateur
      echo "Nom d'utilisateur : "
      read username
      echo "Chemin du dossier utilisateur : "
      read userdir
      echo "Date d'expiration (YYYY-MM-DD) : "
      read expiration_date
      echo password
      read password
      echo "Shell : "
      read shell
      echo "Identifiant (UID) : "
      read uid

      # Vérifier les conditions d'erreur
      if [ -z "$username" ] || [ -z "$userdir" ] || [ -z "$expiration_date" ] || [ -z "$shell" ] || [ -z "$uid" ]; then
        echo "Erreur : Tous les champs doivent être renseignés."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if utilisateur_exist "$username"; then
        echo "Erreur : L'utilisateur existe déjà."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if [ ! -d "$userdir" ]; then
        echo "Erreur : Le chemin du dossier utilisateur n'existe pas."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if [ "$(date -d "$expiration_date" +%s)" -le "$(date +%s)" ]; then
        echo "Erreur : La date d'expiration doit être postérieure à aujourd'hui."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if ! grep -q "^$shell" /etc/shells; then
        echo "Erreur : Le shell spécifié n'est pas installé sur le système."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      useradd -d "$userdir" -e "$expiration_date" -p "$password" -s "$shell" -u "$uid" "$username"
      echo "Utilisateur ajouté avec succès."
      read -p "Appuyez sur Entrée pour continuer..."
      ;;

    2)
      # Modification d'un utilisateur
      echo "Nom d'utilisateur à modifier : "
      read username
      if ! utilisateur_exist "$username"; then
        echo "Erreur : L'utilisateur n'existe pas."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      echo "Nouveau nom d'utilisateur : "
      read new_username
      echo new_userdir
      read new_userdir
      echo "Nouvelle date d'expiration (YYYY-MM-DD) : "
      read new_expiration_date
      echo "Nouveau mot de passe : "
      read new_password
      echo "Nouveau shell : "
      read new_shell
      echo "Nouvel identifiant (UID) : " 
      read new_uid

      # Vérifier les conditions d'erreur
      if [ -z "$new_username" ] || [ -z "$new_userdir" ] || [ -z "$new_expiration_date" ] || [ -z "$new_shell" ] || [ -z "$new_uid" ]; then
        echo "Erreur : Tous les champs doivent être renseignés."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if [ ! -d "$new_userdir" ]; then
        echo "Erreur : Le nouveau chemin du dossier utilisateur n'existe pas."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if [ "$(date -d "$new_expiration_date" +%s)" -le "$(date +%s)" ]; then
        echo "Erreur : La nouvelle date d'expiration doit être postérieure à aujourd'hui."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      if ! grep -q "^$new_shell" /etc/shells; then
        echo "Erreur : Le nouveau shell spécifié n'est pas installé sur le système."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi

      usermod -l "$new_username" -d "$new_userdir" -e "$new_expiration_date" -p "$new_password" -s "$new_shell" -u "$new_uid" "$username"
      echo "Utilisateur modifié avec succès."
      read -p "Appuyez sur Entrée pour continuer..."
      ;;

    3)
      # Suppression d'un utilisateur
      echo "Nom d'utilisateur à supprimer : "
      read username
      if ! utilisateur_exist "$username"; then
        echo "Erreur : L'utilisateur n'existe pas."
        read -p "Appuyez sur Entrée pour continuer..."
        continue
      fi
      echo "Supprimer le dossier utilisateur (oui/non) : "
      read delete_home
      echo "Supprimer l'utilisateur même s'il est connecté (oui/non) : "
      read force_delete

      userdel $username $([[ "$delete_home" == "oui" ]] && echo "--remove") $([[ "$force_delete" == "oui" ]] && echo "--force")
      echo "Utilisateur supprimé avec succès."
      read -p "Appuyez sur Entrée pour continuer..."
      ;;

    4)
      # Sortir du script
      echo "Au revoir! et merci d'voir participer "
      exit 0
      ;;

    *)
      echo "Option invalide. Veuillez choisir une option valide (1/2/3/4)."
      read -p "Appuyez sur Entrée pour continuer..."
      ;;
  esac
done
