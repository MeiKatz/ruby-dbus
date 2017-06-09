module DBus
  module Types
    class Boolean
      class << self
        def marshall(value)
          if value
            [1].pack("L")
          else
            [0].pack("L")
          end
        end
      end
    end
  end
end
