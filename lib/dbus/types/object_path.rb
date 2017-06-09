module DBus
  module Types
    class ObjectPath
      class << self
        def code
          @code ||= "o".freeze
        end

        def marshall(value)
          String.marshall(value)
        end
      end
    end
  end
end
