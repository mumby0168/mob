# AI Mob Programming

Two engineers. Two Claude Code instances. One shared brain.

A Claude Code plugin for live collaborative coding sessions where each engineer has their own Claude instance, sharing context through git and a `.mob/` directory. No external services. No databases. Just git and markdown.

---

## Installation

This repo is a Claude Code plugin. Install it once and the `mob` skill is available in every repo you work in.

### Option 1: Install as a plugin (recommended)

Run this inside any Claude Code session:

```
/plugin marketplace add mumby0168/mob
/plugin install mob@mumby0168/mob
```

The skill will be available as `/mob` in every repo.

### Option 2: Install for a single project

If you only want the skill in one repo:

```
/plugin install mob@mumby0168/mob --scope project
```

This adds the plugin to that project's `.claude/settings.json` so teammates get it when they pull.

### Option 3: Clone alongside your repos

```bash
git clone https://github.com/mumby0168/mob.git
```

Claude Code will discover the skill from the sibling directory.

---

## Quick start

### Starting a mob session

Check out a `mobbing/*` branch — that prefix is the signal that mob mode is active:

```bash
git checkout -b mobbing/auth-refactor
git push -u origin mobbing/auth-refactor
```

Start Claude Code. It detects the branch automatically and enters mob mode. The other engineer pulls the branch and starts their own Claude Code instance. Done.

### First session in a repo (optional setup)

Run the init script to scaffold the `.mob/` context directory:

```bash
./mob-init.sh alice "Ship the auth refactor"
git add -A && git commit -m "mob: init" && git push
```

Other engineer: `git pull && ./mob-init.sh bob`

### Without the plugin

If you prefer not to use the plugin system, copy `CLAUDE-MOB.md` content into your repo's `CLAUDE.md`. This gives Claude the mob workflow without installing anything.

---

## How it works

Each Claude instance:

- Pulls every 2 turns and reads `.mob/` context files
- Writes a context update + turn log entry on every commit
- Commits and pushes as one action, frequently
- Detects when updating the session plan vs writing code
- References turn log entries in commit messages for traceability

The `.mob/` directory holds all shared state:

```
.mob/
└── <session-name>/
    ├── session.md      # Goal, plan, decisions, scope
    ├── alice.md        # Alice's current focus and notes
    ├── bob.md          # Bob's current focus and notes
    └── log.md          # Append-only turn log
```

---

## What's in this repo

```
mob/
├── .claude/
│   └── skills/
│       ├── mob.md              # The Claude Code skill
│       └── references/
│           ├── init.md         # New session & resume flows
│           ├── context-format.md   # Engineer context file format
│           ├── log-format.md   # Turn log format
│           └── sessions.md     # Multi-session management
├── .claude-plugin/
│   ├── plugin.json             # Plugin manifest
│   └── marketplace.json        # Marketplace metadata
├── docs/
│   └── index.html              # Landing page (served via GitHub Pages)
├── CLAUDE-MOB.md               # Standalone CLAUDE.md instructions (no plugin needed)
├── mob-init.sh                 # Quick-start shell script
└── README.md                   # This file
```

---

## The commit loop

Every commit follows this loop:

```
pull → read .mob/ → work → update context → write log → commit → push
```

Small, atomic commits. Frequent pushes. Both engineers stay in sync through the shared `.mob/` context rather than long explanations in chat.

---

## Landing page

The landing page is at [mumby0168.github.io/mob](https://mumby0168.github.io/mob) — a shareable explanation of the concept.
