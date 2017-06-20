module DBus
  module Types
    class Int32 < AbstractType
      class << self
        def code
          @code ||= "i".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          [value].pack("l")
        end

        def unmarshall(value, endianness:)
          packet = UInt32.unmarshall(value, endianness: endianness)

          unless (packet & 0x80000000) == 0
            packet -= 0x100000000
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
        "INT32"
      end
    end
  end
end
