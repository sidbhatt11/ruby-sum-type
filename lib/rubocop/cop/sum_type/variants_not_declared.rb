# frozen_string_literal: true

module RuboCop
  module Cop
    module SumType
      # Flags a module that extends `SumType` but never calls `variants(...)`.
      # Until it does, every matcher and query against the sum raises on first
      # use — which the boot check only reaches if something already matches
      # on it. A reopening in the same file counts; one in another file does
      # not, so the cop stays quiet rather than guess.
      #
      # @example
      #   # bad - the registry is never built
      #   module JobStatus
      #     extend SumType
      #     Queued = Data.define
      #   end
      #
      #   # good
      #   module JobStatus
      #     extend SumType
      #     Queued = Data.define
      #     variants(queued: Queued)
      #   end
      class VariantsNotDeclared < Base
        MSG = '%<sum>s extends SumType but never declares its variants; ' \
              'add a `variants(tag: SomeClass, ...)` call.'

        def_node_matcher :extend_sum_type?, '(send nil? :extend (const _ :SumType))'
        def_node_matcher :variants_call?, '(send nil? :variants ...)'

        def on_send(node)
          return unless extend_sum_type?(node)

          sum = node.each_ancestor(:module, :class).first
          return if sum.nil? || variants_declared_for?(sum)

          add_offense(node, message: format(MSG, sum: qualified_name(sum)))
        end

        private

        def variants_declared_for?(sum)
          name = qualified_name(sum)
          processed_source.ast.each_node(:module, :class).any? do |other|
            qualified_name(other) == name && other.each_descendant(:send).any? { variants_call?(it) }
          end
        end

        def qualified_name(node)
          [*node.each_ancestor(:module, :class).map { const_path(it.children.first) }.reverse,
           const_path(node.children.first)].join('::')
        end

        def const_path(const_node)
          parts = []
          while const_node&.const_type?
            parts.unshift(const_node.children[1])
            const_node = const_node.children[0]
          end
          parts.join('::')
        end
      end
    end
  end
end
