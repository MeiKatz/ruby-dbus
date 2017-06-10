module DBus
  module Types
    class Int16 < AbstractType
      class << self
        def code
          @code ||= "n".freeze
        end

        def alignment
          @alignment ||= 2.freeze
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

      def inspect
        "INT16"
      end
    end
  end
end
