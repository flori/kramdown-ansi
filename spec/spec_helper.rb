if ENV['START_SIMPLECOV'].to_i == 1
  require 'simplecov'
  SimpleCov.start do
    add_filter "#{File.basename(File.dirname(__FILE__))}/"
  end
end
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'kramdown/ansi'

def asset(name)
  File.join(__dir__, 'assets', name)
end