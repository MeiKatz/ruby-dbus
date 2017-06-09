module DBus
  module Types
    class Int16
      class << self
        def code
          @code ||= "n".freeze
        end

        def marshall(value)
          [value].pack("s")
        end

        def unmarshall(value, endianness:)
          packet = UInt16.unmarshall(value, endianness: endianness)

          unless (packet & 0x8000) == 0
            packet -= 0x10000
          end

          packet
        end
      end
    end
  end
end
