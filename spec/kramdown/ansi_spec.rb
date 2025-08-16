require 'spec_helper'
require 'pathname'

describe Kramdown::ANSI do
  let :source  do
    File.read(Pathname.new(__dir__) + '..' + '..' + 'README.md')
  end

  it 'can parse' do
    File.open('tmp/README.ansi', ?w) do |output|
      ansi = described_class.parse(source)
      expect(ansi).to include("\e[1m\e[4mDescription\e[0m\e[0m")
      expect(ansi).to include("\e[1mKramdown::ANSI\e[0m")
      expect(ansi).to include("\e[3min the terminal\e[0m")
      expect(ansi).to include("\e[34mgem install kramdown-ansi\n\e[0m")
      expect(ansi).to include("\e[34mbundle install\e[0m")
      expect(ansi).to include("This is the end.")
      output.puts ansi
    end
  end

  it 'can parse with options' do
    File.open('tmp/README.ansi', ?w) do |output|
      ansi_styles = Kramdown::ANSI::Styles.new.configure(
        header: %i[ red underline ],
        strong: %i[ green ],
        em:     %i[ yellow ],
        code:   %i[ bold color208 ],
      )
      ansi = described_class.parse(source, ansi_styles:)
      expect(ansi).to include("\e[31m\e[4mDescription\e[0m\e[0")
      expect(ansi).to include("\e[32mKramdown::ANSI\e[0m")
      expect(ansi).to include("\e[33min the terminal\e[0m")
      expect(ansi).to include("\e[1m\e[38;5;208mgem install kramdown-ansi\n\e[0m\e[0m")
      expect(ansi).to include("\e[1m\e[38;5;208mbundle install\e[0m\e[0m")
      expect(ansi).to include("This is the end.")
    end
  end
end
