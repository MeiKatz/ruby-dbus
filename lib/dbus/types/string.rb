module DBus
  module Types
    class String
      class << self
        def code
          @code ||= "s".freeze
        end

        def marshall(value)
          [value.bytesize].pack("L") + [value].pack("Z*")
        end
      end
    end
  end
end
