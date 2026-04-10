# Turn Log Format — Reference

The turn log at `.mob/<session>/log.md` is an append-only timeline of the mob session.
Both Claude instances write to it. Neither should edit previous entries.

## Entry Format

Append one entry per turn (per response you give):

```markdown
---
### Turn <N> | <engineer-name> | <ISO timestamp>

**Prompt:** <1-2 sentence summary of what the engineer asked or said>

**Action:** <what you did — files changed, decisions made, outcome>

**Status:** <working | committed | blocked | context-update>
```

## Field Rules

### Turn Number

Sequential per engineer within the session. Engineer A has turns 1, 2, 3... and Engineer B
has their own turns 1, 2, 3... Prefix with the engineer initial if helpful for scanning:

```
### Turn A-4 | alice | 2026-04-06T14:32:00Z
### Turn B-7 | bob | 2026-04-06T14:35:00Z
```

### Prompt Summary

Sanitise the engineer's prompt. The point is intent, not the raw text.

**Do:**
- "Asked to add input validation to the signup form"
- "Wants to refactor the database layer to use connection pooling"
- "Debugging the 500 error on the /users endpoint"

**Don't:**
- Copy the prompt verbatim
- Include API keys, passwords, personal info, internal URLs
- Include long code blocks the engineer pasted in

If the engineer's turn was conversational (e.g., "yeah let's do that" or "looks good"), log it
as: "Confirmed approach. Proceeding with implementation."

### Action Summary

What you actually did. Be specific but concise.

**Good:**
- "Added `validateInput()` to `signup.controller.ts`. New validation schema in `schemas/signup.ts`. Tests passing."
- "Refactored `db.ts` to use pg-pool. Updated 4 query functions. Connection limit set to 20."
- "Found the 500 was a null ref in `getUser()` — added null check at line 47. Fixed."

**Bad:**
- "Made changes to the code"
- "Fixed the issue"
- "Worked on the feature"

### Status

One of:
- `working` — in progress, not committed yet
- `committed` — code committed and pushed this turn
- `blocked` — hit a blocker, needs input or the other engineer's help
- `context-update` — this turn was a session context change, not a code change

## Reading the Log

When you pull and read the log, focus on:

1. **Last 5-10 entries** — what happened recently
2. **Any `blocked` entries** — is the other engineer stuck on something you can help with?
3. **Context-update entries** — did the plan or scope change?
4. **The sequence** — if the other engineer spent 6 turns on something, it was complex. Factor that into your understanding.

Don't read the entire log aloud to the engineer. Summarise: "Rob had 5 turns since your last session — he shipped the middleware, hit a blocker on the token format, resolved it by switching to signed JWTs, and suggests we tackle refresh next."

## Log Size

The log will grow. That's fine. For very long sessions (50+ turns), you can summarise older
entries into a `log-archive.md` and keep only the last 20-30 entries in `log.md`. But don't
do this preemptively — only when the file is getting unwieldy.

## Connection to Commits

Reference turn ranges in commit messages:

```
mob(auth): add refresh endpoint [turns A-4:A-7]
mob(db): fix migration [turns B-12]
```

This lets anyone reading git log understand the reasoning by checking the turn entries.
