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

  # Wraps text to a specified width.
  #
  # @param text [String] the text to wrap
  # @option percentage [Numeric] the percentage value for the width (defaults to nil)
  # @option length [Integer] the character length for the width (defaults to nil)
  # @return [String] the wrapped text
  # @raise [ArgumentError] if neither `percentage` nor `length` is provided
  def wrap(text, percentage: nil, length: nil)
    percentage.nil? ^ length.nil? or
      raise ArgumentError, "either pass percentage or length argument"
    percentage and length ||= width(percentage:)
    text.gsub(/(?<!\n)\n(?!\n)/, ' ').lines.map do |line|
      if length >= 1 && uncolor { line }.length > length
        line.gsub(/(.{1,#{length}})(\s+|$)/, "\\1\n").strip
      else
        line.strip
      end
    end * ?\n
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
