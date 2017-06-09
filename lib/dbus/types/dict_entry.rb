module DBus
  module Types
    class DictEntry
      class << self
        def code
          @code ||= "e".freeze
        end

        def alignment
          @alignment ||= 8.freeze
        end
      end
    end
  end
end
