#!/usr/bin/env bash
# Human-in-the-loop reproduction loop.
# The agent copies this file and edits the scenario between the markers.
# The user runs the copy in their terminal and pastes its output back.
#
# Usage:
#   bash hitl-loop.template.sh
#
# Two helpers:
#   step "<instruction>"          → show instruction, wait for Enter
#   capture VAR "<question>"      → show question, read response into VAR
#
# At the end, captured values are printed as KEY=VALUE, then one verdict line.
# Exit codes: 1 = RED, the exact symptom reproduced; 0 = GREEN, symptom absent;
# 2 = INCOMPLETE, input ended early or the observation matched neither.
#
# `capture` prints its value back to the terminal, where the agent reads it,
# so capture observations, and leave signing in to the user as a `step`.

set -euo pipefail

incomplete() {
  printf '\nINCOMPLETE: %s\n' "$1" >&2
  exit 2
}

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _ || incomplete "Input ended before the step completed."
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer || incomplete "Input ended before an observation was captured."
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message with secrets replaced by <REDACTED> (or 'none'):"

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"

if [[ "$ERRORED" == y && "$ERROR_MSG" == *'Unexpected token'* ]]; then
  printf 'RED: Export threw the reported Unexpected token error.\n'
  exit 1
elif [[ "$ERRORED" == n && "$ERROR_MSG" == none ]]; then
  printf 'GREEN: Export completed without the reported error.\n'
  exit 0
else
  incomplete "Observation matches neither the reported symptom nor its absence; check the captured values."
fi

# --- edit above ---------------------------------------------------------
