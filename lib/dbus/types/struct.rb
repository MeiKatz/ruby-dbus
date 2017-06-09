module DBus
  module Types
    class Struct
      class << self
        def code
          @code ||= "r".freeze
        end
      end
    end
  end
end
