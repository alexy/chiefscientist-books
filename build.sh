#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_root="$HOME/src"

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

refresh_prefixed_formats() {
  local src_dir="$1"
  local dest_dir="$2"
  local prefix="$3"
  local ext

  for ext in pdf epub mobi; do
    refresh_one "$src_dir/$prefix.$ext" "$dest_dir/$prefix.$ext"
  done
}

refresh_named() {
  local src_dir="$1"
  local dest_dir="$2"
  local filename="$3"

  refresh_one "$src_dir/$filename" "$dest_dir/$filename"
}

meetup_src_dir="$src_root/bythebay/cdx/meetup-graph-codex/docs"
meetup_dest_dir="meetup-graph-codex"
meetup_prefix="meetup-graph-codex-book"
meetup_legacy_prefix="rust-graph-loader-book"
refresh_prefixed_formats "$meetup_src_dir" "$meetup_dest_dir" "$meetup_prefix"
refresh_named "$meetup_src_dir" "$meetup_dest_dir" "$meetup_legacy_prefix.pdf"

sail_src_dir="$src_root/books/sail-rust-book/sail-rust-book/book"
sail_dest_dir="sail-rust-book"
sail_prefix="sail-rust-arrow-datafusion-book"
refresh_prefixed_formats "$sail_src_dir" "$sail_dest_dir" "$sail_prefix"

rio_src_dir="$src_root/books/rio-grande/book"
rio_dest_dir="rio-grande"
rio_prefix="historia_riograndense_brasil-alexy"
rio_original_prefix="historia_riograndense_brasil"
refresh_prefixed_formats "$rio_src_dir" "$rio_dest_dir" "$rio_prefix"
refresh_named "$rio_src_dir" "$rio_dest_dir" "$rio_original_prefix.pdf"

grust_src_dir="$src_root/grust/book/build/dist"
grust_dest_dir="grust"
grust_prefix="grust-book"
refresh_prefixed_formats "$grust_src_dir" "$grust_dest_dir" "$grust_prefix"

typesec_src_dir="$src_root/typesec/book/dist"
typesec_dest_dir="typesec"
typesec_prefix="typesec"
refresh_prefixed_formats "$typesec_src_dir" "$typesec_dest_dir" "$typesec_prefix"

printf '\nsummary: %d updated, %d added, %d relinked, %d unchanged\n' \
  "$updated" "$added" "$relinked" "$unchanged"
