module DBus
  module Types
    class Double
      class << self
        def code
          @code ||= "d".freeze
        end

        def marshall(value)
          [value].pack("d")
        end

        def unmarshall(value, endianness:)
          case endianness
          when LIL_END then value.unpack("G")[0]
          when BIG_END then value.unpack("E")[0]
          else raise InvalidPacketException, "Incorrect endianness #{endianness}"
          end
        end
      end
    end
  end
end
