module DBus
  module Types
    class UInt32 < AbstractType
      class << self
        def code
          @code ||= "u".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          [value].pack("L")
        end

        def unmarshall(value, endianness:)
          case endianness
          when LIL_END then value.unpack("V")[0]
          when BIG_END then value.unpack("N")[0]
          else raise InvalidPacketException, "Incorrect endianness #{endianness}"
          end
        end
      end

      def inspect
        "UINT32"
      end
    end
  end
end
