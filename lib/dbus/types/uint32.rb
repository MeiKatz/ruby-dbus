module DBus
  module Types
    class UInt32
      class << self
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
    end
  end
end
