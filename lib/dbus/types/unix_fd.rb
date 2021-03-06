module DBus
  module Types
    class UnixFD < AbstractType
      class << self
        def code
          @code ||= "h".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          UInt32.marshall(value)
        end

        def unmarshall(value, endianness:)
          UInt32.unmarshall(value, endianness: endianness)
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "UNIX_FD"
      end
    end
  end
end
