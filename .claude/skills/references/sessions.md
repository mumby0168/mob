# Session Management — Reference

## Directory Structure

```
.mob/
  current                    # plain text file containing active session name
  auth-refactor/
    session.md
    alice.md
    bob.md
  api-redesign/
    session.md
    alice.md
    carol.md
```

## The `current` File

`.mob/current` is a plain text file containing the name of the active session directory. One line, no newline fuss.

```bash
cat .mob/current
# → auth-refactor
```

When switching sessions or starting new ones, update this file.

## Starting a New Session (When Others Exist)

Check existing sessions first:

```bash
ls -d .mob/*/
cat .mob/current
```

Tell the engineer what sessions exist: "There's an existing `auth-refactor` session from yesterday. Want to start a fresh session or continue that one?"

If starting new:

```bash
SESSION="new-session-name"
mkdir -p .mob/$SESSION
echo "$SESSION" > .mob/current
```

Then create `session.md` and your engineer's context file as described in `init.md`.

## Switching Sessions

```bash
echo "other-session-name" > .mob/current
```

Then read the session context:

```bash
cat .mob/other-session-name/session.md
cat .mob/other-session-name/*.md
```

Summarize the state to the engineer before continuing work.

## Closing a Session

When a session is done, update its `session.md`:

```markdown
## Status
complete

## Completed
<date>

## Summary
<2-3 sentences on what was accomplished>
```

Don't delete the directory. Old sessions are useful context for future work. They're small files and won't cause problems.

If there's another active session, switch to it. If not, remove the `current` pointer:

```bash
rm .mob/current
```

## Listing Sessions

If the engineer asks "what sessions do we have?" or similar:

```bash
for dir in .mob/*/; do
  name=$(basename "$dir")
  status=$(grep -A1 "## Status" "$dir/session.md" 2>/dev/null | tail -1)
  echo "$name: $status"
done
```

Show them in a readable format:
- `auth-refactor: active`
- `api-redesign: complete (2026-04-03)`
