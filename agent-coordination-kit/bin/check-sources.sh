#!/bin/bash
# CEO hourly check-in helper: fingerprint each lead's summary sections (read-only) and report which changed
# since the last run. Configure the SOURCES list below. State lives in .ceo-state/ (add it to .gitignore).
# Usage: bash bin/check-sources.sh   -> prints "CHANGED <name>" lines, or "NO CHANGE"
set -u
STATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/.ceo-state"
mkdir -p "$STATE_DIR"
NEW="$STATE_DIR/current.txt"; OLD="$STATE_DIR/last.txt"

# The "## STATE OF PLAY" section of a PENDING.md, up to the next "## " header.
sop() { awk 'on && /^## /{exit} /^## STATE OF PLAY/{on=1} on{print}' "$1" 2>/dev/null; }
# Newest session-log entry header.
lastlog() { grep '^## ' "$1" 2>/dev/null | tail -1; }
# Headings of a decision register (new rulings add headings).
heads() { grep -E '^#{2,3} ' "$1" 2>/dev/null; }
h() { shasum | cut -c1-12; }

# ---- configure: one line per source ----
{
  # echo "projectA.state_of_play $(sop /path/to/projectA/PENDING.md | h)"
  # echo "projectA.session_log $(lastlog /path/to/projectA/SESSION_LOG.md | h)"
  # echo "projectA.decisions $(heads /path/to/projectA/FEATURE_DECISIONS.md | h)"
  # echo "projectA.track_signals $(cat /path/to/protocol/projectA/guidance/signals/*.txt 2>/dev/null | h)"
  # echo "projectA.head $(git -C /path/to/projectA log -1 --format=%H 2>/dev/null)"
  :
} > "$NEW"

if [ ! -f "$OLD" ]; then echo "FIRST RUN (baseline saved)"; cp "$NEW" "$OLD"; exit 0; fi
changed=$(diff "$OLD" "$NEW" | awk '/^>/{print "CHANGED " $2}')
cp "$NEW" "$OLD"
if [ -n "$changed" ]; then echo "$changed"; else echo "NO CHANGE"; fi
