module DBus
  module Types
    class Int32
      class << self
        def marshall(value)
          [value].pack("l")
        end
      end
    end
  end
end
