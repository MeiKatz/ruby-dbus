module DBus
  module Types
    class Struct < AbstractType
      class << self
        def code
          @code ||= "r".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end

        def basic_type?
          false
        end
      end

      def initialize(*subtypes)
        if subtypes.size == 0
          raise "Struct must have at least one subtype"
        end

        @subtypes = subtypes
      end

      def append_to(buffer, value:)
        unless subtypes.size == value.size
          raise "wrong number of values (#{value.size} for #{subtypes.size})"
        end

        buffer = align_buffer_with_struct(buffer)
        append_elements(value, buffer: buffer)
      end

      def to_s
        "(#{subtypes.map(&:to_s).join})"
      end

      def inspect
        "STRUCT of (#{subtypes.map(&:inspect).join(", ")})"
      end

      private

      attr_reader :subtypes

      def align_buffer_with_struct(buffer)
        buffer.align(self.class.alignment)
      end

      def append_elements(elements, buffer:)
        elements.reduce(buffer) do |buffer, element|
          subtype.append_to(buffer, value: element)
        end
      end
    end
  end
end
