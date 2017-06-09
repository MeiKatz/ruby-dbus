module DBus
  module Types
    class Struct < AbstractType
      class << self
        def code
          @code ||= "r".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end
      end
    end
  end
end
