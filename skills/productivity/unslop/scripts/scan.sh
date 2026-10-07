#!/usr/bin/env bash
# Scans files for the unslop rules a regex can catch and prints one hit per line
# as "<file>:<line>: rule <n>: <match>". Every rule still needs a reading pass.
#
# Candidate patterns (partial coverage; stable rule ids from SKILL.md):
#   7  AI vocabulary        the word list of rule 7; "landscape" and "tapestry"
#                           are flagged in every sense, so judge the abstract uses
#   8  fancy "is"           serves as, stands as, boasts, features
#   9  not just X, but Y    "not just/only/merely ... but" (also "n't just") inside one sentence
#   13 em dash overuse      em dash, en dash, or a spaced hyphen run between words
#                           (table rules between pipes are skipped)
#   19 curly quotes         the four curly quote characters
#   20 chatbot phrases      the phrases listed in rule 20
#   23 filler phrases       the phrases listed in rule 23
#   31 plain word           utilize, leverage, facilitate, numerous, in the event that
#
# Usage: scripts/scan.sh <file>...
# Exit 0 when nothing matched, 1 on any hit, 2 on a usage, input, or grep error.
set -u

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <file>..." >&2
  exit 2
fi
for f in "$@"; do
  if [ ! -f "$f" ] || [ ! -r "$f" ]; then
    echo "not a readable file: $f" >&2
    exit 2
  fi
done

hits=0

# scan <rule> <extended regex> <file>...
# Word-bounded patterns use [^[:alpha:]] rather than \b so BSD and GNU grep agree.
scan() {
  local rule="$1" re="$2"
  shift 2
  local out status
  if out=$(grep -n -H -i -o -E -- "$re" "$@"); then
    :
  else
    status=$?
    if [ "$status" -eq 1 ]; then return 0; fi
    echo "scan failed: grep exited $status for rule $rule" >&2
    exit 2
  fi
  # ".*" rather than "[^:]*" so a colon inside the filename keeps the rule label.
  printf '%s\n' "$out" | sed -E "s/^(.*:[0-9]+:)[[:space:]]*/\1 rule $rule: /; s/[[:space:]]+\$//"
  hits=$((hits + $(printf '%s\n' "$out" | wc -l)))
}

W='(^|[^[:alpha:]])'   # left word boundary
E='([^[:alpha:]]|$)'   # right word boundary

scan 7  "${W}(additionally|crucial|delve|delves|delving|enduring|enhance|enhances|enhanced|enhancing|fostering|garner|garners|garnered|interplay|intricate|landscape|pivotal|showcase|showcases|showcasing|tapestry|testament|underscore|underscores|underscoring|vibrant)${E}" "$@"
scan 8  "${W}(serves as|stands as|boasts|features)${E}" "$@"
scan 9  "(${W}not|n('|’)t) (just|only|merely) [^.!?]* but${E}" "$@"
scan 13 '—|–|[^[:space:]|] +-+ +[^[:space:]|]' "$@"
# Alternation instead of a bracket expression, so a non-UTF-8 locale cannot split the characters into bytes.
scan 19 '“|”|‘|’' "$@"
scan 20 'i hope this helps|let me know if|of course!|certainly!|smoking gun' "$@"
scan 23 "${W}(in order to|due to the fact that|it is important to note that)${E}" "$@"
scan 31 "${W}(utiliz(e|es|ed|ing)|leverag(e|es|ed|ing)|facilitat(e|es|ed|ing)|numerous|in the event that)${E}" "$@"

if [ "$hits" -gt 0 ]; then
  echo "$hits hit(s); every rule still needs reading" >&2
  exit 1
fi
echo "no regex hits; every rule still needs reading" >&2
exit 0
