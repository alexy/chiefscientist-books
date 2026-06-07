# Chief Scientist Books

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

## Assembly Process

1. Rebuild the source book in its own project repository.
2. Verify the regenerated PDF, EPUB, and MOBI in the source repository.
3. Copy only final distributable files into the matching directory here.
4. Keep filenames stable across releases unless the book itself is renamed.
5. Update `manifest.tsv` with the source repository, copied filenames, and date.
6. Commit and push this archive repository.

This repo should not contain manuscript sources, build scripts, generated
intermediate files, or scratch exports. Those stay in the source projects.

