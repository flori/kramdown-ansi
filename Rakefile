# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'kramdown-ansi'
  path_name   'kramdown'
  module_type :module
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'Output markdown in the terminal with ANSI escape sequences'
  description <<~EOT
    Kramdown::ANSI: A library for rendering Markdown(ish) documents with
    beautiful ANSI escape sequences in the terminal.
  EOT
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.AppleDouble', '.bundle',
    '.yardoc', 'doc', 'tags', 'errors.lst', 'cscope.out', 'coverage', 'tmp',
    'yard'
  package_ignore '.all_images.yml', '.tool-versions', '.gitignore', 'VERSION',
    '.rspec', *Dir.glob('.github/**/*', File::FNM_DOTMATCH)
  readme      'README.md'

  executables << 'md' << 'git-md'

  required_ruby_version  '~> 3.1'

  dependency             'term-ansicolor',        '~> 1.11'
  dependency             'kramdown-parser-gfm',   '~> 1.1'
  dependency             'terminal-table',        '~> 3.0'
  development_dependency 'all_images',            '~> 0.4'
  development_dependency 'rspec',                 '~> 3.2'
  development_dependency 'debug'
  development_dependency 'simplecov'

  licenses << 'MIT'

  clobber 'coverage'
end
