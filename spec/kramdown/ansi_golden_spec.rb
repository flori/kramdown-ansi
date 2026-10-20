require 'spec_helper'

describe 'Kramdown::ANSI golden files' do
  before do
    allow(Tins::Terminal).to receive(:columns).and_return 80
  end

  Dir[File.join(__dir__, '../assets/*.md')].each do |md|
    name = File.basename(md, '.md')
    expected_path = md.sub('.md', '.ansi')

    it "renders #{name} matching golden file" do
      skip "no golden file at #{expected_path}" unless File.exist?(expected_path)
      expected = File.read(expected_path)
      actual   = Kramdown::ANSI.parse(File.read(md))
      expect(actual).to eq(expected)
    end
  end
end
