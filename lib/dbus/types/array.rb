module DBus
  module Types
    class Array < AbstractType
      class << self
        def code
          @code ||= "a".freeze
        end

        def alignment
          @alignment ||= 4.freeze
        end

        def basic_type?
          false
        end
      end

      def initialize(subtype)
        @subtype = subtype
      end

      def append_to(buffer, value:)
        buffer = align_buffer_with_array(buffer)
        size_index = buffer.bytesize

        buffer = align_buffer_with_subtype(buffer)

        content_index = buffer.bytesize

        buffer = append_elements(value, buffer: buffer)

        size = buffer.bytesize - content_index

        raise InvalidPacketException if size > 67_108_864 # 2^26

        buffer.replace(size_index..(size_index + 3), [size].pack("L"))
      end

      def to_s
        "a#{subtype.to_s}"
      end

      def inspect
        "ARRAY of #{subtype.inspect}"
      end

      private

      attr_reader :subtype

      def append_elements(elements, buffer:)
        elements.reduce(buffer) do |buffer, element|
          subtype.append_to(buffer, value: element)
        end
      end

      def align_buffer_with_array(buffer)
        buffer.align(self.class.alignment)
      end

      def align_buffer_with_subtype(buffer)
        buffer.append("%%%%").align(subtype.alignment)
      end
    end
  end
end
