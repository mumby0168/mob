---
name: mob
description: >
  AI mob programming mode for collaborative coding sessions. Use this skill whenever
  the user mentions mobbing, mob programming, mob sessions, pair programming with
  another engineer, or working on a shared branch with someone else. Trigger phrases
  include: "mob with", "mobbing with", "start a mob", "continue the mob", "mob session",
  "resume mob", "pair with <n>", "working with <n> on the same branch", or any
  reference to collaborative coding with another engineer who also has Claude Code.
  Also trigger if the user says "let's mob", mentions the .mob directory, or if the
  current git branch starts with "mobbing/" (e.g. mobbing/auth-refactor). The branch
  prefix "mobbing/" is itself a signal that mob mode should be active — even if the
  user hasn't explicitly asked for it. Check the branch name early in the session.
---

# Mob Programming Mode

You are entering mob programming mode. Two engineers, each with their own Claude Code
instance, sharing a branch and a context directory. You are one engineer's driver.
The other engineer has their own Claude. You stay in sync through git and `.mob/`.

## First: Determine Session State

Before doing anything, check two things:

### 1. Check the branch name

```bash
git branch --show-current
```

If the branch starts with `mobbing/`, you are in a mob session. The session name is
the part after the prefix (e.g. `mobbing/auth-refactor` → session name `auth-refactor`).

Enter mob mode automatically. Don't wait for the engineer to say anything about mobbing.
Tell them: "You're on `mobbing/<n>` — I'm in mob mode. Let me check the session context."

If the branch does NOT start with `mobbing/` but the engineer asked to mob, create the branch:

```bash
git checkout -b mobbing/<session-name>
git push -u origin mobbing/<session-name>
```

The branch name is the canonical identifier for the mob session. It should match the
session directory name under `.mob/`.

### 2. Check for .mob/ directory

```bash
ls .mob/ 2>/dev/null
```

**If `.mob/` doesn't exist** → New mob. Read `references/init.md` for setup.

**If `.mob/` exists** → Look for a session matching the branch name:
```bash
ls .mob/
cat .mob/current
```

If a session directory matches the branch (e.g. `.mob/auth-refactor/` for branch
`mobbing/auth-refactor`), resume it. If no match, ask:
- "There's no session for this branch yet. Want me to set one up?"
- Or if other sessions exist: "I see `api-redesign` from earlier. This branch is
  `mobbing/auth-refactor` — want me to start a new session for it?"

Read `references/init.md` for both new session and resume flows.

## Session Context Setup

When starting a new mob session, the first engineer sets the mob context. This is a deliberate
phase before any code gets written. Don't skip it.

### The Setup Flow

1. Ask: "What's the goal for this mob? What are we trying to ship?"
2. Help the engineer articulate the plan — break it into concrete tasks
3. Write this to `.mob/<session>/session.md`
4. Ask: "Does this look right? Anything to add or change?"
5. Let them refine. They might add constraints, technical notes, edge cases, scope boundaries.
6. Once confirmed, commit the session context: `mob(context): set up mob session <n>`
7. Now the other engineer can pull and their Claude has full context from turn one.

The session context isn't static. Either engineer can update it during the mob. Be smart about
detecting when someone wants to adjust the mob context vs when they're talking about code:

**Signals the engineer wants to update mob context:**
- "Actually let's change the plan"
- "Add X to the session goals"
- "We should note that we decided to..."
- "The scope changed — we're also going to..."
- "Let's not do X anymore"
- "Rob and I just agreed to..."
- Any statement about the plan, scope, approach, or shared decisions (not a specific file or function)

When you detect these signals, update `session.md` and/or the context files, then commit+push
the context change on its own so the other Claude picks it up immediately.

Don't mix context updates with code changes in the same commit when possible. A context-only
commit like `mob(context): narrow scope to auth endpoints only` makes the log cleaner and
ensures the other Claude sees the decision before the code that follows from it.

**Signals the engineer is talking about code (not context):**
- Referencing specific files, functions, errors
- Asking you to write, fix, or refactor something
- Debugging, testing, reviewing

These are normal coding turns. Don't update session.md for these — just the engineer's context file.

## Turn Log

Every mob session has a turn log at `.mob/<session>/log.md`. This is an append-only record
of what happened in the session. Read `references/log-format.md` for the full format.

### What gets logged

On every turn (every response you give), append an entry:

- **Timestamp**
- **Engineer** — who you're working with
- **Prompt summary** — a 1-2 sentence sanitised summary of what the engineer asked. Not the raw prompt. Strip sensitive content, credentials, personal info. Capture the intent.
- **Action summary** — what you did in response. Files changed, decisions made, outcome.
- **Turn number** — sequential count for this engineer in this session

### Why this matters

The log gives the other Claude a timeline, not just a snapshot. When the other engineer's Claude
pulls and reads the log, it can see the sequence of decisions (not just the latest one), what was
tried and abandoned, the pace of work, and questions that were asked and answered.

### Commit references

When you commit, reference the log entry range in the commit message:

```
mob(auth): add refresh endpoint [turns A-4:A-7]
```

This connects git history to the session narrative. The other engineer can read those turn entries
to understand not just what changed but the reasoning path that got there.

## Core Operating Rules

These rules apply for the ENTIRE session once mob mode is active. Not just once — every turn.

### Rule 1: Commit and Push as One Action

Every time you finish a piece of work — even small — commit and push together. Never do one without the other. Always include your `.mob/<engineer>.md` context update in the same commit.

```bash
# Update your context file first, then:
git add -A
git commit -m "<type>: <description>"
git push
```

Offer to commit after every meaningful change. Don't wait to be asked. Say something like:
"That's working. Want me to commit and push so Rob can see it?"

If the engineer says "yeah" or "go for it" or anything affirmative to a commit offer, just do it. Don't ask twice.

### Rule 2: Pull Every 2 Turns

Count your turns. Every 2 conversational turns (your responses), do a pull:

```bash
git pull --rebase
```

Then re-read `.mob/*.md` to pick up anything the other engineer's Claude wrote.

If there are changes from the other engineer, briefly summarize: "Rob just pushed — he refactored the auth middleware and notes that the token format changed. Want me to review what he did?"

If there's a conflict, resolve it. Don't ask the engineer to do it manually unless it's a genuine ambiguity that needs a human decision.

### Rule 3: Read Context on Every Pull

After every `git pull`, read ALL files in `.mob/<session>/`:

1. `session.md` — the session goal, plan, and decisions
2. Every `<engineer>.md` file — what each person is working on
3. `log.md` (last 10-15 entries) — the recent timeline of what happened

This is non-negotiable. The context files are how you know what the other pair is doing.
The log tells you *how they got there*.

### Rule 4: Write Context and Log on Every Commit

Before every commit, do two things:

**Update your engineer's context file** — read `references/context-format.md` for the format:
- **Current Focus** — what you're doing now
- **Just Completed** — what this commit contains
- **Next Up** — what you plan to do after this
- **Notes for Other Engineer** — gotchas, decisions, questions

**Append to the turn log** — read `references/log-format.md` for the format. Log every turn,
not just commits. The log entry should summarise what the engineer asked (sanitised) and what
you did. Reference the turn range in the commit message:

```
mob(auth): add refresh endpoint [turns A-4:A-7]
```

### Rule 5: Offer, Don't Wait

Be proactive about the mob workflow:
- "Want me to commit and push this?"
- "It's been a couple of turns — let me pull to check for updates."
- "I see Rob pushed changes to the same area. Let me pull and check before we continue."
- "Should I update the session plan now that we've finished the API layer?"

## Commit Message Format

Use conventional commits. Keep them short. The context file has the details.

```
mob(<area>): <what changed> [turns <range>]
```

Examples:
- `mob(auth): add JWT refresh endpoint [turns A-4:A-7]`
- `mob(db): fix migration ordering [turns B-12]`
- `mob(context): update session plan`

## Session Management

Multiple sessions can exist in `.mob/`. Each session has its own directory:

```
.mob/
  current → file containing active session name
  auth-refactor/
    session.md
    log.md
    alice.md
    bob.md
  api-redesign/
    session.md
    log.md
    alice.md
    carol.md
```

The active session should match the current `mobbing/<n>` branch. If you switch branches
to a different `mobbing/` branch, switch the active session to match.

Read `references/sessions.md` for how to manage multiple sessions.

## Parallel vs Turn-Based Work

**Turn-based** (one pair works, then the other):
- Your "Notes for Other Engineer" section is the handoff. Be detailed.
- Summarize what's done and what's remaining.

**Parallel** (both pairs working simultaneously):
- Check the other engineer's "Current Focus" before starting work.
- If you need to touch a file they're working on, commit your context update first as a heads-up.
- Pull more frequently — every turn instead of every 2 turns.
- Say: "Rob's working on the middleware. I'll stay out of that file. Let me work on the route handlers instead."

## Ending a Session

When the engineer says they're done mobbing:

1. Do a final context update with a summary of everything accomplished
2. Commit and push
3. Update `session.md` with a final status
4. Ask: "Want to keep the session open for next time or close it out?"

If closing: mark session.md status as `complete` with a date.
