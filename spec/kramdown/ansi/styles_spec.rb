require 'spec_helper'


describe Kramdown::ANSI::Styles do
  describe '.from_json' do
    it 'configures styles from JSON' do
      json = '{"header": ["bold", "underline"], "code": "red"}'
      styles = described_class.from_json(json)

      expect(styles.ansi_styles[:header]).to eq([:bold, :underline])
      expect(styles.ansi_styles[:code]).to eq(:red)
    end
  end

  describe '.from_env_var' do
    around do |example|
      ENV['TEST_STYLES'] = '{"em": "yellow"}'
      example.run
      ENV.delete('TEST_STYLES')
    end

    it 'configures styles from environment variable' do
      styles = described_class.from_env_var('TEST_STYLES')

      expect(styles.ansi_styles[:em]).to eq(:yellow)
    end

    it 'raises an error when env var is not set' do
      ENV.delete('TEST_STYLES')
      expect {
        described_class.from_env_var('TEST_STYLES')
      }.to raise_error(KeyError)
    end
  end

  describe '#as_json' do
    it 'can be prepared for JSON conversion' do
      expect(described_class.new.as_json).to include(:code)
    end
  end

  describe '#to_hash' do
    it 'can be converted to a hash' do
      expect(described_class.new.to_hash).to include(:code)
    end
  end

  describe '#to_h' do
    it 'can be converted to a hash more forecefully' do
      expect(described_class.new.to_h).to include(:code)
    end
  end

  describe '#to_json' do
    it 'can be converted to JSON' do
      expect(described_class.new.to_json).to include('"code":')
    end
  end

  describe '#configure' do
    let(:styles) { described_class.new }

    it 'merges options with defaults' do
      styles.configure(header: [:bold, :underline])

      expect(styles.ansi_styles[:header]).to eq([:bold, :underline])
      expect(styles.ansi_styles[:strong]).to eq(:bold) # default preserved
    end

    it 'handles string keys gracefully' do
      styles.configure('em' => 'italic')

      expect(styles.ansi_styles[:em]).to eq(:italic)
    end

    it 'preserves default styles when not overridden' do
      styles.configure(code: :green)

      expect(styles.default_ansi_styles[:header]).to eq(%i[bold underline])
      expect(styles.ansi_styles[:header]).to eq(%i[bold underline])
      expect(styles.ansi_styles[:code]).to eq(:green)
    end
  end

  describe '#apply' do
    let(:styles) { described_class.new }

    it 'applies single style to text' do
      result = styles.apply(:strong) { "Hello" }
      expect(result).to include("\e[1m") # bold ANSI code
    end

    it 'applies multiple styles in correct order' do
      result = styles.apply(:header) { "Header" }
      expect(result).to include("\e[1m\e[4m") # bold + underline
    end

    it 'handles non-existent style by raising KeyError' do
      expect {
        styles.apply(:nonexistent) { "Text" }
      }.to raise_error(KeyError)
    end

    it 'applies styles correctly with complex text' do
      result = styles.apply(:code) { "puts 'hello'" }
      expect(result).to include("\e[34m") # blue ANSI code
    end

    it 'allows inspection of current configuration' do
      expect(styles.ansi_styles).to eq(styles.default_ansi_styles)

      styles.configure(em: :underline)
      expect(styles.ansi_styles[:em]).to eq(:underline)
      expect(styles.ansi_styles[:strong]).to eq(:bold) # unchanged
    end
  end
end
