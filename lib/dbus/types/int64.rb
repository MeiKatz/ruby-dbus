module DBus
  module Types
    class Int64
      class << self
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
    end
  end
end
