module DBus
  module Types
    class AbstractType
      class << self
        def basic_type?
          true
        end
      end

      def to_s
        self.class.code
      end

      def basic_type?
        self.class.basic_type?
      end
    end
  end
end
