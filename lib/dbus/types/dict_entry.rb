module DBus
  module Types
    class DictEntry < AbstractType
      class << self
        def code
          @code ||= "e".freeze
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
