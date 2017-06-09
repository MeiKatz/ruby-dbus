module DBus
  module Types
    class Array
      class << self
        def code
          @code ||= "a".freeze
        end
      end
    end
  end
end
