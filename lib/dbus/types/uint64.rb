module DBus
  module Types
    class UInt64
      class << self
        def marshall(value)
          [value].pack("Q")
        end
      end
    end
  end
end
