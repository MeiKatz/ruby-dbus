module DBus
  class Buffer
    def initialize(value = "", offset: 0)
      @value = value
      @offset = offset
    end

    def replace(range, replacement)
      new_value = value.dup
      new_value[range] = replacement
      self.class.new(new_value)
    end

    def bytesize
      value.bytesize
    end

    def size
      value.size
    end

    def align(padding)
      self.class.new(value.ljust(num_align(offset + value.bytesize, padding) - offset, "\0"))
    end

    def append(value)
      self.class.new(self.value + value)
    end

    private

    attr_reader :offset
    attr_reader :value

    # Round _offset_ up to the specified power of two, _padding_
    def num_align(offset, padding)
      case padding
      when 1, 2, 4, 8
        bits = padding - 1
        (offset + bits) & ~bits
      else
        raise "Unsupported alignment"
      end
    end
  end
end
