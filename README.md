# Books

This repository is the final-copy archive for completed book builds.

Each book gets one top-level directory. Each directory contains the distributable
formats for that book:

- `*.pdf`
- `*.epub`
- `*.mobi`

## Current Books

- `meetup-graph-codex/`
- `sail-rust-book/`
- `rio-grande/`
- `grust/`
- `typesec/`
- `querygraph/`

## Assembly Process

1. Rebuild the source book in its own project repository.
2. Verify the regenerated PDF, EPUB, and MOBI in the source repository.
3. Run `./refre.sh` from this repository to refresh hard links for changed artifacts.
4. Keep filenames stable across releases unless the book itself is renamed.
5. Update `manifest.tsv` with the source repository, linked filenames, and date.
6. Commit and push this archive repository, or run `./refre.sh --push` to commit
   and push the artifact updates detected by that refresh.

`refre.sh` compares each source artifact with its archived copy. It only changes
archive contents when the source file changed, and it also refreshes hard links
when a generator rewrote an identical file at a new inode.

This repo should not contain manuscript sources, source-project build scripts,
generated intermediate files, or scratch exports. Those stay in the source
projects.
