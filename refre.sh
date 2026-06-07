#!/usr/bin/env zsh
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
src_root="$HOME/src"
formats=(pdf epub mobi)
push_after_refresh=0

updated=0
added=0
relinked=0
unchanged=0
detected_paths=()

usage() {
  cat <<'EOF'
usage: ./refre.sh [--push]

Refresh archived book artifacts from their source repositories.

Options:
  --push    commit and push the artifact updates detected by this run
  -h, --help
            show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --push)
      push_after_refresh=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'unknown option: %s\n\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

file_id() {
  stat -f '%d:%i' "$1"
}

record_detected() {
  local rel="$1"

  detected_paths+=("$rel")
}

git_file_changed() {
  local rel="$1"

  git -C "$repo_dir" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1 || return 1
  ! git -C "$repo_dir" diff --quiet -- "$rel"
}

refresh_one() {
  local src="$1"
  local dest="$repo_dir/$2"
  local rel="$2"

  if [[ ! -f "$src" ]]; then
    printf 'missing source: %s\n' "$src" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ ! -e "$dest" ]]; then
    ln -f "$src" "$dest"
    printf 'added   %s\n' "${dest#$repo_dir/}"
    record_detected "$rel"
    added=$((added + 1))
    return
  fi

  if cmp -s "$src" "$dest"; then
    if [[ "$(file_id "$src")" == "$(file_id "$dest")" ]]; then
      if git_file_changed "$rel"; then
        printf 'updated %s\n' "$rel"
        record_detected "$rel"
        updated=$((updated + 1))
      else
        printf 'same    %s\n' "$rel"
        unchanged=$((unchanged + 1))
      fi
    else
      ln -f "$src" "$dest"
      printf 'relink  %s\n' "$rel"
      record_detected "$rel"
      relinked=$((relinked + 1))
    fi
    return
  fi

  ln -f "$src" "$dest"
  printf 'updated %s\n' "$rel"
  record_detected "$rel"
  updated=$((updated + 1))
}

push_changes() {
  if (( ${#detected_paths[@]} == 0 )); then
    printf '\nno detected artifact updates to commit\n'
    return
  fi

  git -C "$repo_dir" add -- "${detected_paths[@]}"

  if git -C "$repo_dir" diff --cached --quiet -- "${detected_paths[@]}"; then
    printf '\ndetected artifact paths had no commit-worthy content changes\n'
    return
  fi

  git -C "$repo_dir" commit \
    -m "Refresh book archive artifacts" \
    -m "Updated: $updated; added: $added; relinked: $relinked; unchanged: $unchanged."
  git -C "$repo_dir" push
}

book() {
  local dest_dir="$1"
  local src_dir="$2"
  local prefix="$3"
  shift 3

  local ext extra

  for ext in "${formats[@]}"; do
    refresh_one "$src_dir/$prefix.$ext" "$dest_dir/$prefix.$ext"
  done

  for extra in "$@"; do
    refresh_one "$src_dir/$extra" "$dest_dir/$extra"
  done
}

book "meetup-graph-codex" \
  "$src_root/bythebay/cdx/meetup-graph-codex/docs" \
  "meetup-graph-codex-book" \
  "rust-graph-loader-book.pdf"

book "sail-rust-book" \
  "$src_root/books/sail-rust-book/sail-rust-book/book" \
  "sail-rust-arrow-datafusion-book"

book "rio-grande" \
  "$src_root/books/rio-grande/book" \
  "historia_riograndense_brasil-alexy" \
  "historia_riograndense_brasil.pdf"

book "grust" \
  "$src_root/grust/book/build/dist" \
  "grust-book"

book "typesec" \
  "$src_root/typesec/book/dist" \
  "typesec"

printf '\nsummary: %d updated, %d added, %d relinked, %d unchanged\n' \
  "$updated" "$added" "$relinked" "$unchanged"

if (( push_after_refresh )); then
  push_changes
fi
