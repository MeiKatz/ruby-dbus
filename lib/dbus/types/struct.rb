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

        def basic_type?
          false
        end
      end
    end
  end
end
