module DBus
  module Types
    class UInt32
      class << self
        def marshall(value)
          [value].pack("L")
        end
      end
    end
  end
end
