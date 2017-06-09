module DBus
  module Types
    class Int64
      class << self
        def marshall(value)
          [value].pack("q")
        end
      end
    end
  end
end
