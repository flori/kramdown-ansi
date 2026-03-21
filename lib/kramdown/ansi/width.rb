require 'tins/terminal'
require 'term/ansicolor'

# A module that provides functionality for calculating terminal width
# percentages and wrapping/truncating text accordingly.
#
# The Width module includes methods to determine the available terminal width
# based on a percentage, and provides text wrapping and truncation capabilities
# that respect terminal dimensions.
#
# @example Wrapping text to 80% of terminal width
#   Kramdown::ANSI::Width.wrap("This is a long line of text", percentage: 80)
#
# @example Truncating text to 50 characters
#   Kramdown::ANSI::Width.truncate("This is a long line of text", length: 50)
module Kramdown::ANSI::Width
  include Term::ANSIColor
  extend Term::ANSIColor

  module_function

  # Returns the width of the terminal in characters, given a percentage.
  #
  # @param percentage [Numeric] the percentage value (defaults to 100.0)
  # @return [Integer] the calculated width
  def width(percentage: 100.0)
    ((Float(percentage) * Tins::Terminal.columns) / 100).floor
  end

  # Removes ANSI escape sequences from the given string.
  #
  # @param line [String] the string potentially containing ANSI escape codes.
  # @return [String] the string with all ANSI escape sequences removed.
  def remove_ansi_escapes(line)
    line.to_s.gsub(/\e\[.*?m|\e\].*?(\e|\a)\\?/, '')
  end

  # Calculates the display width of a string after removing ANSI escape
  # sequences.
  #
  # @param line [String] the string to measure
  # @return [Integer] the number of columns the string occupies in a terminal
  def display_width(line)
    Unicode::DisplayWidth.of(remove_ansi_escapes(line))
  end

  # Wraps a string to a given width, either by percentage of terminal
  # width or by an explicit character length.
  #
  # @param text [String] the text to wrap
  # @option percentage [Numeric] the percentage of terminal width to use
  # @option length [Integer] the explicit character width to wrap to
  # @return [String] the wrapped string, preserving ANSI escape sequences
  # @raise [ArgumentError] if neither `percentage` nor `length` is provided
  # @example
  #   Kramdown::ANSI::Width.wrap("Hello world!", percentage: 50)
  #   # => "Hello\nworld!"
  def wrap(text, percentage: nil, length: nil)
    percentage.nil? ^ length.nil? or
      raise ArgumentError, "either pass percentage or length argument"
    percentage and length ||= width(percentage:)
    return text if length <= 0
    begin
      length = length.to_i
    rescue FloatDomainError
      return text
    end
    length = length.clamp(1..)
    length_without_ansi = 0
    result = ''
    text.gsub(/(?<nws>\S+)|(?<ws>\s)/) do
      token_value  = $&
      token_length = display_width(token_value)
      if $~[:nws]
        if length_without_ansi + token_length > length
          length_without_ansi = token_length
          if result[-1] == ' '
            result[-1, 1] = "\n#{token_value}"
          else
            result << "\n#{token_value}"
          end
        else
          length_without_ansi += token_length
          result << token_value
        end
      else
        length_without_ansi += token_length
        result << token_value
      end
    end
    result
  end

  # Truncates a given string to a specified length or percentage. If the text
  # is longer an ellipsis sequence is added at the end of the generated string,
  # to indicate that a truncation has been performed.
  #
  # @param text [String] the input string to truncate
  # @option percentage [Numeric] the percentage value for the width (defaults to nil)
  # @option length [Integer] the character length for the width (defaults to nil)
  # @option ellipsis [Character] the truncation indicator (defaults to ?…)
  # @return [String] the truncated string
  # @raise [ArgumentError] if neither `percentage` nor `length` is provided
  def truncate(text, percentage: nil, length: nil, ellipsis: ?…)
    percentage.nil? ^ length.nil? or
      raise ArgumentError, "either pass percentage or length argument"
    percentage and length ||= width(percentage:)
    ellipsis_length = ellipsis.size
    if length < ellipsis_length
      +''
    elsif text.size >= length + ellipsis_length
      text[0, length - ellipsis_length] + ellipsis
    else
      text
    end
  end
end
