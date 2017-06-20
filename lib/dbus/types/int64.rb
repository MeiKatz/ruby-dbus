module DBus
  module Types
    class Int64 < AbstractType
      class << self
        def code
          @code ||= "x".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end

        def marshall(value)
          [value].pack("q")
        end

        def unmarshall(value, endianness:)
          packet = UInt64.unmarshall(value, endianness: endianness)

          unless (packet & 0x8000000000000000) == 0
            packet -= 0x10000000000000000
          end

          packet
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "INT64"
      end
    end
  end
end
