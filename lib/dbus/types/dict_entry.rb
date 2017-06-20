module DBus
  module Types
    class DictEntry < AbstractType
      class << self
        def code
          @code ||= "e".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end

        def basic_type?
          false
        end
      end

      def initialize(key_type, value_type)
        unless key_type.basic_type?
          raise "DictEntry key must be of basic type"
        end

        if value_type.is_a?(self.class)
          raise "DictEntry value must not be a DictEntry itself"
        end

        @key_type = key_type
        @value_type = value_type
      end

      def append_to(buffer, value:)
        buffer.append(value) do |buf|
          buf.append(value, type: t.code, padding: t.alignment)
        end

        buffer = buffer.align(self.class.alignment)

        [key_type, value_type].zip(value).reduce(buffer) do |buffer, (type, value)|
          type.append_to(buffer, value: value)
        end
      end

      def to_s
        "{#{key_type.to_s}#{value_type.to_s}}"
      end

      def inspect
        "DICT_ENTRY of (#{key_type.inspect}, #{value_type.inspect})"
      end

      private

      attr_reader :key_type
      attr_reader :value_type
    end
  end
end
