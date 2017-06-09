module DBus
  module Types
    class AbstractType
      def to_s
        self.class.code
      end
    end
  end
end
