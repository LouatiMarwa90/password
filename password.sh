chmod +x password.sh
#!/bin/bash

# Fonction pour afficher l'usage
show_usage() {
  echo "password.sh: [-h] [-v] [-m] [-g] [-N] [-t] mot.."
}

# Fonction pour afficher le help détaillé
HELP() {
  if [[ -f help.txt ]]; then
    cat help.txt
  else
    echo "Fichier help.txt introuvable."
  fi
}

# Fonction pour vérifier si un mot de passe est acceptable
check_password() {
  local password="$1"

  # Vérifier la longueur minimum de huit caractères
  if [[ ${#password} -lt 8 ]]; then
    echo "Mot de passe trop court. Il doit contenir au moins huit caractères."
    return 1
  fi

  # Vérifier la présence d'au moins un caractère numérique
  if ! [[ $password =~ [0-9] ]]; then
    echo "Le mot de passe doit contenir au moins un caractère numérique."
    return 1
  fi

  # Vérifier la présence d'au moins un caractère spécial parmi @, #, $, %, &, *, +, -, =
  if ! [[ $password =~ [@#\$%\&\*\+\-=] ]]; then
    echo "Le mot de passe doit contenir au moins un caractère spécial parmi @, #, $, %, &, *, +, -, =."
    return 1
  fi

  # Vérification de type dictionnaire (à ajuster selon les besoins)
  for ((i=0; i<${#password}-3; i++)); do
    substring="${password:i:4}"
    if grep -qw "$substring" /usr/share/dict/words; then
      echo "Le mot de passe contient une séquence de quatre caractères consécutifs trouvée dans le dictionnaire."
      return 1
    fi
  done

  echo "Le mot de passe est acceptable."
  return 0
}

# Fonction pour afficher le nom des auteurs et version du code
show_version() {
  echo "password.sh version 1.0, créé par [votre nom]."
}

# Fonction pour afficher un menu textuel avec YAD
show_menu() {
  if ! command -v yad &> /dev/null; then
    echo "YAD n'est pas installé. Veuillez l'installer pour utiliser cette fonctionnalité."
    exit 1
  fi

  yad --form --title="Menu Password.sh" \
    --field="Vérifier un mot de passe" \
    --field="Help" \
    --field="Version" \
    --field="Quitter"
}

# Vérifier la présence d'au moins un argument
if [[ $# -lt 1 ]]; then
  show_usage >&2
  exit 1
fi

# Analyser les options
while getopts ":hvtmg" opt; do
  case $opt in
    h)
      HELP
      exit 0
      ;;
    v)
      show_version
      exit 0
      ;;
    t)
      shift $((OPTIND - 1))
      if [[ -z $1 ]]; then
        echo "Erreur: Aucun mot de passe fourni."
        show_usage >&2
        exit 1
      fi
      check_password "$1"
      exit $?
      ;;
    m)
      show_menu
      exit 0
      ;;
    g)
      show_menu
      exit 0
      ;;
    \?)
      echo "Option invalide: -$OPTARG" >&2
      show_usage >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requiert un argument." >&2
      show_usage >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [[ -z $1 ]]; then
  echo "Erreur: Aucun mot de passe fourni."
  show_usage >&2
  exit 1
fi

# Vérifier le mot de passe fourni
check_password "$1"
exit $?

