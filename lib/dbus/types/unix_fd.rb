module DBus
  module Types
    class UnixFD
      class << self
        def marshall(value)
          UInt32.marshall(value)
        end
      end
    end
  end
end
