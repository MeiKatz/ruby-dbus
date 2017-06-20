module DBus
  module Types
    class Signature < AbstractType
      class << self
        def code
          @code ||= "g".freeze
        end

        def alignment
          @alignment ||= 1.freeze
        end

        def marshall(value)
          value.bytesize.chr + value + "\0"
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "SIGNATURE"
      end
    end
  end
end
