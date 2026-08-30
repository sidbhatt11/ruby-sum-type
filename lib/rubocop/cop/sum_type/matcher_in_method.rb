# frozen_string_literal: true

module RuboCop
  module Cop
    module SumType
      # Flags `SomeSum.matcher(...)` built inside a method. Such a matcher is
      # validated on first call, not at load, so the boot check never sees it.
      #
      # @example
      #   # bad - validated only when #describe is called
      #   def describe(shape)
      #     Shape.matcher(circle: ->(c) { c.radius }).call(shape)
      #   end
      #
      #   # good - validated at load, covered by the boot check
      #   DESCRIBE = Shape.matcher(circle: ->(c) { c.radius })
      #   def describe(shape) = DESCRIBE.call(shape)
      class MatcherInMethod < Base
        MSG = 'Build matchers in a constant, not inside a method, so the ' \
              'load-time exhaustiveness check can validate them.'

        def_node_matcher :matcher_call?, '(send (const _ _) :matcher ...)'

        def on_send(node)
          return unless matcher_call?(node)
          return unless node.each_ancestor(:def, :defs).any?

          add_offense(node)
        end
      end
    end
  end
end
