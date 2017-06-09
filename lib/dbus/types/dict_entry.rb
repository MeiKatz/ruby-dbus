module DBus
  module Types
    class DictEntry
      class << self
        def code
          @code ||= "e".freeze
        end
      end
    end
  end
end
