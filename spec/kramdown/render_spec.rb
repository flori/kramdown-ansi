require 'spec_helper'

describe 'Kramdown::ANSI rendering' do
  before do
    allow(Tins::Terminal).to receive(:columns).and_return 80
  end

  subject(:render) { Kramdown::ANSI.parse(md) }

  describe 'headers' do
    context 'level 1' do
      let(:md) { "# Hello\n" }
      it 'applies bold+underline' do
        expect(render).to eq "\e[1m\e[4mHello\e[0m\e[0m\n"
      end
    end

    context 'level 2' do
      let(:md) { "## World\n" }
      it 'applies bold+underline' do
        expect(render).to eq "\e[1m\e[4mWorld\e[0m\e[0m\n"
      end
    end

    context 'level 3' do
      let(:md) { "### Deep\n" }
      it 'applies bold+underline' do
        expect(render).to eq "\e[1m\e[4mDeep\e[0m\e[0m\n"
      end
    end
  end

  describe 'inline emphasis' do
    context 'strong' do
      let(:md) { "This is **bold** text.\n" }
      it 'wraps in bold' do
        expect(render).to eq "This is \e[1mbold\e[0m text.\n"
      end
    end

    context 'emphasis' do
      let(:md) { "This is *italic* text.\n" }
      it 'wraps in italic' do
        expect(render).to eq "This is \e[3mitalic\e[0m text.\n"
      end
    end

    context 'strikethrough' do
      let(:md) { "This is ~~gone~~ text.\n" }
      it 'wraps in strikethrough' do
        expect(render).to eq "This is \e[9mgone\e[0m text.\n"
      end
    end

    context 'code span' do
      let(:md) { "Use `puts` here.\n" }
      it 'wraps in blue' do
        expect(render).to eq "Use \e[34mputs\e[0m here.\n"
      end
    end

    context 'mixed inline' do
      let(:md) { "A **bold** and *em* and `code` word.\n" }
      it 'applies each style independently' do
        expect(render).to eq(
          "A \e[1mbold\e[0m and \e[3mem\e[0m and \e[34mcode\e[0m word.\n"
        )
      end
    end
  end

  describe 'code blocks' do
    context 'fenced with language' do
      let(:md) { "```ruby\nputs \"hi\"\n```\n" }
      it 'applies code style to content' do
        expect(render).to eq "\e[34mputs \"hi\"\n\e[0m"
      end
    end

    context 'fenced without language' do
      let(:md) { "```\nplain code\n```\n" }
      it 'applies code style to content' do
        expect(render).to eq "\e[34mplain code\n\e[0m"
      end
    end
  end

  describe 'blockquotes' do
    context 'single level' do
      let(:md) { "> quoted line\n" }
      it 'wraps in faint + double quotes' do
        expect(render).to eq " “\e[2mquoted line\e[0m”\n"
      end
    end

    context 'nested' do
      let(:md) { "> > nested\n" }
      it 'cycles to single quotes for inner level' do
        expect(render).to eq " “\e[2m‘nested’\e[0m”\n"
      end
    end
  end

  describe 'horizontal rule' do
    let(:md) { "---\n" }
    it 'renders full-width unicode line' do
      expect(render).to eq((?─ * 80) + "\n")
    end
  end

  describe 'lists' do
    context 'unordered' do
      let(:md) { "- one\n- two\n" }
      it 'prefixes with bullet' do
        expect(render).to eq "· one\n\n· two\n\n"
      end
    end

    context 'ordered' do
      let(:md) { "1. first\n2. second\n" }
      it 'prefixes with sequential numbers' do
        expect(render).to eq "1. first\n\n2. second\n\n"
      end
    end

    context 'nested unordered' do
      let(:md) { "- one\n  - sub\n- two\n" }
      it 'indents nested items by 2 spaces' do
        expect(render).to eq "· one\n\n  · sub\n  \n\n· two\n\n"
      end
    end
  end

  describe 'links' do
    let(:md) { "[click](https://example.com)\n" }
    it 'emits OSC 8 hyperlink' do
      expect(render).to eq "\e]8;;https://example.com\e\\click\e]8;;\e\\\n"
    end
  end

  describe 'images' do
    let(:md) { "![kitten](kitten.jpg)\n" }
    it 'prepends emoji and emits OSC 8 hyperlink' do
      expect(render).to eq "\e]8;;kitten.jpg\e\\🖼 kitten\e]8;;\e\\\n"
    end
  end

  describe 'paragraph' do
    context 'plain text' do
      let(:md) { "Just a paragraph.\n" }
      it 'outputs verbatim with trailing newline' do
        expect(render).to eq "Just a paragraph.\n"
      end
    end
  end
end
