module DBus
  module Types
    class AbstractType
      class << self
        def code
          nil
        end

        def alignment
          nil
        end

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

      def append_to(buffer, value:)
        raise NotImplementedError
      end
    end
  end
end
