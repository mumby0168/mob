# Init & Resume — Reference

## Starting a New Mob Session

You need two pieces of information:
1. The engineer's name (ask if not provided)
2. The session name/goal (ask if not provided)

### Create the directory structure

```bash
# Session name should be kebab-case, short, descriptive
SESSION_NAME="<session-name>"
ENGINEER="<engineer-name>"

mkdir -p .mob/$SESSION_NAME

# Point current session
echo "$SESSION_NAME" > .mob/current
```

### Create session.md

```markdown
# Mob Session: <Session Name>

## Status
active

## Started
<date>

## Goal
<what we're building/fixing/shipping>

## Plan
<break down the work into tasks — update this as the session progresses>

## Decisions
<shared decisions made during the mob — either engineer can add here>

## Scope
<what's in, what's explicitly out>

## Engineers
- <engineer-1>
- <engineer-2>
```

This is the **session context setup phase**. Don't rush it. Ask the engineer to describe the
goal. Help them break it into a plan. Ask about constraints and scope. Let them refine until
they confirm. Then commit: `mob(context): set up mob session <session-name>`

The other engineer's Claude will read this on their first pull and have full context immediately.

### Create log.md

```markdown
# Turn Log: <Session Name>

<!-- Append-only. Do not edit previous entries. -->
```

This file grows throughout the session. See `references/log-format.md` for entry format.

### Create the engineer's context file

```markdown
# <Engineer Name> — Mob Context

## Last Updated
<ISO timestamp>

## Current Focus
Starting the session. Setting up mob mode.

## Just Completed
Initialized mob session: <session-name>

## Next Up
<first task from the plan>

## Notes for Other Engineer
Just started the mob. Here's the plan: <brief summary>. Jump in wherever makes sense.
```

### Commit and push

```bash
git add .mob/
git commit -m "mob(init): start session <session-name>"
git push
```

Tell the engineer: "Mob session is set up. When <other-engineer> pulls and starts their Claude, it'll pick up the context. Ready to start on the first task?"

## Resuming an Existing Session

### Check what exists

```bash
cat .mob/current                        # which session is active
cat .mob/<session>/session.md           # goal, plan, decisions
cat .mob/<session>/*.md                 # all context files
tail -60 .mob/<session>/log.md          # recent turn history
```

### Summarize the state

Tell the engineer what you found:
- What the session goal is
- Key decisions from session.md
- What the other engineer last worked on (from their context file)
- Recent activity from the turn log (last 5-10 entries)
- Any notes or questions left for them

Example: "This is the auth-refactor session. Rob last pushed — he finished the JWT middleware and noted the token format changed from opaque to signed. His suggestion is you tackle the refresh endpoint next. Want to pick that up or do something else?"

### Update your context file

Update your `<engineer>.md` to reflect you're resuming:

```markdown
## Current Focus
Resuming session. Reviewing Rob's changes to the JWT middleware.
```

### Pull and continue

```bash
git pull --rebase
```

Then proceed with the work. Normal mob rules apply from here.

## When the Other Engineer Hasn't Initialized Yet

If `.mob/<session>/` only has one engineer file, the other person hasn't joined yet. That's fine — just work normally. When they join, they'll:

1. Pull
2. Run their own Claude Code
3. Their Claude reads `.mob/` and picks up full context
4. They create their own `<engineer>.md` file

You don't need to wait for them.
