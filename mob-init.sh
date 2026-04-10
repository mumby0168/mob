#!/bin/bash
# mob-init: Initialize mob programming mode in the current repo
# Usage: mob-init <your-name> [session-goal]

set -e

NAME="${1}"
GOAL="${2:-}"

if [ -z "$NAME" ]; then
  echo "Usage: mob-init <your-name> [session-goal]"
  echo ""
  echo "Examples:"
  echo "  mob-init alice"
  echo "  mob-init alice \"Ship the auth refactor\""
  exit 1
fi

# Check we're in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: not inside a git repository."
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
MOB_DIR="$REPO_ROOT/.mob"

# Create .mob directory
mkdir -p "$MOB_DIR"

# Create or update session.md
if [ ! -f "$MOB_DIR/session.md" ]; then
  cat > "$MOB_DIR/session.md" << EOF
# Mob Session

## Goal
${GOAL:-TODO: define session goal}

## Plan
TODO: break down the work

## Engineers
- $NAME
EOF
  echo "Created $MOB_DIR/session.md"
else
  # Add engineer to session if not already listed
  if ! grep -q "^- $NAME" "$MOB_DIR/session.md"; then
    echo "- $NAME" >> "$MOB_DIR/session.md"
    echo "Added $NAME to session.md"
  else
    echo "$NAME already in session.md"
  fi
fi

# Create engineer context file
cat > "$MOB_DIR/$NAME.md" << EOF
# $NAME — Mob Context

## Last Updated
$(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Current Focus
Just joined the mob session.

## Just Completed
—

## Next Up
Waiting for session plan.

## Notes for Other Engineer
Just initialized. Ready to go.
EOF
echo "Created $MOB_DIR/$NAME.md"

# Add .mob to .gitignore exclusion (make sure it's tracked)
# Some repos gitignore dot-directories — ensure .mob is tracked
if [ -f "$REPO_ROOT/.gitignore" ]; then
  if grep -q "^\.\*" "$REPO_ROOT/.gitignore" 2>/dev/null; then
    if ! grep -q "^!\.mob" "$REPO_ROOT/.gitignore" 2>/dev/null; then
      echo "!.mob/" >> "$REPO_ROOT/.gitignore"
      echo "Added .mob/ exception to .gitignore"
    fi
  fi
fi

# Append mob instructions to CLAUDE.md if it exists, or create it
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
MOB_MARKER="# Mob Programming Mode"

if [ -f "$CLAUDE_MD" ]; then
  if ! grep -q "$MOB_MARKER" "$CLAUDE_MD"; then
    echo "" >> "$CLAUDE_MD"
    echo "---" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
    cat "$(dirname "$0")/CLAUDE-MOB.md" >> "$CLAUDE_MD" 2>/dev/null || cat "$MOB_DIR/../CLAUDE-MOB.md" 2>/dev/null || {
      echo "Warning: Could not find CLAUDE-MOB.md to append. Copy it manually."
    }
    echo "Appended mob instructions to CLAUDE.md"
  else
    echo "CLAUDE.md already has mob instructions"
  fi
else
  cp "$(dirname "$0")/CLAUDE-MOB.md" "$CLAUDE_MD" 2>/dev/null || {
    echo "Warning: Could not find CLAUDE-MOB.md. Create CLAUDE.md manually."
  }
  echo "Created CLAUDE.md with mob instructions"
fi

echo ""
echo "Mob mode initialized for $NAME."
echo ""
echo "Next steps:"
echo "  1. git add .mob/ CLAUDE.md && git commit -m 'mob: init session' && git push"
echo "  2. Other engineer runs: mob-init <their-name>"
echo "  3. Start your Claude Code session — it will read .mob/ automatically"
