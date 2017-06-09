module DBus
  module Types
    class Double
      class << self
        def marshall(value)
          [value].pack("d")
        end
      end
    end
  end
end
