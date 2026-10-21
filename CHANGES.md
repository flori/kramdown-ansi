# Changes

## 2026-10-21 v0.6.0

### Features

- Add support for nested blockquotes with cycling typographic quotation marks
  based on nesting depth.
- Add ANSI styling support for HTML elements: `ins`/`u` (underline), `mark`
  (negative/inverse), `tt` (code), `small` (faint), and passthrough for
  `span`/`sub`/`sup`.
- Add strikethrough support for `del` and `s` HTML elements.
- Introduce `ProtectEnvVars` module in test helper to isolate environment
  variable changes during tests tagged with `:protect_env`.

### Fixes

- Fix GFM table parsing by inserting required blank lines before and after pipe
  tables to ensure correct recognition by `kramdown`.
- Fix `Integer#size` regression in table column width calculation by using
  `display_width` directly instead of `.size`, ensuring correct column ratios
  on Ruby 4.
- Fix empty table cell rendering by replacing empty strings with a single space
  and falling back to equal-width splits when total width is zero.
- Fix typo in `convert_html_element` where `e.value` was used instead of
  `el.value` for the `del`/`s` branch.
- Make `Token` definition in `Kramdown::ANSI::Width` compatible with Ruby
  versions lacking `Data` by providing a `Struct`-based fallback.

### Improvements

- Rewrite `Kramdown::ANSI::Width#truncate` to be ANSI-aware, correctly handling
  escape sequences, wide characters (emojis), and zero-width characters using
  `display_width`.
- Optimize `wrap` and `truncate` methods by using `scan` instead of `gsub` to
  reduce allocation.
- Generalize the `capture:tables` Rake task to `capture:ansi` to regenerate
  golden files for all `spec/assets/*.md` fixtures.
- Update `README.md` style examples to include `blockquote` and add a nested
  dialog example.

### Build & CI

- Add `tins` gem (`~> 1.61`) as a runtime dependency.
- Upgrade `gem_hadar` development dependency to `>= 2.20.1`.
- Update `rubygems_version` in gemspec to **4.0.22**.
- Remove unused gems (`docile`, `simplecov-html`, `simplecov_json_formatter`)
  from `.utilsrc`.
- Add `git config --global --add safe.directory /work` to Docker test script.
- Use `nproc` instead of `getconf _NPROCESSORS_ONLN` for CPU count in Docker
  test script.
- Add `tmp/.gitkeep` to track the empty `tmp` directory.

### Testing

- Add `spec/kramdown/render_spec.rb` to test `Kramdown::ANSI.parse` for
  headers, inline emphasis, code blocks, blockquotes, horizontal rules, lists,
  links, images, and paragraphs.
- Add `spec/assets/tables.md` and `spec/assets/tables.ansi` golden files
  covering 26 edge cases for table rendering.
- Add `spec/kramdown/ansi_golden_spec.rb` for output regression testing against
  golden files.
- Add `spec/assets/html.md` and `spec/assets/html.ansi` golden files covering
  HTML element styling.
- Add 9 new specs for `Kramdown::ANSI::Width#truncate` covering wide emojis,
  empty strings, pure ANSI, zero-width characters, newline preservation,
  multi-cell ellipsis, nested-style reset, and post-cut escape omission.
- Stub `Tins::Terminal.columns` to 80 in `ansi_spec.rb` and `render_spec.rb`
  for deterministic output.

## 2026-03-21 v0.5.0

- Added `spec/kramdown/ansi_table_spec.rb` to the test suite and gemspec file
  list.
- Updated `Kramdown::ANSI#convert_tr` to use column‑width ratios instead of a
  fixed `full_width`.
- Refactored `Kramdown::ANSI::Width.wrap` to preserve ANSI escapes, clamp
  lengths, and use a token‑based wrapping algorithm.
- Introduced `display_width` method in `Kramdown::ANSI::Width` to compute
  visual width after stripping ANSI codes.
- Extracted ANSI escape removal logic into reusable
  `Kramdown::ANSI::Width.remove_ansi_escapes`.
- Added lightweight `LoremIpsum` helper class in `spec/spec_helper.rb` for
  deterministic dummy text.
- Updated `spec/kramdown/ansi_spec.rb` expectations to reflect new line‑break
  behavior and added a direct `output.puts` call.
- Updated CI image configuration: install `build-base`, `yaml-dev`,
  `openssl-dev`, `git`; removed `bundle update`; added before/after blocks;
  removed `Gemfile.lock`.
- Added `.rspec` configuration with `--force-color` and exclusion of
  `spec_helper`.
- Added `.utilsrc` configuration for util indexing, listing numerous gems and
  test framework settings.
- Removed `require 'spec_helper'` from spec files, enabling colorized test
  output.
- Added runtime dependency on `unicode-display_width` (~> **3.0**) for accurate
  string width calculations.

## 2026-02-23 v0.4.1

- Updated the Ruby CI script to use `bundle exec` when running `rake spec`,
  ensuring the correct gem execution context.
- Removed a duplicate `echo -e "\e[0m"` line from the CI script for cleaner
  output.
- Adjusted the CI configuration to maintain compatibility with the **4.0**
  Alpine image.
- Added a `CHANGES.md` file to the gem release process.
- Configured the `GemHadar` block in the `Rakefile` to include `CHANGES.md` in
  gem releases, ensuring release notes are published to RubyGems.org.
- Updated the Ruby base image from `ruby:4.0-rc-alpine` to `ruby:4.0-alpine`
  for stable builds.
- Enabled the `ruby:4.0-rc-alpine` image in the build matrix to support
  release‑candidate testing.

## 2025-12-19 v0.4.0

- Changed `required_ruby_version` from `~> 3.1` to `>= 3.1` in `Rakefile` and `kramdown-ansi.gemspec`
- Updated `rubygems_version` from **3.7.2** to **4.0.2** in `kramdown-ansi.gemspec`
- Updated `gem_hadar` development dependency from **2.8** to **2.9** in `kramdown-ansi.gemspec`
- Added `openssl-dev` to the `RUN apk add` command in `.all_images.yml`
- Changed `bundle update` to `bundle update --all` in `.all_images.yml`
- Added `ruby:4.0-rc-alpine` image configuration in `.all_images.yml`

## 2025-12-09 v0.3.0

- Added documentation link to README
- Added GitHub Actions workflow file `.github/workflows/static.yml` for static
  site deployment to GitHub Pages
- Configured GitHub Actions workflow to run on `master` branch pushes and
  manual dispatch with appropriate permissions
- Implemented deployment job using `ubuntu-latest` runner with steps for
  checkout, setup Pages, setup Ruby **3.4**, documentation generation, artifact
  upload, and deployment
- Updated `Rakefile` to include `github_workflows` configuration for the new
  `static.yml` workflow
- Updated gem dependencies in `kramdown-ansi.gemspec` to use RubyGems version
  **3.7.2** instead of **3.6.9**
- Updated `gem_hadar` development dependency from version **~> 2.6** to **~>
  2.8**
- Modified `lib/kramdown/ansi/pager.rb` to improve documentation and yield both
  output stream and process ID to the block
- Added new test case in `spec/kramdown/ansi/pager_spec.rb` to verify that the
  `pager` method yields both output and pid to the block
- Enhanced the `pager` method documentation to better describe its
  functionality and parameters
- Added `bundle install --jobs=$(getconf _NPROCESSORS_ONLN)` command to utilize
  all available CPU cores during gem installation
- Updated `gem_hadar` development dependency from version **2.2** to **2.6**
- Modified `package_ignore` in `Rakefile` to explicitly ignore `.github`
  directory instead of using glob pattern `'.github/**/*'`
- Added `RUN gem update --system` to update RubyGems to **latest** version in
  CI configuration
- Added `bundle update` command to update bundle dependencies in CI
  configuration

## 2025-09-09 v0.2.0

- Updated required Ruby version requirement from **~> 3.0** to **~> 3.1**
- Dropped support for Ruby version **3.0**
- Removed `ruby:3.0-alpine` from `.all_images.yml`
- Updated `required_ruby_version` in `Rakefile` to **~> 3.1**

## 2025-09-09 v0.1.1

- Updated Ruby version requirement from **~> 3.1** to **~> 3.0** in `Rakefile`
  and `kramdown-ansi.gemspec`
- Bumped `gem_hadar` development dependency from `"~> 2.0"` to `"~> 2.2"` in
  `kramdown-ansi.gemspec`
- Added `ignored` parameter to `as_json` method signature in
  `lib/kramdown/ansi/styles.rb`
- Added `args` parameter to `to_json` method signature and passed it through to
  `as_json.to_json` in `lib/kramdown/ansi/styles.rb`
- Added support for Ruby versions **3.1** and **3.0** in CI pipeline
- Included `ruby:3.1-alpine` and `ruby:3.0-alpine` image configurations
- Updated Dockerfile with `RUN gem install bundler gem_hadar` instruction

## 2025-08-17 v0.1.0

- Added comprehensive ANSI style configuration support with
  `Kramdown::ANSI::Styles` class
- Implemented `from_json` and `from_env_var` methods for loading styles
  programmatically
- Added environment variable precedence for style configuration:
  - `KRAMDOWN_ANSI_GIT_MD_STYLES` → `KRAMDOWN_ANSI_STYLES`
  - `KRAMDOWN_ANSI_MD_STYLES` → `KRAMDOWN_ANSI_STYLES`
- Updated `md` and `git-md` executables to use new style configuration system
- Added **JSON** dependency to gemspec
- Enhanced README with documentation for style configuration
- Added extensive test coverage for `Styles` class functionality
- Supported custom ANSI styles via `ansi_styles` option in
  `Kramdown::ANSI.parse`
- Implemented proper fallback logic for default styles when custom
  configurations are applied
- Updated license reference to link to LICENSE file
- Updated `gem_hadar` development dependency from version **1.20** to **2.0**
- Simplified test coverage initialization with `GemHadar::SimpleCov.start`
- Updated RSpec syntax in spec files, changing `RSpec.describe` to `describe`

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
