#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# The bridge: take the EvoSkill-evolved skill → drop it into the Arena agent →
# submit to Challenge 1 (office-qa).
#
#   ./scripts/submit.sh            # confirm, then submit
#   ./scripts/submit.sh --dry-run  # wire up the skill but DON'T submit (inspect first)
#
# Note: Arena allows 1 submission/day. This uses your daily slot.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EVO="$ROOT/evoskill-project"
AGENT="$ROOT/arena-agent"
DRY=0; [[ "${1:-}" == "--dry-run" ]] && DRY=1

[ -d "$EVO/.claude/skills" ] || { echo "No evolved skills found. Run ./scripts/improve.sh first."; exit 1; }
command -v arena &>/dev/null || { echo "arena CLI not found — run ./scripts/setup.sh."; exit 1; }

echo "▶ Wiring the evolved skill into the Arena agent ($AGENT/skills_consolidated/)…"
# Keep a one-time backup of the shipped baseline skill
[ -d "$AGENT/.skills_baseline" ] || cp -R "$AGENT/skills_consolidated" "$AGENT/.skills_baseline"

# Replace the agent's skills with the evolved domain skills.
# Skip 'skill-creator' (a meta-skill EvoSkill uses to AUTHOR skills — not useful at eval).
rm -rf "$AGENT/skills_consolidated"; mkdir -p "$AGENT/skills_consolidated"
copied=0
for d in "$EVO"/.claude/skills/*/; do
  name="$(basename "$d")"
  [ "$name" = "skill-creator" ] && continue
  cp -R "$d" "$AGENT/skills_consolidated/$name"
  copied=$((copied+1))
  echo "    + $name"
done
[ "$copied" -gt 0 ] || { echo "Nothing copied — restoring baseline."; rm -rf "$AGENT/skills_consolidated"; mv "$AGENT/.skills_baseline" "$AGENT/skills_consolidated"; exit 1; }
echo "  ✓ $copied skill(s) wired in. (Baseline saved at arena-agent/.skills_baseline/.)"

cd "$AGENT"
echo
echo "▶ Validating the agent config…"
[ -d .arena/samples ] || { echo "  fetching office-qa samples (one-time)…"; arena pull; }
arena test --dry-run

if [ "$DRY" -eq 1 ]; then
  echo
  echo "✓ Dry run: skill wired in and config valid. Review arena-agent/skills_consolidated/, then:"
  echo "    cd arena-agent && arena submit --tag evoskill"
  exit 0
fi

echo
read -rp "Submit this agent to Challenge 1 now? (uses today's 1 submission) [y/N] " yn
case "$yn" in
  [Yy]*) arena submit --tag evoskill
         echo; echo "✓ Submitted. Check your score:  arena history    (or  arena status <id>)";;
  *)     echo "Skipped. When ready:  cd arena-agent && arena submit --tag evoskill";;
esac
