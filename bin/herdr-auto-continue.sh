#!/bin/bash
# herdr-auto-continue.sh <workspace:pane>
# Watches a Claude Code session running in a herdr pane and automatically
# sends "continue" once the usage-limit reset arrives.
#
# Usage: herdr-auto-continue.sh w1:p1
set -u

PANE="${1:?usage: $0 <workspace:pane>}"
LIMIT_PATTERN='usage limit|limit reached|resets'
POLL_SECONDS=300

pane_shows_limit() {
  herdr pane read "$PANE" --source visible --lines 40 | grep -qiE "$LIMIT_PATTERN"
}

send_continue() {
  herdr pane send_text "$PANE" "continue"
  herdr pane send_keys "$PANE" "enter"
}

while true; do
  # Wait until the agent stops and is waiting for input.
  herdr wait agent-status "$PANE" --status blocked

  if pane_shows_limit; then
    echo "$(date) limit detected on $PANE, polling until reset..."
    while pane_shows_limit; do
      sleep "$POLL_SECONDS"
      # Try to resume; while still limited this is rejected and harmless.
      send_continue
      sleep 10
    done
    echo "$(date) resumed $PANE."
  else
    # Blocked for another reason (e.g. waiting on a question) — leave it alone.
    sleep 60
  fi
done
