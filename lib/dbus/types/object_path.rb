module DBus
  module Types
    class ObjectPath
      class << self
        def marshall(value)
          String.marshall(value)
        end
      end
    end
  end
end
