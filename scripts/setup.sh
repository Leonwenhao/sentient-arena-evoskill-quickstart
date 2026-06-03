#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Sentient Arena × EvoSkill quickstart — one-time setup
#
# Installs everything you need to evolve an OfficeQA skill and submit it to
# Challenge 1:  uv → EvoSkill → goose → arena-cli check → API key.
# No Docker required.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

b()  { printf "\033[1m%s\033[0m\n" "$1"; }
ok() { printf "  \033[32m✓\033[0m %s\n" "$1"; }
no() { printf "  \033[31m✗\033[0m %s\n" "$1"; }
inf(){ printf "  \033[2m%s\033[0m\n" "$1"; }

b "1/5  uv (Python package manager)"
if command -v uv &>/dev/null; then ok "uv $(uv --version | awk '{print $2}')"; else
  inf "installing uv…"; curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"; ok "uv installed"
fi

b "2/5  EvoSkill"
if command -v evoskill &>/dev/null; then ok "evoskill already installed"; else
  inf "installing EvoSkill from GitHub (pulls a few agent SDKs — give it a minute)…"
  if uv tool install "git+https://github.com/sentient-agi/EvoSkill.git" 2>/dev/null; then
    ok "evoskill installed (uv tool)"
  else
    inf "uv tool install failed; falling back to a local editable clone…"
    rm -rf .evoskill-src && git clone --depth 1 https://github.com/sentient-agi/EvoSkill.git .evoskill-src
    uv tool install --editable ./.evoskill-src && ok "evoskill installed (editable)"
  fi
  export PATH="$HOME/.local/bin:$PATH"
fi
command -v evoskill &>/dev/null && ok "evoskill on PATH" || no "evoskill not on PATH — add \$HOME/.local/bin to PATH"

b "3/5  goose  (the Arena's agent harness — EvoSkill drives it; v1.25+)"
if command -v goose &>/dev/null; then ok "goose $(goose --version 2>/dev/null | awk '{print $2}')"; else
  if command -v brew &>/dev/null; then
    inf "installing goose via Homebrew…"; brew install block-goose-cli && ok "goose installed"
  else
    inf "installing goose via the official script…"
    curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash
    export PATH="$HOME/.local/bin:$PATH"; ok "goose installed"
  fi
fi

b "4/5  Arena CLI  (Sentient's platform tool)"
if command -v arena &>/dev/null; then
  ok "arena $(arena --version 2>/dev/null | awk '{print $2}')"
  inf "authenticating (opens browser / paste token) — skip if already logged in"
  arena auth login || inf "already authenticated, or run 'arena auth login' yourself"
else
  no "arena not found. Install it from the Sentient Arena dashboard onboarding:"
  inf "    1) Sign in at  https://arena.sentient.xyz"
  inf "    2) Follow 'Install the CLI' (one command they give you), then 'arena auth login'"
  inf "    3) Re-run this script."
  exit 1
fi

b "5/5  API key"
if [ -n "${OPENROUTER_API_KEY:-}" ]; then ok "OPENROUTER_API_KEY is set"; else
  no "OPENROUTER_API_KEY not set."
  inf "Get one at https://openrouter.ai/keys , then:  export OPENROUTER_API_KEY=sk-or-..."
  inf "(EvoSkill evolves with it; the Arena eval itself uses Sentient's keys.)"
fi

echo
b "Setup complete. Next:"
inf "  ./scripts/improve.sh     # evolve your OfficeQA skill with EvoSkill"
inf "  ./scripts/submit.sh      # ship the improved skill to Challenge 1"
echo
inf "Tip: if 'arena'/'evoskill'/'goose' aren't found in a new shell, add to your profile:"
inf '  export PATH="$HOME/.local/bin:$PATH"'
