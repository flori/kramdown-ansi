require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'kramdown/ansi'

def asset(name)
  File.join(__dir__, 'assets', name)
end
