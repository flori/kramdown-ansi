require 'spec_helper'

describe Kramdown::ANSI::Pager do
  let :command do
    'cat'
  end

  describe '.pager' do
    context 'with no TTY' do
      before do
        expect(STDOUT).to receive(:tty?).at_least(:once).and_return(false)
      end

      it 'returns nil if STDOUT is no TTY' do
        expect(Kramdown::ANSI::Pager.pager(command:)).to be_nil
      end
    end

    context 'with TTY' do
      before do
        expect(STDOUT).to receive(:tty?).at_least(:once).and_return(true)
      end

      it 'returns command if STDOUT is TTY' do
        expect(Kramdown::ANSI::Pager.pager(command:)).to eq command
      end

      it 'returns the provided command for paging if enough lines' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        expect(Kramdown::ANSI::Pager.pager(command: command, lines: 30)).to eq(command)
      end

      it 'returns nil if not enough lines' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        expect(Kramdown::ANSI::Pager.pager(command: command, lines: 23)).to be_nil
      end

      it 'can output to the command for paging if enough lines' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        block_called = false
        result = Kramdown::ANSI::Pager.pager(command: command, lines: 30) do |output|
          expect(output).to be_a IO
          expect(output).not_to eq STDOUT
          block_called = true
        end
        expect(block_called).to eq true
        expect(result).to eq command
      end

      it 'yields to output and pid' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        child_pid = nil
        result = Kramdown::ANSI::Pager.pager(command: command, lines: 30) do |output, pid|
          expect(pid).to be_a Integer
          expect(output).to be_a IO
          expect(output).not_to eq STDOUT
          child_pid    = pid
        end
        expect(child_pid).to be_a Integer
        expect(result).to eq command
      end

      it 'closes output for Interrupt' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        block_called = false
        expect_any_instance_of(IO).to receive(:sync=).and_raise Interrupt
        expect_any_instance_of(IO).to receive(:close).and_call_original
        expect(described_class).to receive(:pager_reset_screen)
        result = Kramdown::ANSI::Pager.pager(command: command, lines: 30) do |output|
          block_called = true
        end
        expect(block_called).to eq false
        expect(result).to be_nil
      end

      it 'closes output for Errno::EPIPE' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        block_called = false
        expect_any_instance_of(IO).to receive(:sync=).and_raise Errno::EPIPE
        expect_any_instance_of(IO).to receive(:close).and_call_original
        expect(described_class).to receive(:pager_reset_screen)
        result = Kramdown::ANSI::Pager.pager(command: command, lines: 30) do |output|
          block_called = true
        end
        expect(block_called).to eq false
        expect(result).to be_nil
      end


      it 'can output STDOUT if not enough lines' do
        expect(Tins::Terminal).to receive(:lines).and_return 25
        block_called = false
        Kramdown::ANSI::Pager.pager(command: command, lines: 23) do |output|
          expect(output).to eq STDOUT
          block_called = true
        end
        expect(block_called).to eq true
      end
    end
  end
end
