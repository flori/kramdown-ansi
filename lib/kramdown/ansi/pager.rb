require 'tins/terminal'

module Kramdown::ANSI::Pager
  module_function

  # If called without a block returns either the provided command for paging if
  # the given number of lines are exceeding the available number of terminal
  # lines or nil. If a block was provided it yields to an IO handle for the
  # pager command in the latter case or STDOUT in the former.
  #
  # @param command [String] the pager command (optional)
  # @param lines [Integer] the number of lines in the output (optional)
  # @yield [IO] yields the output IO handle for further processing
  # @return [NilClass] returns nil if STDOUT is used or STDOUT is not a TTY.
  def pager(command: nil, lines: nil, &block)
    if block
      if my_pager = pager(command:, lines:)
        IO.popen(my_pager, 'w') do |output|
          output.sync = true
          yield output
          output.close
        end
      else
        yield STDOUT
      end
    else
      return unless STDOUT.tty?
      if lines
        if lines >= Tins::Terminal.lines
          pager(command:)
        end
      else
        command
      end
    end
  end
end
