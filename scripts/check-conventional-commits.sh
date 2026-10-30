#!/usr/bin/env bash
# Checks that a pull request title and every commit subject in a range follow Conventional Commits.
#
#   scripts/check-conventional-commits.sh "<PR title>" <base>..<head>
#
# Types are listed in CLAUDE.md ("Commits and pull request titles"). GitHub's `Revert "..."` format also passes.
set -euo pipefail

pattern='^((feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: [^ ]|Revert ")'
failed=0

check() {
  if [[ "$2" =~ $pattern ]]; then
    echo "ok    $1: $2"
  else
    echo "::error::$1 \"$2\" does not follow Conventional Commits, e.g. \"feat: add the brew screen\"" \
      "or \"fix(networking): retry the handshake\"."
    failed=1
  fi
}

check "PR title" "$1"
while IFS= read -r subject; do
  check "Commit" "$subject"
done < <(git log --no-merges --format=%s "$2")
exit "$failed"
