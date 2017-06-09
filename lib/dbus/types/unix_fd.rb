module DBus
  module Types
    class UnixFD
      class << self
        def marshall(value)
          UInt32.marshall(value)
        end

        def unmarshall(value, endianness:)
          UInt32.unmarshall(value, endianness: endianness)
        end
      end
    end
  end
end