# AI Mob Programming

Two engineers. Two AI agents. One shared brain.

A Claude Code skill for live collaborative coding sessions where each engineer has their own Claude instance, sharing context through git and a `.mob/` directory.

## What's in this package

```
ai-mob-programming/
├── index.html              # Landing page — open in a browser or share
├── mob-skill/              # The Claude Code skill
│   ├── SKILL.md            # Main skill file (install this)
│   └── references/
│       ├── init.md         # New session & resume flows
│       ├── context-format.md   # Engineer context file format
│       ├── log-format.md   # Turn log format
│       └── sessions.md     # Multi-session management
├── mob-init.sh             # Quick-start shell script (optional)
├── CLAUDE-MOB.md           # Standalone CLAUDE.md instructions (alternative to the skill)
└── README.md               # This file
```

## Quick start

### Option A: Install the skill (recommended)

1. Copy `mob-skill/` into your Claude Code skills directory
2. Check out a `mobbing/*` branch:
   ```bash
   git checkout -b mobbing/auth-refactor
   git push -u origin mobbing/auth-refactor
   ```
3. Start Claude Code. It detects the branch and enters mob mode.
4. Other engineer pulls the branch, starts their Claude Code. Done.

### Option B: Use the init script

1. Run in any repo:
   ```bash
   ./mob-init.sh alice "Ship the auth refactor"
   git add -A && git commit -m "mob: init" && git push
   ```
2. Other engineer: `git pull && ./mob-init.sh bob`

## How it works

Each Claude instance:
- Pulls every 2 turns and reads `.mob/` context files
- Writes a context update + turn log entry on every commit
- Commits and pushes as one action, frequently
- Detects when you're updating the session plan vs writing code
- References turn log entries in commit messages for traceability

No external services. No databases. Just git and markdown.

## The landing page

Open `index.html` in a browser to see a shareable explanation of the concept.
