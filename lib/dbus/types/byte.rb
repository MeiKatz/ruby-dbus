module DBus
  module Types
    class Byte
      class << self
        def code
          @code ||= "y".freeze
        end

        def alignment
          @alignment ||= 1.freeze
        end

        def marshall(value)
          value.chr
        end

        def unmarshall(value)
          value.unpack("C")[0]
        end
      end
    end
  end
end
