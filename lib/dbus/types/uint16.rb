module DBus
  module Types
    class UInt16 < AbstractType
      class << self
        def code
          @code ||= "q".freeze
        end

        def alignment
          @alignment ||= 2.freeze
        end

        def marshall(value)
          [value].pack("S")
        end

        def unmarshall(value, endianness:)
          case endianness
          when LIL_END then value.unpack("v")[0]
          when BIG_END then value.unpack("n")[0]
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
        "UINT16"
      end
    end
  end
end
