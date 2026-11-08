#!/usr/bin/env bash
# Measure a skill against the checkable items of SKILL-REVIEW.md.
# Usage: scripts/measure.sh <skill-dir>
# Prints one "ok" or "FAIL" line per measurement; exits 1 when any FAIL.
# Limits (64, 1024, 500, 100) are the constraints stated in SKILL-MECHANICS.md
# and the checklist of SKILL-REVIEW.md.
set -u

[ "$#" -eq 1 ] || { printf 'FAIL  usage: measure.sh <skill-dir>\n'; exit 1; }
dir="$1"
# Resolve to an absolute path so a relative "." still yields the directory name.
dir=$(cd "$dir" 2>/dev/null && pwd -P) || { printf 'FAIL  no such directory: %s\n' "$1"; exit 1; }
# Keep relative/current-directory and target-owned PATH entries out of review tools.
review_safe_path=""
IFS=: read -r -a review_path_entries <<< "${PATH-}"
for review_entry in "${review_path_entries[@]}"; do
  [[ "$review_entry" = /* ]] || continue
  review_physical=$(cd "$review_entry" 2>/dev/null && pwd -P) || continue
  case "$review_physical" in "$dir"|"$dir"/*) continue ;; esac
  review_safe_path="${review_safe_path:+$review_safe_path:}$review_physical"
done
[ -n "$review_safe_path" ] || { printf 'FAIL  no trusted absolute tool directories outside target\n'; exit 1; }
PATH="$review_safe_path"
export PATH
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

mapfile -t refs < <(find "$dir" -mindepth 2 -name '*.md' -not -path '*/agents/*' 2>/dev/null | sort)
for ref in "${refs[@]}"; do
  rel="${ref#"$dir"/}"
  base=$(basename "$ref")
  lines=$(wc -l < "$ref")
  if grep -Fq "($rel)" "$skill"; then ok "$rel linked from SKILL.md ($lines lines)"; else fail "$rel not linked from SKILL.md"; fi
  if [ "$lines" -gt 100 ]; then
    # The table of contents must open the file; 30 lines covers a title and intro.
    head -30 "$ref" | grep -Eqi '^## (contents|table of contents)' && ok "$rel has a table of contents" || fail "$rel has $lines lines and no table of contents"
  fi
  # Links from this reference to sibling references (second level).
  for other in "${refs[@]}"; do
    [ "$other" = "$ref" ] && continue
    obase=$(basename "$other")
    grep -Fq "($obase)" "$ref" && info "$rel links to $obase: content there must also be linked from SKILL.md"
  done
done

# --- Scripts
while IFS= read -r script; do
  rel="${script#"$dir"/}"
  if grep -Frq -e "$(basename "$script")" -- "$skill" "${refs[@]}" 2>/dev/null; then ok "$rel referenced"; else fail "$rel never referenced from SKILL.md or references"; fi
done < <(find "$dir/scripts" -type f 2>/dev/null | sort)

# --- Validator (skills-ref). disable-model-invocation is the one rejection this collection accepts.
validator=()
# Resolve symlinks so a tool outside the target cannot point back into it.
resolve_validator() {
  local candidate="$1" candidate_dir candidate_name link depth
  [[ "$candidate" = /* ]] || return 1
  # 40 matches the conventional operating-system symlink traversal limit.
  for ((depth=0; depth<40; depth++)); do
    candidate_dir=${candidate%/*}
    candidate_name=${candidate##*/}
    candidate_dir=$(cd "${candidate_dir:-/}" 2>/dev/null && pwd -P) || return 1
    candidate="$candidate_dir/$candidate_name"
    case "$candidate" in "$dir"|"$dir"/*) return 1 ;; esac
    if [ ! -L "$candidate" ]; then
      [ -f "$candidate" ] && [ -x "$candidate" ] || return 1
      printf '%s\n' "$candidate"
      return 0
    fi
    link=$(readlink "$candidate") || return 1
    case "$link" in /*) candidate="$link" ;; *) candidate="$candidate_dir/$link" ;; esac
  done
  return 1
}
validator_candidate=$(type -P skills-ref 2>/dev/null) || validator_candidate=""
if [ -n "$validator_candidate" ]; then
  if validator_path=$(resolve_validator "$validator_candidate"); then
    validator=("$validator_path")
  else
    info "skills-ref resolves to an untrusted or unverifiable path: format validation not run"
  fi
fi
if [ "${#validator[@]}" -gt 0 ]; then
  validator_status=0
  out=$("${validator[@]}" validate "$dir" 2>&1) || validator_status=$?
  if [ "$validator_status" -eq 0 ] && printf '%s' "$out" | grep -q '^Valid skill'; then
    ok "skills-ref validate passed"
  elif printf '%s' "$out" | grep -q 'Unexpected fields in frontmatter: disable-model-invocation\.' && [ "$(printf '%s' "$out" | grep -c '^  - ')" -eq 1 ]; then
    ok "skills-ref validate passed (accepted deviation: disable-model-invocation)"
  else
    fail "skills-ref validate: $(printf '%s' "$out" | tr '\n' ' ')"
  fi
else
  info "trusted skills-ref unavailable: format validation not run; use a separately trusted installation"
fi

exit $status
