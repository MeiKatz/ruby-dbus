module DBus
  module Types
    class Signature
      class << self
        def marshall(value)
          value.bytesize.chr + value + "\0"
        end
      end
    end
  end
end
