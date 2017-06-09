module DBus
  module Types
    class Array
      class << self
        def code
          @code ||= "a".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end
      end
    end
  end
end
