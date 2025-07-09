# Changes

## 2025-07-09 v0.0.4

* **Pager Detection Update**
  + Updated pager detection to use the `--get` option with `git config` instead
    of `get` in `git-md`.

## 2025-02-28 v0.0.3

* Improve `all_images` testing
    * Updated Docker RUN command to install build-base and yaml-dev packages.
    * Updated `gem_hadar` development dependency to version ~> **1.20**.
    * Removed gem update and install commands.
    * Added Docker image for **3.4** Ruby version.
* Improve documentation
    * Added images of `md` and `git-md` output to README.
    * Added new files `img/git-md.png` and `img/md.png`.
    * Updated list of files in `kramdown-ansi.gemspec`.

## 2024-12-08 v0.0.2

* Added handling of `Interrupt` and `Errno::EPIPE` exceptions when using pager in `md` and `git-md` executables:
  * Added require `'term/ansicolor'` to `Kramdown::ANSI::Pager`.
  * Added rescue blocks in `Kramdown::ANSI::Pager.pager` to catch `Interrupt`, `Errno::EPIPE` exceptions.
  * Added `pager_reset_screen` method to reset terminal screen by printing ANSI escape codes.
  * Updated `spec/kramdown/ansi/pager_spec.rb` with tests for new functionality.

## 2024-10-31 v0.0.1

* Strip CSI and OSC sequences in `Terminal::Table`:
  + Fix size calculations

## 2024-10-31 v0.0.0

  * Start
