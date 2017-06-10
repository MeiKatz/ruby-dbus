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

        @key_type = key_type
        @value_type = value_type
      end

      def to_s
        "{#{key_type}#{value_type}}"
      end

      private

      attr_reader :key_type
      attr_reader :value_type
    end
  end
end
