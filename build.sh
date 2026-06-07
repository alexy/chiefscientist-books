#!/usr/bin/env zsh
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
src_root="$HOME/src"
formats=(pdf epub mobi)

updated=0
added=0
relinked=0
unchanged=0

file_id() {
  stat -f '%d:%i' "$1"
}

refresh_one() {
  local src="$1"
  local dest="$repo_dir/$2"

  if [[ ! -f "$src" ]]; then
    printf 'missing source: %s\n' "$src" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ ! -e "$dest" ]]; then
    ln -f "$src" "$dest"
    printf 'added   %s\n' "${dest#$repo_dir/}"
    added=$((added + 1))
    return
  fi

  if cmp -s "$src" "$dest"; then
    if [[ "$(file_id "$src")" == "$(file_id "$dest")" ]]; then
      printf 'same    %s\n' "${dest#$repo_dir/}"
      unchanged=$((unchanged + 1))
    else
      ln -f "$src" "$dest"
      printf 'relink  %s\n' "${dest#$repo_dir/}"
      relinked=$((relinked + 1))
    fi
    return
  fi

  ln -f "$src" "$dest"
  printf 'updated %s\n' "${dest#$repo_dir/}"
  updated=$((updated + 1))
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
