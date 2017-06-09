module DBus
  module Types
    class UInt16
      class << self
        def code
          @code ||= "q".freeze
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
    end
  end
end
