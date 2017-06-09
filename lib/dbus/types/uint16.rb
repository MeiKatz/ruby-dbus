module DBus
  module Types
    class UInt16
      class << self
        def marshall(value)
          [value].pack("S")
        end
      end
    end
  end
end
