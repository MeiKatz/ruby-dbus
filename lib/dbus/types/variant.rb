module DBus
  module Types
    class Variant < AbstractType
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
