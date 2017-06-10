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

      def inspect
        "SIGNATURE"
      end
    end
  end
end
