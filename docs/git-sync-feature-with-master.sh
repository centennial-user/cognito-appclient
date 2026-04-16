#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./git-sync-feature-with-master.sh <feature-branch> [rebase|merge] [remote] [base-branch]
#
# Examples:
#   ./git-sync-feature-with-master.sh feature/login
#   ./git-sync-feature-with-master.sh feature/login merge
#   ./git-sync-feature-with-master.sh feature/login rebase origin master

FEATURE_BRANCH="${1:-}"
STRATEGY="${2:-rebase}"     # rebase | merge
REMOTE="${3:-origin}"
BASE_BRANCH="${4:-master}"

if [[ -z "$FEATURE_BRANCH" ]]; then
  echo "Error: feature branch name is required."
  echo "Usage: $0 <feature-branch> [rebase|merge] [remote] [base-branch]"
  exit 1
fi

if [[ "$STRATEGY" != "rebase" && "$STRATEGY" != "merge" ]]; then
  echo "Error: strategy must be 'rebase' or 'merge'."
  exit 1
fi

# Ensure we're in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository."
  exit 1
}

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
STASHED=0
STASH_MSG="auto-stash before syncing ${FEATURE_BRANCH} with ${BASE_BRANCH} ($(date +%Y-%m-%d_%H-%M-%S))"

echo "Current branch: ${CURRENT_BRANCH}"
echo "Feature branch: ${FEATURE_BRANCH}"
echo "Base branch:    ${BASE_BRANCH}"
echo "Remote:         ${REMOTE}"
echo "Strategy:       ${STRATEGY}"
echo

# Stash local changes (tracked, staged, and untracked) if any
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Local changes detected. Stashing (including untracked files)..."
  git stash push -u -m "${STASH_MSG}"
  STASHED=1
else
  echo "No local changes to stash."
fi

echo "Fetching latest from ${REMOTE}..."
git fetch "${REMOTE}"

echo "Updating ${BASE_BRANCH} from ${REMOTE}/${BASE_BRANCH}..."
git checkout "${BASE_BRANCH}"
git pull --ff-only "${REMOTE}" "${BASE_BRANCH}"

echo "Switching to feature branch ${FEATURE_BRANCH}..."
git checkout "${FEATURE_BRANCH}"

if [[ "${STRATEGY}" == "rebase" ]]; then
  echo "Rebasing ${FEATURE_BRANCH} onto ${BASE_BRANCH}..."
  git rebase "${BASE_BRANCH}"
else
  echo "Merging ${BASE_BRANCH} into ${FEATURE_BRANCH}..."
  git merge --no-ff "${BASE_BRANCH}"
fi

# Restore stashed work if we stashed earlier
if [[ "${STASHED}" -eq 1 ]]; then
  echo "Re-applying stashed changes..."
  # If conflicts happen here, resolve them manually
  git stash pop || true
fi

echo
echo "Sync complete."
echo "Next step:"
if [[ "${STRATEGY}" == "rebase" ]]; then
  echo "  If branch was already pushed before rebase, push with:"
  echo "  git push --force-with-lease ${REMOTE} ${FEATURE_BRANCH}"
else
  echo "  Push with:"
  echo "  git push ${REMOTE} ${FEATURE_BRANCH}"
fi
