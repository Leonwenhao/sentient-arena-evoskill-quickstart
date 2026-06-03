#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Evolve the OfficeQA skill with EvoSkill.
#
#   ./scripts/improve.sh                               # default: M2.7 via OpenRouter
#   ./scripts/improve.sh .evoskill/config.advanced.toml # strong-model evolve (needs ANTHROPIC_API_KEY)
#
# Runs locally — no Docker. EvoSkill versions each program as a git branch inside
# evoskill-project/ (an isolated repo, so it never touches your outer clone).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/../evoskill-project"

CONFIG="${1:-.evoskill/config.toml}"

# --- API key check (all configs route through OpenRouter) ---
[ -n "${OPENROUTER_API_KEY:-}" ] || { echo "Set OPENROUTER_API_KEY first (see ./scripts/setup.sh)."; exit 1; }
command -v evoskill &>/dev/null || { echo "evoskill not found — run ./scripts/setup.sh first."; exit 1; }

# --- isolated git repo so EvoSkill's program/* branches stay out of the outer repo ---
if [ ! -d .git ]; then
  printf '{"original_branch": "main"}\n' > .evoskill/state.json
  git init -q
  git add -A
  git -c user.email=you@example.com -c user.name=you commit -q -m "officeqa evoskill — baseline (seed skill)"
  echo "✓ initialized isolated git repo for EvoSkill"
fi

echo
echo "▶ Baseline: scoring the SEED skill on the validation split…"
evoskill eval --config "$CONFIG" || true

echo
echo "▶ Evolving (EvoSkill proposes → generates → evaluates → keeps winners)…"
echo "   model/config: $CONFIG"
evoskill run --verbose --config "$CONFIG"

echo
echo "▶ Skills discovered:"
evoskill skills || true
echo
echo "▶ Diff vs baseline (what the loop changed):"
evoskill diff || true

echo
echo "✓ Done. The improved skill set is in: evoskill-project/.claude/skills/"
echo "  Inspect it, then ship it:   ./scripts/submit.sh"
