module DBus
  module Types
    class String
      class << self
        def marshall(value)
          [value.bytesize].pack("L") + [value].pack("Z*")
        end
      end
    end
  end
end
