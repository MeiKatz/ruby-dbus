module DBus
  module Types
    class Variant
      class << self
        def code
          @code ||= "v".freeze
        end
      end
    end
  end
end
