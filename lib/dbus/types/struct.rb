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
        @subtypes = subtypes
      end

      def to_s
        "(#{subtypes.map(&:to_s).join})"
      end

      private

      attr_reader :subtypes
    end
  end
end
