# Changes

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
