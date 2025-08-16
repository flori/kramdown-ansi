require 'kramdown'
require 'kramdown-parser-gfm'
require 'terminal-table'
require 'term/ansicolor'

# A namespace module for the Kramdown::ANSI library.
#
# The Kramdown module serves as the root namespace for the Kramdown::ANSI
# library, which provides functionality for rendering Markdown documents with
# ANSI escape sequences in terminal environments. This module encapsulates the
# core components and converters necessary for transforming Markdown content
# into beautifully formatted terminal output.
module Kramdown
  class Kramdown::ANSI < Kramdown::Converter::Base
  end
end
require 'kramdown/ansi/width'
require 'kramdown/ansi/pager'
require 'kramdown/ansi/styles'

# A converter class that transforms Kramdown documents into ANSI-formatted
# terminal output.
#
# The Kramdown::ANSI class extends Kramdown::Converter::Base to provide
# functionality for rendering Markdown documents with ANSI escape sequences for
# terminal display. It handles various Markdown elements such as headers,
# paragraphs, lists, and code blocks, applying configurable ANSI styles to
# enhance the visual presentation in terminals.
#
# @example Converting a markdown string to ANSI formatted output
#   ansi_output = Kramdown::ANSI.parse(markdown_string)
#
# @example Using custom ANSI styles
#   styles = { header: [:bold, :underline], code: :red }
#   ansi_output = Kramdown::ANSI.parse(markdown_string, ansi_styles: styles)
class Kramdown::ANSI < Kramdown::Converter::Base
  include Kramdown::ANSI::Width

  # A utility module that provides ANSI escape sequence removal functionality
  # for terminal table content.
  #
  # The Terminal::Table::Util module contains helper methods for processing
  # text that may contain ANSI escape sequences, particularly for cleaning up
  # terminal table output before further processing or display.
  #
  # @example Removing ANSI escape sequences from table lines
  #   cleaned_line = Terminal::Table::Util.ansi_escape("\e[1mBold Text\e[0m")
  module Terminal::Table::Util
    # Removes ANSI escape sequences from the given line of text.
    #
    # This method strips out all ANSI escape codes that are commonly used to
    # format terminal output with colors, styles, and cursor movements.
    #
    # @param line [String] the input string that may contain ANSI escape
    # sequences
    # @return [String] a copy of the input string with all ANSI escape
    # sequences removed
    def self.ansi_escape(line)
      line.to_s.gsub(/\e\[.*?m|\e\].*?(\e|\a)\\?/, '')
    end
  end

  # A custom Markdown parser that extends GFM to provide enhanced parsing
  # capabilities for Kramdown::ANSI.
  #
  # This class modifies the standard GFM parser by disabling certain quirks and
  # removing specific block and span parsers to tailor the Markdown processing
  # for ANSI terminal output.
  #
  # @example Using the Mygfm parser with Kramdown::ANSI
  #   parser = Kramdown::Parser::Mygfm.new(markdown_content, {})
  #   document = Kramdown::Document.new(markdown_content, input: :mygfm)
  class ::Kramdown::Parser::Mygfm <  ::Kramdown::Parser::GFM
    def initialize(source, options)
      options[:gfm_quirks] << :no_auto_typographic
      super
      @block_parsers -= %i[
        definition_list block_html block_math
        footnote_definition abbrev_definition
      ]
      @span_parsers -= %i[ footnote_marker inline_math ]
    end
  end

  # Parses the given markdown source into ANSI formatted terminal output.
  #
  # @param source [String] the markdown content to be converted
  # @param options [Hash] additional options for the parsing process
  # @return [String] the ANSI formatted terminal output
  def self.parse(source, options = {})
    options = { input: :mygfm, auto_ids: false, entity_output: :as_char }.merge(
      options.transform_keys(&:to_sym)
    )
    @doc = Kramdown::Document.new(source, options).to_ansi
  end

  # Initializes a new Kramdown::ANSI converter instance with optional ANSI
  # styling configuration.
  #
  # @param root [Kramdown::Element] the root element of the document to convert
  # @param options [Hash] additional options for the conversion process
  # @return [void]
  def initialize(root, options)
    @ansi_styles = Kramdown::ANSI::Styles.new.configure(options.delete(:ansi_styles))
    super
  end

  # The convert method dispatches to type-specific conversion methods based on
  # the element's type.
  #
  # @param el [Kramdown::Element] the element to convert
  # @param opts [Hash] additional options for the conversion process
  # @return [String] the converted content of the element
  def convert(el, opts = {})
    send("convert_#{el.type}", el, opts)
  end

  # The inner method processes child elements of a given element and applies
  # optional block processing to each child.
  #
  # @param el [Kramdown::Element] the element whose children will be processed
  # @param opts [Hash] additional options for the processing
  # @yield [Kramdown::Element, Integer, String] optional block to customize processing of each child element
  # @yieldparam inner_el [Kramdown::Element] the current child element being processed
  # @yieldparam index [Integer] the index of the current child element
  # @yieldparam content [String] the converted content of the current child element
  # @return [String] the concatenated result of processing all child elements
  def inner(el, opts, &block)
    result = +''
    options = opts.dup.merge(parent: el)
    el.children.each_with_index do |inner_el, index|
      options[:index] = index
      options[:result] = result
      begin
        content = send("convert_#{inner_el.type}", inner_el, options)
        result << (block&.(inner_el, index, content) || content)
      rescue NameError => e
        warning "Caught #{e.class} for #{inner_el.type}"
      end
    end
    result
  end

  # The convert_root method processes the root element of a Kramdown document.
  #
  # This method serves as the entry point for converting the top-level element
  # of a Markdown document into its ANSI-formatted terminal representation.
  # It delegates the actual processing to the inner method, which handles
  # the recursive conversion of child elements.
  #
  # @param el [Kramdown::Element] the root element to convert
  # @param opts [Hash] additional options for the conversion process
  # @return [String] the ANSI formatted content of the root element and its children
  def convert_root(el, opts)
    inner(el, opts)
  end

  # The convert_blank method handles blank line conversion in Markdown
  # documents.
  #
  # This method determines whether a blank element should produce output based
  # on the context of the surrounding content. It checks if the current result
  # ends with double newlines or is empty, and returns an appropriate newline
  # character to maintain proper spacing in the rendered output.
  #
  # @param _el [Kramdown::Element] the blank element being converted (unused)
  # @param opts [Hash] conversion options containing the result context
  # @return [String] either an empty string or a single newline character
  def convert_blank(_el, opts)
    opts[:result] =~ /\n\n\Z|\A\Z/ ? "" : "\n"
  end

  # The convert_text method processes a text element by extracting its value.
  #
  # @param el [Kramdown::Element] the text element to convert
  # @param _opts [Hash] additional options (unused)
  # @return [String] the raw text content of the element
  def convert_text(el, _opts)
    el.value
  end

  # The convert_header method processes a header element by applying ANSI
  # styling and adding a newline.
  #
  # @param el [Kramdown::Element] the header element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the styled header content with a trailing newline
  def convert_header(el, opts)
    newline apply_style(:header) { inner(el, opts) }
  end

  # The convert_p method processes a paragraph element by calculating the
  # appropriate text width based on the terminal size and list indentation,
  # then wraps the content accordingly.
  #
  # @param el [Kramdown::Element] the paragraph element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the wrapped and formatted paragraph content with proper newlines
  def convert_p(el, opts)
    length = width(percentage: 90) - opts[:list_indent].to_i
    length < 0 and return ''
    newline wrap(inner(el, opts), length:)
  end

  # The convert_strong method processes a strong emphasis element by applying
  # ANSI styling to its content.
  #
  # @param el [Kramdown::Element] the strong element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the styled strong content
  def convert_strong(el, opts)
    apply_style(:strong) { inner(el, opts) }
  end

  # The convert_em method processes an emphasis element by applying ANSI
  # styling to its content.
  #
  # @param el [Kramdown::Element] the emphasis element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the styled emphasis content
  def convert_em(el, opts)
    apply_style(:em) { inner(el, opts) }
  end

  # The convert_a method processes an anchor element by applying hyperlink
  # formatting to its content.
  #
  # @param el [Kramdown::Element] the anchor element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the hyperlink formatted content
  def convert_a(el, opts)
    url = el.attr['href']
    hyperlink(url) { inner(el, opts) }
  end

  # The convert_codespan method processes a code span element by applying ANSI
  # styling to its content.
  #
  # @param el [Kramdown::Element] the code span element to convert
  # @param _opts [Hash] additional options (unused)
  # @return [String] the styled code span content
  def convert_codespan(el, _opts)
    apply_style(:code) { el.value }
  end

  # The convert_codeblock method processes a code block element by applying
  # ANSI styling to its content.
  #
  # @param el [Kramdown::Element] the code block element to convert
  # @param _opts [Hash] additional options (unused)
  # @return [String] the styled code block content
  def convert_codeblock(el, _opts)
    apply_style(:code) { el.value }
  end

  # The convert_blockquote method processes a blockquote element by applying
  # proper formatting.
  #
  # This method takes a blockquote element and formats its content with
  # quotation marks while ensuring appropriate newline handling. It delegates
  # the inner content processing to the inner method and then wraps the result
  # with quotation marks.
  #
  # @param el [Kramdown::Element] the blockquote element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the formatted blockquote content with quotation marks and
  # proper newlines
  def convert_blockquote(el, opts)
    newline ?“ + inner(el, opts).sub(/\n+\z/, '') + ?”
  end

  # The convert_hr method processes a horizontal rule element by generating a
  # full-width separator line.
  #
  # This method creates a horizontal rule (divider) using the Unicode
  # line-drawing character and applies proper newline formatting to ensure
  # correct spacing in the terminal output.
  #
  # @param _el [Kramdown::Element] the horizontal rule element to convert (unused)
  # @param _opts [Hash] conversion options (unused)
  # @return [String] a formatted horizontal rule line spanning the full
  # terminal width with newlines
  def convert_hr(_el, _opts)
    newline ?─ * width(percentage: 100)
  end

  # The convert_img method processes an image element by extracting its source
  # URL and alternative text, formatting the display with a fallback to the URL
  # if the alt text is empty, and applying hyperlink styling.
  #
  # @param el [Kramdown::Element] the image element to convert
  # @param _opts [Hash] additional options (unused)
  # @return [String] the formatted image content with hyperlink styling
  def convert_img(el, _opts)
    url = el.attr['src']
    alt = el.attr['alt']
    alt.strip.size == 0 and alt = url
    alt = '🖼 ' + alt
    hyperlink(url) { alt }
  end

  # The convert_ul method processes an unordered list element by applying
  # bullet point formatting and indentation.
  #
  # This method takes an unordered list element and formats its child elements
  # with bullet points, applying appropriate newline handling based on the list
  # item's position, and adding indentation to align the content properly
  # within the terminal output.
  #
  # @param el [Kramdown::Element] the unordered list element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the formatted unordered list content with bullet points
  # and proper indentation
  def convert_ul(el, opts)
    list_indent = opts[:list_indent].to_i
    inner(el, opts) { |_inner_el, index, content|
      result = '· %s' % content
      result = newline(result, count: index <= el.children.size - 1 ? 1 : 2)
      result.gsub(/^/, ' ' * list_indent)
    }
  end

  # The convert_ol method processes an ordered list element by applying
  # numbered bullet point formatting and indentation.
  #
  # This method takes an ordered list element and formats its child elements
  # with sequential numbers, applying appropriate newline handling based on the
  # list item's position, and adding indentation to align the content properly
  # within the terminal output.
  #
  # @param el [Kramdown::Element] the ordered list element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the formatted ordered list content with numbered points
  # and proper indentation
  def convert_ol(el, opts)
    list_indent = opts[:list_indent].to_i
    inner(el, opts) { |_inner_el, index, content|
      result = '%u. %s' % [ index + 1, content ]
      result = newline(result, count: index <= el.children.size - 1 ? 1 : 2)
      result.gsub(/^/, ' ' * list_indent)
    }
  end

  # The convert_li method processes a list item element by applying indentation
  # and handling newlines.
  #
  # This method takes a list item element and modifies the conversion options
  # to include appropriate indentation for nested lists. It then delegates the
  # inner content processing to the inner method and ensures proper newline
  # handling at the end of the content.
  #
  # @param el [Kramdown::Element] the list item element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the formatted list item content with proper indentation
  # and newlines
  def convert_li(el, opts)
    opts = opts.dup
    opts[:list_indent] = 2 + opts[:list_indent].to_i
    newline inner(el, opts).sub(/\n+\Z/, '')
  end

  # The convert_html_element method processes HTML inline elements such as <i>,
  # <em>, <b>, and <strong> by applying the corresponding ANSI styles to their
  # content. It handles emphasis and strong formatting tags specifically, while
  # ignoring other HTML elements by returning an empty string.
  #
  # @param el [Kramdown::Element] the HTML element being converted
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the styled content for emphasis or strong elements, or an
  # empty string for other elements
  def convert_html_element(el, opts)
    if el.value == 'i' || el.value == 'em'
      apply_style(:em) { inner(el, opts) }
    elsif el.value == 'b' || el.value == 'strong'
      apply_style(:strong) { inner(el, opts) }
    else
      ''
    end
  end

  # The convert_table method processes a table element by creating a terminal
  # table instance, applying styling and alignment options, and generating
  # formatted output with newlines.
  #
  # @param el [Kramdown::Element] the table element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the formatted table content with proper styling and newlines
  def convert_table(el, opts)
    table = Terminal::Table.new
    table.style = {
      all_separators: true,
      border: :unicode_round,
    }
    opts[:table] = table
    inner(el, opts)
    el.options[:alignment].each_with_index do |a, i|
      a == :default and next
      opts[:table].align_column(i, a)
    end
    newline table.to_s
  end

  # The convert_thead method processes a table header element by extracting and
  # formatting the heading rows from the table content, then assigns them to
  # the terminal table instance.
  #
  # @param el [Kramdown::Element] the table header element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] an empty string to indicate successful processing and
  # assignment of headings to the table instance
  def convert_thead(el, opts)
    rows = inner(el, opts)
    rows = rows.split(/\s*\|\s*/)[1..].map(&:strip)
    opts[:table].headings = rows
    ''
  end

  # The convert_tbody method processes a table body element by collecting its
  # inner content.
  #
  # This method handles the conversion of HTML table body elements, gathering
  # all child elements' content and returning it as a string. It serves as part
  # of the table conversion process, working in conjunction with other
  # table-related methods to generate properly formatted terminal output.
  #
  # @param el [Kramdown::Element] the table body element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the concatenated content of all child elements within the
  # table body
  def convert_tbody(el, opts)
    res = +''
    res << inner(el, opts)
  end

  # The convert_tfoot method handles the conversion of table footer elements.
  #
  # This method processes table footer elements by returning an empty string,
  # effectively ignoring footer content during the ANSI terminal output
  # conversion. It is part of the table conversion process, working alongside
  # other table-related methods to generate properly formatted terminal output.
  #
  # @param el [Kramdown::Element] the table footer element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] an empty string to indicate successful handling of the
  # footer element
  def convert_tfoot(el, opts)
    ''
  end

  # The convert_tr method processes a table row element by calculating column
  # widths based on content size, wrapping text to fit within the terminal
  # width, and adding the formatted row to the terminal table instance.
  #
  # @param el [Kramdown::Element] the table row element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] an empty string to indicate successful processing and
  # addition of the row to the table instance
  def convert_tr(el, opts)
    return '' if el.children.empty?
    full_width = width(percentage: 90)
    cols = el.children.map { |c| convert(c, opts).strip }
    row_size = cols.sum(&:size)
    return '' if row_size.zero?
    opts[:table] << cols.map { |c|
      length = (full_width * (c.size / row_size.to_f)).floor
      wrap(c, length:)
    }
    ''
  end

  # The convert_td method processes a table data cell element by delegating its
  # content conversion to the inner method.
  #
  # @param el [Kramdown::Element] the table data cell element to convert
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] the converted content of the table data cell element
  def convert_td(el, opts)
    inner(el, opts)
  end

  # The convert_entity method processes an entity element by extracting its
  # character value.
  #
  # @param el [Kramdown::Element] the entity element to convert
  # @param _opts [Hash] additional options (unused)
  # @return [String] the character representation of the entity
  def convert_entity(el, _opts)
    el.value.char
  end

  # The convert_xml_comment method handles XML comment elements by returning an
  # empty string.
  #
  # This method is part of the Kramdown::ANSI converter and is responsible for
  # processing XML comment elements that appear in the Markdown document. It
  # ignores XML comments during the ANSI terminal output conversion process,
  # returning an empty string to indicate that no content should be rendered
  # for these elements.
  #
  # @return [String] an empty string to indicate that XML comments are ignored
  # during conversion
  def convert_xml_comment(*)
    ''
  end

  # The convert_xml_pi method handles the conversion of XML processing
  # instruction elements.
  #
  # This method is part of the Kramdown::ANSI converter and is responsible for
  # processing XML processing instruction elements that appear in the Markdown
  # document. It ignores these elements during the ANSI terminal output
  # conversion process, returning an empty string to indicate that no content
  # should be rendered for these elements.
  #
  # @return [String] an empty string to indicate that XML processing
  # instructions are ignored during conversion
  def convert_xml_pi(*)
    ''
  end

  # The convert_br method handles the conversion of line break elements.
  #
  # This method processes HTML line break elements (br tags) by returning an
  # empty string, effectively ignoring them during the ANSI terminal output
  # conversion process. It is part of the Kramdown::ANSI converter's element
  # handling suite.
  #
  # @param _el [Kramdown::Element] the line break element being converted (unused)
  # @param opts [Hash] conversion options containing context for processing
  # @return [String] an empty string to indicate that line breaks are ignored
  # during conversion
  def convert_br(_el, opts)
    ''
  end

  # The convert_smart_quote method processes smart quote entities by
  # determining whether to output a double quotation mark or single quotation
  # mark based on the entity's type.
  #
  # @param el [Kramdown::Element] the smart quote element being converted
  # @param _opts [Hash] additional options (unused)
  # @return [String] a double quotation mark for right double quotes or left
  # double quotes, and a single quotation mark for other smart quote entities
  def convert_smart_quote(el, _opts)
    el.value.to_s =~ /[rl]dquo/ ? "\"" : "'"
  end

  # The newline method appends a specified number of newline characters to the
  # end of a given text string.
  #
  # @param text [String] the input text to which newlines will be appended
  # @param count [Integer] the number of newline characters to append (defaults to 1)
  # @return [String] the text with the specified number of trailing newline characters
  def newline(text, count: 1)
    text.gsub(/\n*\z/, ?\n * count)
  end

  private

  # The apply_style method applies ANSI styling to content by utilizing the
  # configured styles and yielding the content to be styled.
  #
  # @param name [Symbol] the style name to apply
  # @yield [String] the content to be styled
  # @return [String] the content with the specified ANSI styles applied
  def apply_style(name, &block)
    @ansi_styles.apply(name, &block)
  end
end

Kramdown::Converter.const_set(:Ansi, Kramdown::ANSI)
