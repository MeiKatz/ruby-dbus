module DBus
  module Types
    class Int32
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
    end
  end
end
