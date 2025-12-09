# -*- encoding: utf-8 -*-
# stub: kramdown-ansi 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "kramdown-ansi".freeze
  s.version = "0.2.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "Kramdown::ANSI: A library for rendering Markdown(ish) documents with\nbeautiful ANSI escape sequences in the terminal.\n".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["md".freeze, "git-md".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/kramdown/ansi.rb".freeze, "lib/kramdown/ansi/pager.rb".freeze, "lib/kramdown/ansi/styles.rb".freeze, "lib/kramdown/ansi/width.rb".freeze, "lib/kramdown/version.rb".freeze]
  s.files = ["CHANGES.md".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "bin/git-md".freeze, "bin/md".freeze, "img/git-md.png".freeze, "img/md.png".freeze, "kramdown-ansi.gemspec".freeze, "lib/kramdown/ansi.rb".freeze, "lib/kramdown/ansi/pager.rb".freeze, "lib/kramdown/ansi/styles.rb".freeze, "lib/kramdown/ansi/width.rb".freeze, "lib/kramdown/version.rb".freeze, "spec/assets/README.ansi".freeze, "spec/assets/kitten.jpg".freeze, "spec/kramdown/ansi/pager_spec.rb".freeze, "spec/kramdown/ansi/styles_spec.rb".freeze, "spec/kramdown/ansi/width_spec.rb".freeze, "spec/kramdown/ansi_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://github.com/flori/kramdown-ansi".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "Kramdown-ansi - Output markdown in the terminal with ANSI escape sequences".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 3.1".freeze)
  s.rubygems_version = "3.7.2".freeze
  s.summary = "Output markdown in the terminal with ANSI escape sequences".freeze
  s.test_files = ["spec/kramdown/ansi/pager_spec.rb".freeze, "spec/kramdown/ansi/styles_spec.rb".freeze, "spec/kramdown/ansi/width_spec.rb".freeze, "spec/kramdown/ansi_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.8".freeze])
  s.add_development_dependency(%q<all_images>.freeze, ["~> 0.4".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.11".freeze])
  s.add_runtime_dependency(%q<kramdown-parser-gfm>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<terminal-table>.freeze, ["~> 3.0".freeze])
  s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0".freeze])
end
