# Changes

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
