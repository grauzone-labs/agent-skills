#!/usr/bin/env bash
# Measure a skill against the checkable items of SKILL-REVIEW.md.
# Usage: scripts/measure.sh <skill-dir>
# Prints one "ok" or "FAIL" line per measurement; exits 1 when any FAIL.
set -u

dir="${1:?usage: measure.sh <skill-dir>}"
dir="${dir%/}"
skill="$dir/SKILL.md"
status=0

ok()   { printf 'ok    %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; status=1; }
info() { printf 'info  %s\n' "$1"; }

[ -f "$skill" ] || { fail "no SKILL.md in $dir"; exit 1; }

# Frontmatter is the block between the first two '---' lines; body is the rest.
frontmatter=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$skill")
body_lines=$(awk 'NR>1 && !done && $0=="---"{done=1; next} done{n++} END{print n+0}' "$skill")
field() { printf '%s\n' "$frontmatter" | awk -v k="$1" 'index($0, k":")==1{sub("^"k":[ ]*",""); print; exit}'; }

# --- Frontmatter
name=$(field name)
dirname_=$(basename "$dir")
[ "$name" = "$dirname_" ] && ok "name matches directory ($name)" || fail "name '$name' differs from directory '$dirname_'"
printf '%s' "$name" | grep -Eq '^[a-z0-9-]+$' && ok "name uses lowercase, digits, hyphens" || fail "name has characters outside [a-z0-9-]"
[ "${#name}" -le 64 ] && ok "name length ${#name} <= 64" || fail "name length ${#name} > 64"
printf '%s' "$name" | grep -Eqi 'anthropic|claude' && fail "name contains a reserved word" || ok "name has no reserved word"

desc=$(field description)
[ -n "$desc" ] && ok "description present (${#desc} chars)" || fail "description missing"
[ "${#desc}" -le 1024 ] && ok "description length <= 1024" || fail "description length ${#desc} > 1024"
first=$(printf '%s' "$desc" | awk '{print $1}')
if printf '%s' "$first" | grep -Eq '^(I|You|We|Use|Help)$'; then
  fail "description opens with '$first': write it in third person, what then when"
elif printf '%s' "$first" | grep -Eq 's$'; then
  ok "description opens with '$first' (third person)"
else
  info "description opens with '$first': confirm it is third person (Implements, not Implement)"
fi
printf '%s' "$desc" | grep -Eqi '\buse (it |this )?when\b|\bwhen (the user|asked|you|working)\b' && ok "description states when to use" || fail "description has no 'use when' clause"
printf '%s' "$frontmatter" | grep -q '[<>]' && fail "frontmatter contains angle brackets" || ok "frontmatter has no angle brackets"

[ -n "$(field compatibility)" ] && ok "compatibility declared" || info "no compatibility field: confirm the body assumes no CLI, package, or host"
version=$(printf '%s\n' "$frontmatter" | awk '/^[ ]+version:/{sub(/^[ ]+version:[ ]*/,""); gsub(/"/,""); print; exit}')
[ -n "$version" ] && ok "metadata.version $version" || info "no metadata.version"

# --- Structure
[ "$body_lines" -lt 500 ] && ok "SKILL.md body $body_lines lines < 500" || fail "SKILL.md body $body_lines lines >= 500"
[ -f "$dir/README.md" ] && fail "README.md inside the skill directory" || ok "no README.md in skill directory"

refs=$(find "$dir" -mindepth 2 -name '*.md' -not -path '*/evals/*' -not -path '*/agents/*' 2>/dev/null | sort)
for ref in $refs; do
  rel="${ref#"$dir"/}"
  base=$(basename "$ref")
  lines=$(wc -l < "$ref")
  if grep -q "($rel)" "$skill"; then ok "$rel linked from SKILL.md ($lines lines)"; else fail "$rel not linked from SKILL.md"; fi
  if [ "$lines" -gt 100 ]; then
    head -30 "$ref" | grep -Eqi '^## (contents|table of contents)' && ok "$rel has a table of contents" || fail "$rel has $lines lines and no table of contents"
  fi
  # Links from this reference to sibling references (second level).
  for other in $refs; do
    [ "$other" = "$ref" ] && continue
    obase=$(basename "$other")
    grep -q "($obase)" "$ref" && info "$rel links to $obase: content there must also be linked from SKILL.md"
  done
done

# --- Scripts
for script in $(find "$dir/scripts" -type f 2>/dev/null | sort); do
  rel="${script#"$dir"/}"
  if grep -rq "$(basename "$script")" "$skill" $refs 2>/dev/null; then ok "$rel referenced"; else fail "$rel never referenced from SKILL.md or references"; fi
done

# --- Evaluation
if [ -f "$dir/evals/evals.json" ]; then
  n=$(grep -c '"prompt"' "$dir/evals/evals.json")
  [ "$n" -ge 3 ] && ok "evals/evals.json has $n evaluations" || fail "evals/evals.json has $n evaluations (< 3)"
else
  fail "no evals/evals.json"
fi

# --- Validator (skills-ref). disable-model-invocation is the one rejection this collection accepts.
if command -v npx >/dev/null 2>&1; then
  out=$(npx -y skills-ref validate "$dir" 2>&1)
  if printf '%s' "$out" | grep -q '^Valid skill'; then
    ok "skills-ref validate passed"
  elif printf '%s' "$out" | grep -q 'Unexpected fields in frontmatter: disable-model-invocation\.' && [ "$(printf '%s' "$out" | grep -c '^  - ')" -eq 1 ]; then
    ok "skills-ref validate passed (accepted deviation: disable-model-invocation)"
  else
    fail "skills-ref validate: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
else
  info "npx not found: run skills-ref validate manually"
fi

exit $status
