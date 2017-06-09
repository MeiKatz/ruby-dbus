module DBus
  module Types
    class Byte
      class << self
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
