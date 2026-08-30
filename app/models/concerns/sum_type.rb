# frozen_string_literal: true

# Closed, exhaustively-matched sum types over plain Data classes.
# A matcher validates when it is built, and matchers are constants, so the
# check runs at load — which under Rails eager loading means at boot.
module SumType
  class Error < StandardError; end
  class NonExhaustiveMatch < Error; end
  class UnknownVariant < Error; end
  class UnrecognisedValue < Error; end

  def variants(**map)
    raise Error, 'variants already declared' if defined?(@variants) && @variants

    @key_by_class = map.invert.freeze
    @variants = map.freeze
  end

  def variants_map
    @variants || raise(Error, "#{self} declares no variants — call `variants(tag: SomeClass, ...)` first")
  end

  # routed through variants_map so an undeclared sum still fails honestly
  def key_by_class = variants_map && @key_by_class

  def variant?(klass) = key_by_class.key?(klass)
  def member?(value) = key_by_class.key?(value.class) || variants_map.values.any? { value.is_a?(it) }

  def matcher(**handlers)
    keys    = variants_map.keys
    missing = keys - handlers.keys
    unknown = handlers.keys - keys
    raise NonExhaustiveMatch, "missing handlers for: #{missing.join(', ')}" if missing.any?
    raise UnknownVariant,     "no such variant(s): #{unknown.join(', ')}"   if unknown.any?

    Matcher.new(sum: self, handlers: handlers.freeze)
  end

  Matcher = Data.define(:sum, :handlers) do
    def call(value, ...)
      key = sum.key_by_class[value.class] ||
            sum.variants_map.find { |_k, type| value.is_a?(type) }&.first
      raise UnrecognisedValue, "#{value.class} is not a #{sum} variant" if key.nil?

      handlers.fetch(key).call(value, ...)
    end
    alias_method :match, :call
    alias_method :[], :call

    def to_proc = method(:call).to_proc
  end
end
