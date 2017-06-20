module DBus
  module Types
    class UInt64 < AbstractType
      class << self
        def code
          @code ||= "t".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end

        def marshall(value)
          [value].pack("Q")
        end

        def unmarshall(value, endianness:)
          packet_l = value.byteslice(0..3)
          packet_h = value.byteslice(4..7)

          packet_l = UInt32.unmarshall(packet_l, endianness: endianness)
          packet_h = UInt32.unmarshall(packet_h, endianness: endianness)

          case endianness
          when LIL_END then packet_l + (packet_h << 32)
          when BIG_END then (packet_l << 32) + packet_h
          else raise InvalidPacketException, "Incorrect endianness #{endianness}"
          end
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "UINT64"
      end
    end
  end
end
