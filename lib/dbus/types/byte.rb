module DBus
  module Types
    class Byte
      class << self
        def marshall(value)
          value.chr
        end
      end
    end
  end
end
