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

  # The pager method manages terminal output paging functionality
  #
  # This method handles the logic for determining when to use a pager command
  # like 'less' or 'more' when the output exceeds the terminal's line capacity.
  # It also manages the execution of these pagers and ensures proper terminal
  # state restoration when paging is used.
  #
  # @param command [String] the pager command to use when paging is needed
  # @param lines [Integer] the number of lines to compare against terminal height
  # @yield [output, pid] when a block is provided, yields the output stream and child's process ID
  # @yieldparam output [IO] the IO stream to write output to
  # @yieldparam pid [Integer] the process ID of the pager subprocess
  # @return [String, nil] the pager command string if paging was used, nil otherwise
  def pager(command: nil, lines: nil, &block)
    if block
      if my_pager = pager(command:, lines:)
        IO.popen(my_pager, 'w') do |output|
          output.sync = true
          yield output, output.pid
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
