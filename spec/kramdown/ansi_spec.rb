require 'spec_helper'
require 'pathname'

RSpec.describe Kramdown::ANSI do
  let :source  do
    File.read(Pathname.new(__dir__) + '..' + '..' + 'README.md')
  end

  it 'can parse' do
    File.open('tmp/README.ansi', ?w) do |output|
      ansi = described_class.parse(source)
      expect(ansi).to match("This is the end.")
      output.puts ansi
    end
  end
end
