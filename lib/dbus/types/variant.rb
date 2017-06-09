module DBus
  module Types
    class Variant
      class << self
        def code
          @code ||= "v".freeze
        end

        def alignment
          @alignment ||= 1.freeze
        end
      end
    end
  end
end
