#!/usr/bin/env bash
# =============================================================================
# Saegus — point d'entrée PUBLIC des agents. Ne contient aucun secret.
#
# Sur un Mac neuf, une seule commande :
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/saegus/agent-bootstrap/main/bootstrap.sh)" bootstrap --recover yoda
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/saegus/agent-bootstrap/main/bootstrap.sh)" bootstrap --new obiwan --role consultant
#
# Ce script installe le strict minimum (Homebrew, outil GitHub), demande la
# connexion GitHub de David, récupère le socle PRIVÉ saegus/agent-socle,
# puis lui passe la main avec les mêmes paramètres.
# =============================================================================
set -euo pipefail

SOCLE_REPO="saegus/agent-socle"
SOCLE_DIR="$HOME/agents/socle"

[ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ] || { echo "Mac à puce Apple requis."; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "Installer d'abord les outils Apple : xcode-select --install, puis relancer."; exit 1; }

if [ ! -x /opt/homebrew/bin/brew ]; then
  echo "→ Installation de Homebrew (script officiel ; mot de passe administrateur demandé)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
command -v gh >/dev/null 2>&1 || brew install gh

if [ -d "$SOCLE_DIR/.git" ]; then
  echo "✓ Socle déjà présent dans $SOCLE_DIR"
else
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    echo "→ Connexion GitHub de David dans le navigateur (récupération du socle privé)"
    gh auth login --hostname github.com --web --git-protocol https --skip-ssh-key
  fi
  gh auth setup-git   # Git utilise la connexion GitHub le temps de la récupération
  mkdir -p "$HOME/agents"
  gh repo clone "$SOCLE_REPO" "$SOCLE_DIR"
fi

exec "$SOCLE_DIR/install.sh" "$@"
