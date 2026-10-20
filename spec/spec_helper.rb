require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
require 'rspec'
begin
  require 'debug'
rescue LoadError
end
require 'kramdown/ansi'

# A lightweight Lorem Ipsum generator.
#
# The generator uses a small pool of classic Latin words and
# randomly assembles them into sentences and paragraphs.
class LoremIpsum
  # Generates Lorem Ipsum text with the specified number of paragraphs and
  # average words per sentence.
  #
  # @param paragraphs [Integer] the number of paragraphs to generate (default: 3)
  # @param words_per_sentence [Integer] the average number of words per
  #   sentence (default: 10)
  # @return [String] the generated Lorem Ipsum text
  def self.generate(paragraphs: 3, words_per_sentence: 10, seed: nil)
    new.generate(paragraphs:, words_per_sentence:, seed:)
  end

  # Default word pool (classic Lorem Ipsum source)
  WORDS = %w[
    lorem ipsum dolor sit amet consectetur adipiscing elit sed do
    eiusmod tempor incididunt ut labore et dolore magna aliqua
    enim ad minim veniam quis nostrud exercitation ullamco
    laboris nisi ut aliquip ex ea commodo consequat duis aute
    irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur
    excepteur sint occaecat cupidatat non proident sunt
    culpa qui officia deserunt mollit anim id est laborum
  ].freeze

  # Generate a random word from the pool
  def random_word
    WORDS.sample random: @random
  end

  # Generate a sentence of a given length (in words)
  # @param words [Integer] number of words in the sentence
  # @return [String] a sentence ending with a period
  def sentence(words: 8)
    words.times.map { random_word }.join(' ').capitalize + '.'
  end

  # Generate a paragraph of a given number of sentences
  # @param sentences [Integer] number of sentences in the paragraph
  # @return [String] a paragraph ending with a newline
  def paragraph(sentences: 4)
    sentences.times.map { sentence }.join(' ') + "\n"
  end

  # Generate a full Lorem Ipsum text
  #
  # @param paragraphs [Integer] number of paragraphs
  # @param words_per_sentence [Integer] average words per sentence
  # @return [String] the generated text
  def generate(paragraphs: 3, words_per_sentence: 10, seed: nil)
    @random = seed ? Random.new(seed) : Random.new
    paragraphs.times.map do
      # For a bit of natural variation, pick a random number
      # of sentences around the requested average.
      sentences = @random.rand(words_per_sentence / 2..words_per_sentence * 2)
      paragraph(sentences: sentences)
    end.join("\n")
  end
end

def asset(name)
  File.join(__dir__, 'assets', name)
end

# A module that provides functionality for protecting environment variables
# during tests.
#
# This module ensures that environment variable changes made during test
# execution are automatically restored to their original values after the test
# completes. It is designed to prevent side effects between tests that modify
# environment variables, maintaining a clean testing environment.
module ProtectEnvVars
  # The apply method creates a lambda that protects environment variables
  # during test execution.
  #
  # @return [Proc] a lambda that wraps test execution with environment variable
  #   preservation
  def self.apply
    -> example do
      if example.metadata[:protect_env]
        begin
          stored_env = ENV.to_h
          example.run
        ensure
          ENV.replace(stored_env)
        end
      else
        example.run
      end
    end
  end
end

RSpec.configure do |config|
  config.around(&ProtectEnvVars.apply)
end
