# 🎬 EvoSkill × Sentient Arena — Tutorial Video Script

A shot-by-shot guide for a **~6–8 minute** tutorial. Goal: a viewer goes from "never heard of EvoSkill" to "I just submitted an evolved agent to Challenge 1." Tone: builder-to-builder, fast, no fluff.

**Pre-record checklist**
- [ ] Terminal at a large, readable font (18pt+), clean prompt, dark theme.
- [ ] `OPENROUTER_API_KEY` exported; arena-cli authenticated; VPN off / on a clean (non-datacenter) IP so the Arena CLI isn't Cloudflare-challenged.
- [ ] Use **`config.demo.toml`** for the on-camera run (tuned to show the climb). Do ONE full practice run beforehand to confirm it climbs and to learn the runtime; pre-stage that finished run to cut to (so viewers don't wait the full loop). If a run comes out flat, re-roll, or swap the model line to `openrouter/anthropic/claude-sonnet-4.6` for a stronger, more reliable climb.
- [ ] Browser tabs ready: the repo, [arena.sentient.xyz](https://arena.sentient.xyz) leaderboard, [EvoSkill repo](https://github.com/sentient-agi/EvoSkill).

---

## [0:00–0:35] Cold open / hook
**On screen:** you, talking head, or the Arena leaderboard.
**Say:**
> "I won the highest-accuracy spot in the last Sentient Arena. Today I'm going to show you how to take *my* winning playbook, have **EvoSkill automatically improve it**, and submit it to **Challenge 1** — in about five minutes, no Docker, one API key. Let's go."

**B-roll:** quick flash of the repo's three commands.

## [0:35–1:30] What & why (the 60-second mental model)
**On screen:** simple diagram — `seed skill → EvoSkill loop → evolved skill → Arena submission`.
**Say:**
> "Challenge 1 is grounded document reasoning over Treasury data. The eval forces one model — MiniMax M2.7 — in a bare container. So you can't win with a bigger model; you win with a better **skill**. EvoSkill is Sentient's tool that automatically discovers and improves agent skills from the agent's own failures. We seed it with a real Arena-winning playbook so it starts strong, not from scratch."

## [1:30–2:30] Step 1 — Setup
**On screen:** terminal.
```bash
git clone https://github.com/<you>/sentient-arena-evoskill-quickstart.git
cd sentient-arena-evoskill-quickstart
./scripts/setup.sh
```
**Say (over the install):**
> "One script installs `uv`, installs EvoSkill, and checks that the Arena CLI is set up and I've got an OpenRouter key. No Docker, no goose install — EvoSkill runs the agent locally."

**Cut** the install wait; resume on the green "Setup complete."

## [2:30–4:30] Step 2 — Evolve (the star moment)
**On screen:** terminal, then the live progress table.
```bash
./scripts/improve.sh .evoskill/config.demo.toml   # tuned so the accuracy climb reads clearly
```
**Say:**
> "Now the magic. EvoSkill runs my seed skill on OfficeQA questions, sees where it fails, proposes fixes, tests them on a held-out split, and keeps what works — automatically. Watch the accuracy climb."

**Show:** the `Iter / Accuracy / Δ / Status` table updating; point at a `★ new best` row.
**Then:**
```bash
evoskill diff
```
**Say:**
> "And here's exactly what it changed versus my baseline — new rules it discovered, in plain English. That's the part that used to take me days of manual iteration."

*(If the live run is long, cut to your pre-staged finished run here.)*

## [4:30–5:45] Step 3 — Submit to Challenge 1
**On screen:** terminal.
```bash
./scripts/submit.sh
```
**Say:**
> "Last step drops the evolved skill into a ready Arena agent, validates the config, and submits to Challenge 1. One submission a day, so I'll confirm…"

**Show:** type `y`, the `Submitted!` line, then:
```bash
arena history
```
**Say:**
> "There it is on the board. From clone to submitted, evolved agent — minutes."

## [5:45–6:30] The advanced tease + CTA
**Say:**
> "Want stronger skills? One flag evolves with Claude as the proposer and transfers the gain to M2.7 — EvoSkill's cross-model transferability. Repo's in the description: clone it, evolve your own, and drop your best skills in the Sentient Discord. Go compete in Challenge 1 — link below. See you on the leaderboard."

**End card:** repo URL · arena.sentient.xyz · Discord · "Built by Leon Liu / Dolores Research".

---

## Soundbites (for clips / the X thread)
- "You don't beat this benchmark with a bigger model. You beat it with a better skill — and EvoSkill finds that skill for you."
- "I open-sourced my Arena-winning playbook as the seed. EvoSkill takes it from there."
- "Clone, evolve, submit. No Docker, one API key, five minutes."

## Companion X/Twitter thread (draft)
1. I won highest-accuracy in Sentient Arena Cohort 0. Here's how to evolve an agent that good for **Challenge 1** — automatically — with @SentientAGI's EvoSkill. 🧵 (repo + video)
2. The trick: Challenge 1 forces one model in a bare box. You win on *skills*, not model size. EvoSkill discovers + improves skills from your agent's own failures.
3. I seeded it with my actual winning OfficeQA playbook so it starts strong. `./improve.sh` and watch accuracy climb. `evoskill diff` shows what it learned.
4. `./submit.sh` ships it straight to the leaderboard. No Docker, one key, minutes. Clone it, beat my score, and tell me in the @SentientAGI Discord. 👇
