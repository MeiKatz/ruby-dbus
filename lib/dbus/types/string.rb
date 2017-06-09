module DBus
  module Types
    class String < AbstractType
      class << self
        def code
          @code ||= "s".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          [value.bytesize].pack("L") + [value].pack("Z*")
        end
      end
    end
  end
end
