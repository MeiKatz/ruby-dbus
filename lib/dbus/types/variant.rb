module DBus
  module Types
    class Variant < AbstractType
      class << self
        def code
          @code ||= "v".freeze
        end

        def alignment
          @alignment ||= 1.freeze
        end

        def basic_type?
          false
        end
      end

      def append_to(buffer, value:)
        # @todo
      end

      def inspect
        "VARIANT"
      end
    end
  end
end
