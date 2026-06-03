<div align="center">

# 🏆 Sentient Arena × EvoSkill — Challenge 1 Quickstart

**Evolve a state-of-the-art OfficeQA agent and submit it to [Sentient Arena](https://arena.sentient.xyz) Challenge 1 — in minutes.**

Clone → run → submit. No Docker. One API key.

[![EvoSkill](https://img.shields.io/badge/Powered%20by-EvoSkill-f73c6f?style=for-the-badge)](https://github.com/sentient-agi/EvoSkill)
[![Sentient Arena](https://img.shields.io/badge/Compete-Sentient%20Arena-007ec6?style=for-the-badge)](https://arena.sentient.xyz)
[![Discord](https://img.shields.io/badge/Join-Discord-5865F2?style=for-the-badge)](https://discord.gg/sentientfoundation)

</div>

---

This repo pairs **[EvoSkill](https://github.com/sentient-agi/EvoSkill)** — Sentient's toolkit that *automatically discovers and improves agent skills from failure traces* — with a **seed skill that won the highest-accuracy axis in Sentient Arena Cohort 0**. EvoSkill starts from that playbook and evolves it further, then we ship the result straight into Challenge 1.

> Built by [Leon Liu / Dolores Research](https://doloresresearch.com). The seed is the exact grounded-reasoning playbook (stdlib-only computation, corrected statistical formulas, scorer-format discipline, fiscal-year/unit traps) from a #1 Arena finish — now open for the whole community to build on.

## TL;DR

```bash
git clone https://github.com/<you>/sentient-arena-evoskill-quickstart.git
cd sentient-arena-evoskill-quickstart

./scripts/setup.sh      # install uv + EvoSkill + check arena-cli + keys
./scripts/improve.sh    # EvoSkill evolves the OfficeQA skill (shows before → after)
./scripts/submit.sh     # drop the evolved skill into your agent → submit to Challenge 1
```

That's the whole loop. The sections below explain what each step does.

## Why this exists

Challenge 1 (the `office-qa` competition) asks agents to compute precise answers from ~700 U.S. Treasury Bulletin documents — grounded numeric reasoning that rewards *discipline* over raw model size. Two facts shape everything:

1. The eval **forces MiniMax M2.7** and runs in a **bare container** (no `numpy`/`scipy`, no internet).
2. The biggest wins are **behavioral** — the right skill turns a generic agent into a specialist.

EvoSkill automates finding that skill. This quickstart removes every other piece of friction so you can go from zero to a submitted, *improved* agent today.

## Prerequisites

| You need | Get it |
|---|---|
| **Python 3.12+** & `uv` | `setup.sh` installs `uv` for you |
| **An OpenRouter key** | [openrouter.ai/keys](https://openrouter.ai/keys) → `export OPENROUTER_API_KEY=sk-or-...` |
| **A Sentient Arena account + CLI** | Sign in at [arena.sentient.xyz](https://arena.sentient.xyz), install the CLI from the onboarding, `arena auth login` |

No Docker. EvoSkill drives **goose** — the Arena's own harness — locally (setup installs it for you). Evolving through the *same harness and model the Arena runs at eval* means your skill is tuned to exactly what scores your submission.

## Step 1 — Setup

```bash
./scripts/setup.sh
```
Installs `uv`, installs **EvoSkill** from GitHub, checks that **arena-cli** is present + authenticated, and verifies your `OPENROUTER_API_KEY`. Idempotent — safe to re-run.

## Step 2 — Evolve the skill

```bash
./scripts/improve.sh
```
This runs EvoSkill on a **10-question OfficeQA sample** (bundled in `evoskill-project/data/`, fully self-contained) using **goose + MiniMax M2.7 via OpenRouter** — the same harness and model the Arena uses at eval. EvoSkill:

1. **Runs** the current skill on the questions and collects failures.
2. **Proposes** targeted skill edits to fix them.
3. **Evaluates** each variant on a held-out split.
4. **Keeps** the winners on `program/*` git branches.

You'll see a live table climb:
```
  Iter  Accuracy  Δ          Skills  Frontier  Status
  1     ...%      —          1       [1]       baseline (your seed)
  2     ...%      +...%      1       [1, 2]    ★ new best
```
The evolved skill lands in `evoskill-project/.claude/skills/`. Inspect what changed with `evoskill diff`.

> **Want stronger edits?** `./scripts/improve.sh .evoskill/config.advanced.toml` evolves with **Claude Sonnet** (a much stronger proposer) and relies on EvoSkill's **cross-model transferability** — the gain still carries to M2.7 at eval. Needs `ANTHROPIC_API_KEY`.

## Step 3 — Submit to Challenge 1

```bash
./scripts/submit.sh            # or  --dry-run  to wire it up without submitting
```
This is the bridge EvoSkill's own demo doesn't include: it copies the evolved skill into the **Arena agent** (`arena-agent/`, a ready `office-qa` project running goose + M2.7), validates the config with `arena test --dry-run`, and — after you confirm — runs `arena submit`. Check your score with `arena history`.

> Arena allows **1 submission/day**. The baseline skill is backed up to `arena-agent/.skills_baseline/` in case you want to revert.

## How it works

```
evoskill-project/                     arena-agent/
  .claude/skills/officeqa-playbook/      arena.yaml            (office-qa, goose, M2.7)
        ▲  seed = Arena-winner playbook  prompts/officeqa_prompt.j2
        │                                skills_consolidated/  ◄── submit.sh drops the
  EvoSkill evolves it  ───────────────────────────────────────    evolved skill here
  .evoskill/config.toml  (M2.7 via OpenRouter, local, no Docker)
  data/  (10 sample questions + 9 source docs)
```

- **The seed skill** (`evoskill-project/.claude/skills/officeqa-playbook/SKILL.md`) is the differentiator — a real #1-Arena playbook, so EvoSkill starts from a strong baseline instead of scratch.
- **EvoSkill** does the search; you do nothing but watch the accuracy climb.
- **The bridge** turns the evolved skill into a real leaderboard submission.

## Scaling up (optional)

The bundled 10 questions make the demo fast. For a serious run, point `.evoskill/config.toml` `[dataset] path` at a larger OfficeQA CSV and add the full corpus to `data_dirs`, then raise `[evolution] iterations`. More questions + more iterations = stronger skills (and more API spend).

## Credits & links

- **EvoSkill** — [github.com/sentient-agi/EvoSkill](https://github.com/sentient-agi/EvoSkill) · [paper](https://arxiv.org/abs/2603.02766) · [blog](https://www.sentient.xyz/blog/evoskill-automated-skill-induction-from-agent-failures)
- **Sentient Arena** — [arena.sentient.xyz](https://arena.sentient.xyz) · [Discord](https://discord.gg/sentientfoundation)
- **Seed playbook & this quickstart** — [Leon Liu / Dolores Research](https://doloresresearch.com)

Licensed Apache-2.0, matching EvoSkill. PRs and skill contributions welcome — share your evolved skills in the Sentient Discord!
