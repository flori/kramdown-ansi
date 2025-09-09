require 'json'

# A configuration class for managing ANSI styles used in Markdown rendering.
#
# The Styles class provides functionality to initialize default ANSI styling
# options for various Markdown elements and allows customization through
# JSON configuration or environment variables.
#
# @example Using default styles
#   styles = Kramdown::ANSI::Styles.new
#
# @example Creating styles from JSON configuration
#   json_config = '{"header": ["bold", "underline"], "code": "red"}'
#   styles = Kramdown::ANSI::Styles.from_json(json_config)
#
# @example Creating styles from environment variable
#   ENV['MY_STYLES'] = '{"em": "italic"}'
#   styles = Kramdown::ANSI::Styles.from_env_var('MY_STYLES')
class Kramdown::ANSI::Styles
  # Initializes a new instance with default ANSI styles configuration.
  #
  # Sets up the default styling options for various Markdown elements and
  # prepares the instance variable to hold the current ANSI style
  # configuration.
  def initialize
    @default_ansi_styles = {
      header: %i[ bold underline ],
      strong: :bold,
      em:     :italic,
      code:   :blue,
    }
    @ansi_styles = @default_ansi_styles.dup
  end

  # The default_ansi_styles reader method provides access to the default ANSI
  # style configuration used by the Styles class.
  #
  # This method returns the @default_ansi_styles instance variable, which holds
  # the predefined styling options for various Markdown elements before any
  # custom configuration has been applied.
  #
  # @return [Hash] the default ANSI styles configuration hash containing symbol keys
  # and style value arrays or single style values
  attr_reader :default_ansi_styles

  # The ansi_styles reader method provides access to the current ANSI style
  # configuration.
  #
  # This method returns the @ansi_styles instance variable, which holds the
  # active ANSI styling options used for formatting Markdown elements in
  # terminal output.
  #
  # @return [Hash] the current ANSI styles configuration hash
  attr_reader :ansi_styles

  # Creates a new instance by parsing JSON configuration and applying it.
  #
  # @param json [String] A JSON string containing the configuration options
  # @return [Kramdown::ANSI::Styles] A new instance with the parsed
  # configuration applied
  def self.from_json(json)
    new.configure(JSON.parse(json))
  end

  # Creates a new Styles instance by parsing JSON configuration from an
  # environment variable.
  #
  # @param name [String] the name of the environment variable containing the
  # JSON configuration
  # @return [Kramdown::ANSI::Styles] a new instance with the parsed
  # configuration applied
  def self.from_env_var(name)
    from_json(ENV.fetch(name))
  end

  # Configures the ANSI styles using the provided options.
  #
  # Merges the given options with the default ANSI styles to customize the
  # styling configuration for Markdown elements.
  #
  # @param options [Hash] a hash containing style configuration options
  # @return [Kramdown::ANSI::Styles] returns self to allow for method chaining
  def configure(options)
    options_ansi_styles = options.to_h.transform_keys(&:to_sym).
      transform_values {
        array = Array(_1).map(&:to_sym)
        array.size == 1 ? array.first : array
      }
    @ansi_styles = @default_ansi_styles.merge(options_ansi_styles)
    self
  end

  # Applies ANSI styles to the given text block based on the specified style
  # name.
  #
  # @param name [Symbol] the style name to apply
  # @yield [String] the text to be styled
  # @return [String] the text with ANSI styles applied
  def apply(name, &block)
    styles = Array(@ansi_styles.fetch(name))
    styles.reverse_each.reduce(block.()) do |text, style|
      if style.is_a?(Symbol) || style.is_a?(String)
        text = Term::ANSIColor.send(style) { text }
      end
      text
    end
  end

  # The as_json method converts the current ANSI styles configuration into a
  # JSON-serializable format.
  #
  # @param ignored [Array] ignored args
  # @return [Hash] A hash representation of the current ANSI styles configuration.
  def as_json(*ignored)
    @ansi_styles
  end

  alias to_hash as_json

  alias to_h to_hash

  # The to_json method converts the current ANSI styles configuration into a
  # JSON-serializable format.
  #
  # @param args [Array] pass-through args
  # @return [String] A JSON string representation of the current ANSI styles
  # configuration.
  def to_json(*args)
    as_json.to_json(*args)
  end
end
