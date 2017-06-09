module DBus
  module Types
    class Int16
      class << self
        def marshall(value)
          [value].pack("s")
        end
      end
    end
  end
end
