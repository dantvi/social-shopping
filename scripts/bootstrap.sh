set -euo pipefail

PLUGIN_DIR="fsu24d-social-shopping-plugin-dantvi"
THEME_DIR="fsu24d-social-shopping-tema-dantvi"

PLUGIN_REPO="${PLUGIN_REPO:-https://github.com/Medieinstitutet/fsu24d-social-shopping-plugin-dantvi}"
THEME_REPO="${THEME_REPO:-https://github.com/Medieinstitutet/fsu24d-social-shopping-tema-dantvi}"

clone_if_missing () {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "$target_dir/.git" ]; then
    echo "Already present: $target_dir"
    return 0
  fi

  if [ -d "$target_dir" ]; then
    echo "Found directory '$target_dir' without a .git repo. Skipping clone to avoid overwriting."
    echo "If you want a fresh clone, remove the directory and rerun."
    return 0
  fi

  echo "→ Cloning $repo_url → $target_dir"
  git clone --depth 1 "$repo_url" "$target_dir"
}

echo "=== Bootstrap: cloning classroom repos (plugin + theme) ==="
clone_if_missing "$PLUGIN_REPO" "$PLUGIN_DIR"
clone_if_missing "$THEME_REPO"  "$THEME_DIR"

echo "=== Done. Current classroom repos: ==="
ls -1d fsu24d-social-shopping-* 2>/dev/null || echo "(none yet)"
