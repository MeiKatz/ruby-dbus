module DBus
  module Types
    class Byte < AbstractType
      class << self
        def code
          @code ||= "y".freeze
        end

        def alignment
          @alignment ||= 1.freeze
        end

        def marshall(value)
          value.chr
        end

        def unmarshall(value)
          value.unpack("C")[0]
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "BYTE"
      end
    end
  end
end
