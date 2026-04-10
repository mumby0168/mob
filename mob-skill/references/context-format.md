# Context File Format — Reference

Each engineer has a context file at `.mob/<session>/<engineer>.md`. This is the shared memory between the two Claude instances. Keep it concise — it's a handoff note, not documentation.

## Template

```markdown
# <Engineer Name> — Mob Context

## Last Updated
<ISO 8601 timestamp, e.g. 2026-04-06T14:30:00Z>

## Current Focus
One or two sentences. What are you actively working on right now?
Be specific: "Adding the /refresh endpoint to auth.routes.ts" not "working on auth."

## Just Completed
What the most recent commit(s) contain. File names, function names, what changed and why.
Keep it to 3-5 bullet points max. Example:

- Added `refreshToken()` to `auth.service.ts`
- New route `POST /auth/refresh` in `auth.routes.ts`
- Updated token config to support 7-day refresh window

## Next Up
What you plan to do next. One or two items. This helps the other engineer
know where you're headed so they don't duplicate work or conflict.

## Notes for Other Engineer
The most important section. Write what the other person needs to know:

- Decisions you made and why ("Went with signed JWTs because opaque tokens would need a DB lookup on every request")
- Gotchas ("The test suite expects the old token format — needs updating")
- Questions ("Should the refresh endpoint revoke the old token or let it expire?")
- Suggestions ("The error handling in middleware.ts is getting messy — might be worth extracting")

If you have nothing to say here, write "Nothing to flag." Don't leave it empty.
```

## Rules for Writing Context

1. **Update before every commit.** The context file and the code should always be in the same commit.
2. **Overwrite, don't append.** This file represents current state, not a log. Replace the content each time.
3. **Be specific.** File names, function names, line references. "Fixed the bug" is useless. "Fixed null check in `validateToken()` at auth.service.ts:47" is useful.
4. **Keep it short.** If your context file is longer than ~30 lines, you're writing too much. The other Claude can read the code — it just needs to know where to look and what to watch out for.
5. **Timestamp it.** Always update the "Last Updated" field. This tells the other Claude how stale the context is.

## Reading Context

When you pull and read context files:

1. Check the timestamp. If it's recent (last few minutes), the other engineer is actively working. Be aware of conflicts.
2. Check their "Current Focus." If it overlaps with what you're about to do, flag it to your engineer.
3. Check "Notes for Other Engineer." Act on anything relevant — answer questions, adjust your approach based on their decisions.
4. Don't read context aloud in full. Summarize the relevant bits: "Rob finished the middleware and suggests we extract the error handling. He's now working on the tests."
