require 'tins/terminal'
require 'term/ansicolor'

# A module that provides paging functionality for terminal output.
#
# The Pager module handles the logic for determining when to use a pager
# command like 'less' or 'more' when the output exceeds the terminal's line
# capacity. It also manages the execution of these pagers and ensures proper
# terminal state restoration when paging is used.
#
# @example Using the pager with a block
#   Kramdown::ANSI::Pager.pager(command: 'less', lines: 50) do |output|
#     output.puts "Content to display"
#   end
#
# @example Checking if a pager is needed
#   pager_command = Kramdown::ANSI::Pager.pager(command: 'more', lines: 100)
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
        rescue Interrupt, Errno::EPIPE
          pager_reset_screen
          return nil
        ensure
          output.close
        end
        my_pager
      else
        yield STDOUT
        nil
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

  # Resets the terminal screen by printing ANSI escape codes for reset, clear
  # screen, move home and show cursor.
  def pager_reset_screen
    c = Term::ANSIColor
    STDOUT.print c.reset, c.clear_screen, c.move_home, c.show_cursor
  end
end
