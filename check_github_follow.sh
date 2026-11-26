#!/usr/bin/env bash
set -euo pipefail

target_user="jephersonRD"
expected_user="${GITHUB_USER:-}"

if [[ -z "$expected_user" && -f .env ]]; then
  expected_user="$(sed -n 's/^GITHUB_USER=//p' .env | head -n 1)"
fi

if [[ -z "$expected_user" ]]; then
  echo "Set GITHUB_USER in .env before running this check." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it and run 'gh auth login'." >&2
  exit 1
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "Sign in to GitHub first by running 'gh auth login'." >&2
  exit 1
fi

authenticated_user="$(gh api user --jq '.login')"
if [[ "${authenticated_user,,}" != "${expected_user,,}" ]]; then
  echo "The authenticated GitHub account ($authenticated_user) does not match GITHUB_USER ($expected_user)." >&2
  exit 1
fi

if ! gh api --silent "user/following/${target_user}" >/dev/null 2>&1; then
  echo "Could not verify that $authenticated_user follows https://github.com/${target_user}." >&2
  echo "Follow the account, then retry; ensure your GitHub CLI authentication can read your account." >&2
  exit 1
fi

echo "Follow check passed for $authenticated_user."
