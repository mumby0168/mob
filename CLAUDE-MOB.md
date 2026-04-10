# Mob Programming Mode

You are in a **mob session**. Multiple engineers are working on this codebase simultaneously, each with their own Claude Code instance. Follow these rules strictly.

## Git Discipline

- **Pull before every task.** Before starting any work, run `git pull --rebase` first.
- **Commit early and often.** Small, atomic commits. Don't batch up large changes.
- **Push after every commit.** Never sit on local commits.
- **Pull after every push.** Check if the other engineer pushed while you were working.
- **On conflict:** pull, rebase, resolve, then continue. Never force push.

## Mob Context — `.mob/` Directory

A shared context directory exists at `.mob/` in the repo root. This is how you and the other Claude instance stay in sync.

### Structure

```
.mob/
  session.md       # Current session metadata
  <engineer>.md    # One file per engineer (e.g., alice.md, bob.md)
```

### Reading Context

**Every time you pull**, read all files in `.mob/`:
1. Read `session.md` for the session goal and plan
2. Read every `<engineer>.md` file — including your own and the other engineer's
3. Use this context to understand what's been done, what's in progress, and what's planned

### Writing Context

**Every time you commit**, update your engineer's `.mob/<engineer>.md` file with:

```markdown
# <Engineer Name> — Mob Context

## Last Updated
<timestamp>

## Current Focus
What you're working on right now.

## Just Completed
What you finished in the last commit(s). Be specific — file names, function names, what changed and why.

## Next Up
What you plan to do next.

## Notes for Other Engineer
Anything the other pair needs to know — gotchas, decisions made, questions, suggestions. This is the most important section.
```

Keep it concise. This isn't documentation — it's a handoff note.

### On Session Start

If `.mob/session.md` doesn't exist or looks stale, ask the engineer what the session goal is and create/update it:

```markdown
# Mob Session

## Goal
<what we're building/fixing/shipping today>

## Plan
<high-level breakdown of tasks>

## Engineers
- <name-1>
- <name-2>
```

## Workflow

The typical loop:

1. `git pull --rebase`
2. Read `.mob/*.md`
3. Discuss with your engineer what to work on
4. Do the work
5. Update `.mob/<engineer>.md`
6. `git add -A && git commit -m "<msg>"` (include .mob/ files)
7. `git push`
8. Repeat

## Parallel Work

When both pairs are working simultaneously on different tasks:
- Stay in your lane. Check the other engineer's "Current Focus" to avoid stepping on each other.
- If you need to touch a file the other pair is working on, mention it in "Notes for Other Engineer" and commit your context update first before making changes.
- Pull more frequently during parallel work — every few minutes, not just between tasks.

## Turn-Based Work

When taking turns (one pair works, then the other):
- The "Notes for Other Engineer" section is your primary handoff mechanism.
- Be explicit about what's done and what's left.
- If you hit a blocker or made a tradeoff, explain why.
