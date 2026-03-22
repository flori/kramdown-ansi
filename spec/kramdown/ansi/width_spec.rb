describe Kramdown::ANSI::Width do
  let :ansi do
    Term::ANSIColor
  end

  before do
    allow(Tins::Terminal).to receive(:columns).and_return 80
  end

  describe '.width' do
    it 'defaults to 100%' do
      expect(described_class.width).to eq 80
    end

    it 'can be to 80%' do
      expect(described_class.width(percentage: 80)).to eq 64
    end
  end

  describe '.wrap' do
    it 'can wrap with percentage' do
      wrapped = described_class.wrap([ ?A * 10 ] * 10 * ' ', percentage: 80)
      expect(wrapped).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA\n"\
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA"
      )
      expect(wrapped.size).to eq 109
    end

    it 'can wrap with length' do
      wrapped = described_class.wrap([ ?A * 10 ] * 10 * ' ', length: 64)
      expect(wrapped).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA\n"\
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA"
      )
      expect(wrapped.size).to eq 109
    end

    it "doesn't wrap with length 0" do
      wrapped = described_class.wrap([ ?A * 10 ] * 10 * ' ', length: 0)
      expect(wrapped).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA "\
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA"
      )
    end
  end

  describe '.truncate' do
    it 'can truncate with percentage' do
      truncated = described_class.truncate([ ?A * 10 ] * 10 * ' ', percentage: 80)
      expect(truncated).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAA…"
      )
      expect(truncated.size).to eq 64
    end

    it 'can truncate with length' do
      truncated = described_class.truncate([ ?A * 10 ] * 10 * ' ', length: 64)
      expect(truncated).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAA…"
      )
      expect(truncated.size).to eq 64
    end

    it 'can truncate ansi escape sequences with length' do
      truncated = described_class.truncate([ ansi.red { ?A * 10 }, ansi.green { ?A * 10 } ] * 5 * ' ', length: 64)
      expect(truncated).to eq(
        "\e[31mAAAAAAAAAA\e[0m \e[32mAAAAAAAAAA\e[0m \e[31mAAAAAAAAAA\e[0m \e[32mAAAAAAAAAA\e[0m \e[31mAAAAAAAAAA\e[0m \e[32mAAAAAAAA…\e[0m"
      )
      expect(Term::ANSIColor.uncolor {truncated }.size).to eq 64
    end

    it 'can truncate wide emojis with length' do
      truncated = described_class.truncate('ABC' + ?😍 * 10 + 'DEF', length: 10)
      expect(truncated).to eq("ABC😍😍😍…")
      expect(truncated.size).to eq 7
      expect(described_class.display_width(truncated)).to eq 10
      truncated = described_class.truncate('AB' + ?😍 * 10 + 'DEF', length: 10)
      expect(truncated).to eq("AB😍😍😍…")
      expect(truncated.size).to eq 6
      expect(described_class.display_width(truncated)).to eq 9
      truncated = described_class.truncate('A' + ?😍 * 10 + 'DEF', length: 10)
      expect(truncated).to eq("A😍😍😍😍…")
      expect(truncated.size).to eq 6
      expect(described_class.display_width(truncated)).to eq 10
      truncated = described_class.truncate('A' * 5 + ?😍 + 'B' * 5, length: 10)
      expect(truncated).to eq("AAAAA😍BB…")
      expect(truncated.size).to eq 9
      expect(described_class.display_width(truncated)).to eq 10
      truncated = described_class.truncate('A' * 3 + ?😍 + 'B' + ?😁 + 'C' * 5, length: 10)
      expect(truncated).to eq("AAA😍B😁C…")
      expect(truncated.size).to eq 8
      expect(described_class.display_width(truncated)).to eq 10
      truncated = described_class.truncate('A' * 3 + ?😍 + ansi.red { 'B' } + ?😁 + 'C' * 5, length: 10)
      expect(truncated).to eq("AAA😍\e[31mB\e[0m😁C…\e[0m")
      expect(truncated.size).to eq 21
      expect(described_class.display_width(truncated)).to eq 10
    end

    it 'cannot truncate if not necessary' do
      text = [ ?A * 10 ] * 5 * ' '
      truncated = described_class.truncate(text, length: 54)
      expect(truncated).to eq text
    end

    it 'can truncate empty strings' do
      truncated = described_class.truncate('', length: 23)
      expect(truncated).to be_empty
    end

    it 'can truncate with length 0' do
      truncated = described_class.truncate([ ?A * 10 ] * 10 * ' ', length: 0)
      expect(truncated).to be_empty
    end

    it 'can truncate with ...' do
      truncated = described_class.truncate([ ?A * 10 ] * 10 * ' ', length: 64, ellipsis: '...')
      expect(truncated).to eq(
        "AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAAAAA..."
      )
      expect(truncated.size).to eq 64
    end

    it 'keeps pure ANSI strings (no chars)' do
      truncated = described_class.truncate(ansi.red { '' }, length: 10)
      expect(truncated).to eq "\e[31m\e[0m"
      expect(truncated.size).to eq 9
    end

    it 'handles zero-width characters correctly' do
      src = "A#{("\u200d"*10)}B"
      truncated  = described_class.truncate(src, length: 3)
      expect(described_class.display_width(truncated)).to eq(2)
      expect(truncated).to match "A.*B"
    end

    it 'preserves newlines in multi-line text' do
      truncated = described_class.truncate("hello\nworld", length: 8)
      expect(truncated).to include("\n")
      expect(described_class.display_width(truncated)).to eq 8
    end

    it 'supports multi‑cell ellipsis' do
      truncated  = described_class.truncate('ABC' + ?😇 * 10, length: 8, ellipsis: '… (more)')
      expect(truncated).to eq "… (more)"
      expect(described_class.display_width(truncated)).to eq 8
      expect(truncated.length).to eq 8
    end

    it 'appends reset if truncated after an escape that lacks reset' do
      truncated = described_class.truncate(ansi.red { 'Hello' }, length: 4)
      expect(truncated).to eq "\e[31mHel…\e[0m"
      expect(described_class.remove_ansi_escapes(truncated).size).to eq 4
    end

    it 'appends single reset for nested styles when truncated' do
      truncated = described_class.truncate(ansi.red { ansi.bold { 'Hi' } }, length: 2)
      expect(truncated).to eq "\e[31m\e[1mH…\e[0m"
      expect(described_class.display_width(truncated)).to eq 2
    end

    it 'omits escapes that fall after the truncation point' do
      src = "#{ansi.red { 'A' }}B#{ansi.green { 'C' }}D"
      truncated = described_class.truncate(src, length: 2)
      expect(truncated).not_to include "\e[32m"
      expect(truncated).to eq "\e[31mA…\e[0m"
      expect(described_class.display_width(truncated)).to eq 2
    end
  end
end
