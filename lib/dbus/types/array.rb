module DBus
  module Types
    class Array < AbstractType
      class << self
        def code
          @code ||= "a".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def basic_type?
          false
        end
      end

      def initialize(subtype)
        @subtype = subtype
      end

      def to_s
        "a#{subtype.to_s}"
      end

      private

      attr_reader :subtype
    end
  end
end
