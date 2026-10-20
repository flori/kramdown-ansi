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
    '.rspec', '.github'
  readme      'README.md'

  executables << 'md' << 'git-md'

  changelog do
    filename 'CHANGES.md'
  end

  github_workflows(
    'static.yml' => {}
  )

  required_ruby_version  '>= 3.1'

  dependency             'term-ansicolor',        '~> 1.11'
  dependency             'kramdown-parser-gfm',   '~> 1.1'
  dependency             'terminal-table',        '~> 4.0'
  dependency             'json',                  '~> 2.0'
  dependency             'unicode-display_width', '~> 3.0'
  development_dependency 'all_images',            '~> 0.4'
  development_dependency 'rspec',                 '~> 3.2'
  development_dependency 'debug'
  development_dependency 'simplecov'

  licenses << 'MIT'

  clobber 'coverage'
end

namespace :capture do
  desc 'Capture golden file output for spec/assets/tables.md'
  task :tables do
    require 'kramdown/ansi'
    module Tins::Terminal
      def self.columns
        80
      end
    end
    src = File.read('spec/assets/tables.md')
    out = Kramdown::ANSI.parse(src)
    File.write('spec/assets/tables.ansi', out)
    puts "Captured spec/assets/tables.ansi (#{out.bytesize} bytes)"
  end
end
