# frozen_string_literal: true

require_relative 'test_helper'

module Colour
  extend SumType

  Red  = Data.define
  Blue = Data.define(:shade)

  variants(red: Red, blue: Blue)
end

# Carriers in an inheritance relationship: dispatch must still find Circle,
# which is not a key in the class index.
class Shape; end
class Circle < Shape; end

module Shapes
  extend SumType

  variants(shape: Shape)
end

class SumTypeTest < Minitest::Test
  DESCRIBE = Colour.matcher(red: ->(_) { 'red' }, blue: ->(c) { "blue #{c.shade}" })
  SHAPES   = Shapes.matcher(shape: ->(_) { 'a shape' })

  def test_dispatches_on_exact_class
    assert_equal 'red', DESCRIBE.call(Colour::Red.new)
    assert_equal 'blue navy', DESCRIBE.call(Colour::Blue.new(shade: 'navy'))
  end

  # The class index is keyed on exact classes, so a subclass misses it. The
  # is_a? scan behind the index is what keeps this working; delete it and this
  # is the test that fails.
  def test_falls_back_to_is_a_scan_for_subclasses
    assert_equal 'a shape', SHAPES.call(Circle.new)
  end

  def test_forwards_extra_arguments_to_the_handler
    matcher = Colour.matcher(red: ->(_, n) { 'red ' * n }, blue: ->(_, _n) { 'blue' })

    assert_equal 'red red ', matcher.call(Colour::Red.new, 2)
  end

  def test_rejects_a_value_that_is_not_a_variant
    error = assert_raises(SumType::UnrecognisedValue) { DESCRIBE.call('not a colour') }

    assert_includes error.message, 'String is not a Colour variant'
  end

  def test_rejects_a_matcher_missing_a_variant
    error = assert_raises(SumType::NonExhaustiveMatch) { Colour.matcher(red: ->(_) { 'red' }) }

    assert_includes error.message, 'missing handlers for: blue'
  end

  def test_rejects_a_matcher_naming_an_unknown_variant
    error = assert_raises(SumType::UnknownVariant) do
      Colour.matcher(red: ->(_) { '' }, blue: ->(_) { '' }, green: ->(_) { '' })
    end

    assert_includes error.message, 'no such variant(s): green'
  end

  def test_rejects_declaring_variants_twice
    assert_raises(SumType::Error) { Colour.variants(red: Colour::Red) }
  end

  def test_an_undeclared_sum_fails_honestly
    sum = Module.new { extend SumType }

    assert_raises(SumType::Error) { sum.variants_map }
    assert_raises(SumType::Error) { sum.key_by_class }
    assert_raises(SumType::Error) { sum.variant?(String) }
    assert_raises(SumType::Error) { sum.matcher(anything: ->(_) { '' }) }
  end

  def test_variant_asks_about_a_class
    assert Colour.variant?(Colour::Red)
    refute Colour.variant?(String)
  end

  def test_member_asks_about_a_value
    assert Colour.member?(Colour::Red.new)
    assert Shapes.member?(Circle.new)
    refute Colour.member?('not a colour')
  end

  def test_call_has_aliases
    red = Colour::Red.new

    assert_equal 'red', DESCRIBE.match(red)
    assert_equal 'red', DESCRIBE[red]
    assert_equal ['red'], [red].map(&DESCRIBE)
  end

  def test_a_matcher_is_frozen
    assert_predicate DESCRIBE, :frozen?
    assert_predicate DESCRIBE.handlers, :frozen?
  end
end
