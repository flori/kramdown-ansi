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

  ANSI_ESCAPES = /\e\[.*?m|\e\].*?(\e|\a)\\?/

  private_constant :ANSI_ESCAPES

  # Removes ANSI escape sequences from the given string.
  #
  # @param line [String] the string potentially containing ANSI escape codes.
  # @return [String] the string with all ANSI escape sequences removed.
  def remove_ansi_escapes(line)
    line.to_s.gsub(ANSI_ESCAPES, '')
  end

  # Returns the width of the terminal in characters, given a percentage.
  #
  # @param percentage [Numeric] the percentage value (defaults to 100.0)
  # @return [Integer] the calculated width
  def width(percentage: 100.0)
    ((Float(percentage) * Tins::Terminal.columns) / 100).floor
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
    result = +''
    text.scan(/(?<nws>\S+)|(?<ws>\s)/) do
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

  if defined?(Data)
    # A frozen data record for a single token in the `truncate` scan.
    #
    # +type+ is `:esc` (ANSI escape, zero display width) or
    # `:txt` (visible character, display width from
    # `Unicode::DisplayWidth`).
    # +value+ is the raw matched substring.
    # +length+ is the display width in terminal columns (0 for escapes).
    Token = Data.define(:type, :value, :length)
  else
    class Token < Struct.new(:type, :value, :length)
      def initialize(**opts)
        opts.each do |key, value|
          self.send("#{key}=", value)
        end
        freeze
      end
    end
  end

  private_constant :Token

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
    ellipsis_length = display_width(remove_ansi_escapes(ellipsis))
    found_esc       = false
    result          = +''

    return result if text.empty?
    return result if length < ellipsis_length

    current_length = 0
    tokens = []

    text.scan(/(?<esc>#{ANSI_ESCAPES})|(?<txt>.)/m) do
      token = Token.new(
        type:   $~[:esc] ? :esc : :txt,
        value:  $&,
        length: $~[:esc] ? 0 : display_width($&)
      )
      tokens << token
    end

    while token = tokens.shift
      if token.type == :esc
        found_esc = true
        result << token.value
        next
      end

      if current_length + token.length == length && tokens.empty?
        result << token.value
        current_length += token.length
        break
      elsif current_length + token.length + ellipsis_length > length
        result << ellipsis
        break
      elsif current_length + token.length + ellipsis_length == length
        result << token.value
        current_length += token.length
        remaining_text_length = tokens.select { _1.type == :txt }.map(&:length).sum
        if current_length + remaining_text_length == length
          next
        elsif current_length + remaining_text_length > length
          result << ellipsis
          break
        else
          next
        end
      else
        current_length += token.length
        result << token.value
      end

    end

    result << reset if found_esc && !result.end_with?(reset)
    result
  end
end
