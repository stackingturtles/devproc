#!/usr/bin/env bash
# Consistency check for the process library. Run after editing sources.
#   1. Generated role agents are current (scripts/build-agents.sh --check).
#   2. Shared, harness-neutral files contain no harness-specific terms.
#   3. Relative Markdown links resolve.
#   4. The Claude Code plugin manifests validate (skipped if `claude` is absent).
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 2
status=0
fail() { echo "FAIL: $*" >&2; status=1; }

echo "== generated agents"
"$root/scripts/build-agents.sh" --check || fail "generated agents are stale"

# Harness-neutral sources. Harness specifics belong only in harnesses.md, harness/,
# generated agents, .claude-plugin/, and scripts/. README.md is the index and may
# name and link the supported harnesses, so it is not checked.
shared=(AGENTS.md process.md static-analysers.md dependency-checking.md)
while IFS= read -r f; do shared+=("$f"); done < <(find roles runbooks skills -type f -name '*.md' | sort)

# Distinctive per-harness tool, package, and configuration names.
terms='contact_supervisor|need_decision|interview_request|pi-subagents|pi-web-access|pi-lsp|pi-hashline|rpiv-ask-user-question|~/\.pi\b|\bweb_search\b|\bfetch_content\b|get_search_content|source_check|inheritSkills|acceptanceRole|subagentOnlyExtensions|systemPromptMode|\bPi\b|Claude Code|SendMessage|AskUserQuestion|WebSearch|WebFetch|CLAUDE\.md|\.claude-plugin|NEEDS_DECISION|devproc:'

echo "== harness-specific terms in shared files"
if hits=$(grep -nE "$terms" "${shared[@]}"); then
  echo "$hits" >&2
  fail "harness-specific terms in shared files (move them to harnesses.md or harness/)"
fi

echo "== relative markdown links"
while IFS= read -r f; do
  dir="$(dirname "$f")"
  while IFS= read -r link; do
    target="${link%%#*}"
    [[ -z "$target" ]] && continue
    case "$target" in http://*|https://*|mailto:*) continue ;; esac
    [[ -e "$dir/$target" ]] || fail "$f: broken link ($link)"
  done < <(awk '/^[[:space:]]*```/{fence=!fence; next} !fence' "$f" | grep -oE '\]\([^) ]+\)' | sed -E 's/^\]\(//; s/\)$//')
done < <(find . -path ./.git -prune -o -path ./logs -prune -o -type f -name '*.md' -print | sort)

echo "== plugin manifest"
if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$root" >/dev/null 2>&1 || fail "claude plugin validate failed (run it for details)"
else
  echo "skipped: claude CLI not found"
fi

if (( status )); then echo "check: FAILED" >&2; else echo "check: OK"; fi
exit "$status"
