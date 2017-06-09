module DBus
  module Types
    class Boolean < AbstractType
      class << self
        def code
          @code ||= "b".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          if value
            [1].pack("L")
          else
            [0].pack("L")
          end
        end

        def unmarshall(value, endianness:)
          packet =
            case endianness
            when LIL_END then value.unpack("V")[0]
            when BIG_END then value.unpack("N")[0]
            else raise InvalidPacketException, "Incorrect endianness #{endianness}"
            end

          case packet
            when 0 then false
            when 1 then true
            else raise RangeError
          end
        end
      end
    end
  end
end
