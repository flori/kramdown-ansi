describe 'Kramdown::ANSI table' do
  before do
    allow(Tins::Terminal).to receive(:columns).and_return 80
  end

  lorem_cell = -> seed do
    LoremIpsum.generate(paragraphs: 1, words_per_sentence: 5, seed:).strip
  end

  ansi_lorem_cell = -> seed do
    lorem_cell.(seed).gsub(/\S+/) { |word|
      Term::ANSIColor.send(%i[ bold italic color208 color248 ].sample) { word }
    }
  end

  let(:no_ansi_markdown) do
    <<~EOT
      | Header 1 | Header 2 | Header 3 |
      |----------|----------|----------|
      | #{lorem_cell.(23)} | #{lorem_cell.(42)} | #{lorem_cell.(25)} |
    EOT
  end

  let(:ansi_markdown) do
    <<~EOT
      | Header 1 | Header 2 | Header 3 |
      |----------|----------|----------|
      | #{ansi_lorem_cell.(23)} | #{ansi_lorem_cell.(42)} | #{ansi_lorem_cell.(25)} |
    EOT
  end

  it 'renders a table w/o ANSI styling and correct borders' do
    no_ansi = Kramdown::ANSI.parse(no_ansi_markdown)
    # The table should contain the table separator character
    expect(no_ansi).to match(/─/)
    # The generated LoremIpsum text should appear in the output
    expect(no_ansi).to include(lorem_cell.(23)[0, 10])
    # No raw markdown markers should remain
    expect(no_ansi).not_to include('|')
  end

  it 'renders a table with ANSI styling and correct borders' do
    ansi = Kramdown::ANSI.parse(ansi_markdown)
    # The table should contain the table separator character
    expect(ansi).to match(/─/)
    # The generated LoremIpsum text should appear in the output
    expect(ansi).to include(lorem_cell.(23)[0, 10])
    # No raw markdown markers should remain
    expect(ansi).not_to include('|')
  end
end
