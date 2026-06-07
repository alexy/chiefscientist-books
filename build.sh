#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

refresh_one "/Users/alexy/src/bythebay/cdx/meetup-graph-codex/docs/meetup-graph-codex-book.pdf" "meetup-graph-codex/meetup-graph-codex-book.pdf"
refresh_one "/Users/alexy/src/bythebay/cdx/meetup-graph-codex/docs/rust-graph-loader-book.pdf" "meetup-graph-codex/rust-graph-loader-book.pdf"
refresh_one "/Users/alexy/src/bythebay/cdx/meetup-graph-codex/docs/meetup-graph-codex-book.epub" "meetup-graph-codex/meetup-graph-codex-book.epub"
refresh_one "/Users/alexy/src/bythebay/cdx/meetup-graph-codex/docs/meetup-graph-codex-book.mobi" "meetup-graph-codex/meetup-graph-codex-book.mobi"

refresh_one "/Users/alexy/src/books/sail-rust-book/sail-rust-book/book/sail-rust-arrow-datafusion-book.pdf" "sail-rust-book/sail-rust-arrow-datafusion-book.pdf"
refresh_one "/Users/alexy/src/books/sail-rust-book/sail-rust-book/book/sail-rust-arrow-datafusion-book.epub" "sail-rust-book/sail-rust-arrow-datafusion-book.epub"
refresh_one "/Users/alexy/src/books/sail-rust-book/sail-rust-book/book/sail-rust-arrow-datafusion-book.mobi" "sail-rust-book/sail-rust-arrow-datafusion-book.mobi"

refresh_one "/Users/alexy/src/books/rio-grande/book/historia_riograndense_brasil-alexy.pdf" "rio-grande/historia_riograndense_brasil-alexy.pdf"
refresh_one "/Users/alexy/src/books/rio-grande/book/historia_riograndense_brasil.pdf" "rio-grande/historia_riograndense_brasil.pdf"
refresh_one "/Users/alexy/src/books/rio-grande/book/historia_riograndense_brasil-alexy.epub" "rio-grande/historia_riograndense_brasil-alexy.epub"
refresh_one "/Users/alexy/src/books/rio-grande/book/historia_riograndense_brasil-alexy.mobi" "rio-grande/historia_riograndense_brasil-alexy.mobi"

refresh_one "/Users/alexy/src/grust/book/build/dist/grust-book.pdf" "grust/grust-book.pdf"
refresh_one "/Users/alexy/src/grust/book/build/dist/grust-book.epub" "grust/grust-book.epub"
refresh_one "/Users/alexy/src/grust/book/build/dist/grust-book.mobi" "grust/grust-book.mobi"

refresh_one "/Users/alexy/src/typesec/book/dist/typesec.pdf" "typesec/typesec.pdf"
refresh_one "/Users/alexy/src/typesec/book/dist/typesec.epub" "typesec/typesec.epub"
refresh_one "/Users/alexy/src/typesec/book/dist/typesec.mobi" "typesec/typesec.mobi"

printf '\nsummary: %d updated, %d added, %d relinked, %d unchanged\n' \
  "$updated" "$added" "$relinked" "$unchanged"
