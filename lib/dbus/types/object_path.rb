module DBus
  module Types
    class ObjectPath < AbstractType
      class << self
        def code
          @code ||= "o".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def marshall(value)
          String.marshall(value)
        end
      end

      def append_to(buffer, value:)
        buffer
          .align(self.class.alignment)
          .append(self.class.marshall(value))
      end

      def inspect
        "OBJECT_PATH"
      end
    end
  end
end
