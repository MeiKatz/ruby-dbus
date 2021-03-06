# dbus.rb - Module containing the low-level D-Bus implementation
#
# This file is part of the ruby-dbus project
# Copyright (C) 2007 Arnaud Cornet and Paul van Tilburg
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require "socket"

# = D-Bus main module
#
# Module containing all the D-Bus modules and classes.
module DBus
  # Exception raised when an invalid packet is encountered.
  class InvalidPacketException < Exception
  end

  # = D-Bus packet unmarshaller class
  #
  # Class that handles the conversion (unmarshalling) of payload data
  # to Array.
  class PacketUnmarshaller
    # Index pointer that points to the byte in the data that is
    # currently being processed.
    #
    # Used to kown what part of the buffer has been consumed by unmarshalling.
    # FIXME: Maybe should be accessed with a "consumed_size" method.
    attr_reader :idx

    # Create a new unmarshaller for the given data _buffer_ and _endianness_.
    def initialize(buffer, endianness)
      @buffy = buffer.dup
      @endianness = endianness
      @idx = 0
    end

    # Unmarshall the buffer for a given _signature_ and length _len_.
    # Return an array of unmarshalled objects
    def unmarshall(signature, len = nil)
      if !len.nil? && @buffy.bytesize < @idx + len
        raise IncompleteBufferException
      end

      sigtree = Type::Parser.new(signature).parse
      ret = []

      sigtree.each do |elem|
        ret << do_parse(elem)
      end

      ret
    end

    # Align the pointer index on a byte index of _a_, where a
    # must be 1, 2, 4 or 8.
    def align(a)
      case a
      when 1
      when 2, 4, 8
        bits = a - 1
        @idx = @idx + bits & ~bits
        raise IncompleteBufferException if @idx > @buffy.bytesize
      else
        raise "Unsupported alignment #{a}"
      end
    end

    ###############################################################
    # FIXME: does anyone except the object itself call the above methods?
    # Yes : Message marshalling code needs to align "body" to 8 byte boundary
    private

    # Retrieve the next _nbytes_ number of bytes from the buffer.
    def read(nbytes)
      if @idx + nbytes > @buffy.bytesize
        raise IncompleteBufferException
      end

      ret = @buffy.slice(@idx, nbytes)
      @idx += nbytes
      ret
    end

    # Read the string length and string itself from the buffer.
    # Return the string.
    def read_string
      align(4)
      str_sz = Types::UInt32.unmarshall(read(4), endianness: @endianness)
      ret = @buffy.slice(@idx, str_sz)
      raise IncompleteBufferException if @idx + str_sz + 1 > @buffy.bytesize
      @idx += str_sz
      if @buffy[@idx].ord != 0
        raise InvalidPacketException, "String is not nul-terminated"
      end
      @idx += 1
      # no exception, see check above
      ret
    end

    # Read the signature length and signature itself from the buffer.
    # Return the signature.
    def read_signature
      str_sz = read(1).unpack("C")[0]
      ret = @buffy.slice(@idx, str_sz)

      if @idx + str_sz + 1 >= @buffy.bytesize
        raise IncompleteBufferException
      end

      @idx += str_sz

      unless @buffy[@idx].ord == 0
        raise InvalidPacketException, "Type is not nul-terminated"
      end
      @idx += 1
      # no exception, see check above
      ret
    end

    # Based on the _signature_ type, retrieve a packet from the buffer
    # and return it.
    def do_parse(signature)
      packet = nil
      case signature.sigtype
      when Types::Byte.code
        packet = Types::Byte.unmarshall(read(1))
      when Types::UInt16.code
        align(2)
        packet = Types::UInt16.unmarshall(read(2), endianness: @endianness)
      when Types::Int16.code
        align(4)
        packet = Types::Int16.unmarshall(read(4), endianness: @endianness)
      when Types::UInt32.code
        align(4)
        packet = Types::UInt32.unmarshall(read(4), endianness: @endianness)
      when Types::UnixFD.code
        align(4)
        packet = Types::UnixFD.unmarshall(read(4), endianness: @endianness)
      when Types::Int32.code
        align(4)
        packet = Types::Int32.unmarshall(read(4), endianness: @endianness)
      when Types::UInt64.code
        align(8)
        packet = Types::UInt64.unmarshall(read(8), endianness: @endianness)
      when Types::Int64.code
        align(8)
        packet = Types::Int64.unmarshall(read(8), endianness: @endianness)
      when Types::Double.code
        align(8)
        packet = Types::Double.unmarshall(read(8), endianness: @endianness)
      when Types::Boolean.code
        align(4)
        packet = Types::Boolean.unmarshall(read(4), endianness: @endianness)
      when Types::Array.code
        align(4)
        # checks please
        array_sz = Types::UInt32.unmarshall(read(4), endianness: @endianness)
        raise InvalidPacketException if array_sz > 67_108_864

        align(signature.child.alignment)
        raise IncompleteBufferException if @idx + array_sz > @buffy.bytesize

        packet = []
        start_idx = @idx
        while @idx - start_idx < array_sz
          packet << do_parse(signature.child)
        end

        if signature.child.sigtype == Types::DictEntry.code
          packet = Hash[packet]
        end
      when Types::Struct.code
        align(8)
        packet = []

        signature.members.each do |elem|
          packet << do_parse(elem)
        end
      when Types::Variant.code
        string = read_signature
        # error checking please
        sig = Type::Parser.new(string).parse[0]
        align(sig.alignment)
        packet = do_parse(sig)
      when Types::ObjectPath.code
        packet = read_string
      when Types::String.code
        packet = read_string
        packet.force_encoding("UTF-8")
      when Types::Signature.code
        packet = read_signature
      when Types::DictEntry.code
        align(8)
        key = do_parse(signature.members[0])
        value = do_parse(signature.members[1])
        packet = [key, value]
      else
        raise NotImplementedError,
              "sigtype: #{signature.sigtype} (#{signature.sigtype.chr})"
      end
      packet
    end # def do_parse
  end # class PacketUnmarshaller

  # D-Bus packet marshaller class
  #
  # Class that handles the conversion (marshalling) of Ruby objects to
  # (binary) payload data.
  class PacketMarshaller
    # The current or result packet.
    # FIXME: allow access only when marshalling is finished
    attr_reader :packet

    # Create a new marshaller, setting the current packet to the
    # empty packet.
    def initialize(offset = 0)
      @packet = ""
      @offset = offset # for correct alignment of nested marshallers
    end

    # Round _n_ up to the specified power of two, _a_
    def num_align(n, a)
      case a
      when 1, 2, 4, 8
        bits = a - 1
        n + bits & ~bits
      else
        raise "Unsupported alignment"
      end
    end

    # Align the buffer with NULL (\0) bytes on a byte length of _a_.
    def align(value, padding:, offset:)
      value.ljust(num_align(offset + value.bytesize, padding) - offset, "\0")
    end

    # Append the array type _type_ to the packet and allow for appending
    # the child elements.
    def array(type)
      # Thanks to Peter Rullmann for this line
      @packet = align(@packet, padding: 4, offset: @offset)
      sizeidx = @packet.bytesize
      @packet += "ABCD"
      @packet = align(@packet, padding: type.alignment, offset: @offset)
      contentidx = @packet.bytesize
      yield
      sz = @packet.bytesize - contentidx
      raise InvalidPacketException if sz > 67_108_864
      @packet[sizeidx...sizeidx + 4] = [sz].pack("L")
    end

    # Align and allow for appending struct fields.
    def struct
      @packet = align(@packet, padding: 8, offset: @offset)
      yield
    end

    # Append a value _val_ to the packet based on its _type_.
    #
    # Host native endianness is used, declared in Message#marshall
    def append(type, val)
      raise TypeException, "Cannot send nil" if val.nil?

      type = type.chr if type.is_a?(Integer)
      type = Type::Parser.new(type).parse[0] if type.is_a?(String)
      case type.sigtype
      when Types::Byte.code
        @packet += Types::Byte.marshall(val)
      when Types::UInt32.code
        @packet = align(@packet, padding: 4, offset: @offset)
        @packet += Types::UInt32.marshall(val)
      when Types::UnixFD.code
        @packet = align(@packet, padding: 4, offset: @offset)
        @packet += Types::UnixFD.marshall(val)
      when Types::UInt64.code
        @packet = align(@packet, padding: 8, offset: @offset)
        @packet += Types::UInt64.marshall(val)
      when Types::Int64.code
        @packet = align(@packet, padding: 8, offset: @offset)
        @packet += Types::Int64.marshall(val)
      when Types::Int32.code
        @packet = align(@packet, padding: 4, offset: @offset)
        @packet += Types::Int32.marshall(val)
      when Types::UInt16.code
        @packet = align(@packet, padding: 2, offset: @offset)
        @packet += Types::UInt16.marshall(val)
      when Types::Int16.code
        @packet = align(@packet, padding: 2, offset: @offset)
        @packet += Types::Int16.marshall(val)
      when Types::Double.code
        @packet = align(@packet, padding: 8, offset: @offset)
        @packet += Types::Double.marshall(val)
      when Types::Boolean.code
        @packet = align(@packet, padding: 4, offset: @offset)
        @packet += Types::Boolean.marshall(val)
      when Types::ObjectPath.code
        @packet += Types::ObjectPath.marshall(val)
      when Types::String.code
        @packet += Types::String.marshall(val)
      when Types::Signature.code
        @packet += Types::Signature.marshall(val)
      when Types::Variant.code
        vartype = nil

        if val.is_a?(Array) && val.size == 2
          if val[0].is_a?(DBus::Type::Type)
            vartype, vardata = val
          elsif val[0].is_a?(String)
            begin
              parsed = Type::Parser.new(val[0]).parse
              vartype = parsed[0] if parsed.size == 1
              vardata = val[1]
            rescue Type::SignatureException
              # no assignment
            end
          end
        end

        if vartype.nil?
          vartype, vardata = PacketMarshaller.make_variant(val)
          vartype = Type::Parser.new(vartype).parse[0]
        end

        @packet += Types::Signature.marshall(vartype.to_s)
        @packet = align(@packet, padding: vartype.alignment, offset: @offset)
        sub = PacketMarshaller.new(@offset + @packet.bytesize)
        sub.append(vartype, vardata)
        @packet += sub.packet
      when Types::Array.code
        if val.is_a?(Hash)
          unless type.child.sigtype == Types::DictEntry.code
            raise TypeException, "Expected an Array but got a Hash"
          end
          # Damn ruby rocks here
          val = val.to_a
        end

        # If string is recieved and ay is expected, explode the string
        if val.is_a?(String) && type.child.sigtype == Types::Byte.code
          val = val.bytes
        end

        unless val.is_a?(Enumerable)
          raise TypeException, "Expected an Enumerable of #{type.child.inspect} but got a #{val.class}"
        end

        array(type.child) do
          val.each do |elem|
            append(type.child, elem)
          end
        end
      when Types::Struct.code
        # TODO: use duck typing, val.respond_to?
        unless type.members.size == val.size
          raise TypeException, "Struct has #{val.size} elements but type info for #{type.members.size}"
        end

        struct do
          type.members.zip(val).each do |t, v|
            append(t, v)
          end
        end
      when Types::DictEntry.code
        # TODO: use duck typing, val.respond_to?
        unless val.is_a?(Array)
          raise TypeException, "DE expects an Array"
        end

        unless val.size == 2
          raise TypeException, "Dict entry expects a pair"
        end

        unless type.members.size == val.size
          raise TypeException, "DE has #{val.size} elements but type info for #{type.members.size}"
        end

        struct do
          type.members.zip(val).each do |t, v|
            append(t, v)
          end
        end
      else
        raise NotImplementedError,
              "sigtype: #{type.sigtype} (#{type.sigtype.chr})"
      end
    end # def append

    # Make a [signature, value] pair for a variant
    def self.make_variant(value)
      # TODO: mix in _make_variant to String, Integer...
      case value
      when true then ["b", true]
      when false then ["b", false]
      when nil then ["b", nil]
      when Float then ["d", value]
      when Symbol then ["s", value.to_s]
      when Array then ["av", value.map { |i| make_variant(i) }]
      when Hash
        h = {}
        value.each_key { |k| h[k] = make_variant(value[k]) }
        ["a{sv}", h]
      else
        if value.respond_to?(:to_s)
          ["s", value.to_s]
        elsif value.respond_to?(:to_i)
          if -2_147_483_648 <= i && i < 2_147_483_648
            ["i", i]
          else
            ["x", i]
          end
        end
      end
    end
  end # class PacketMarshaller
end # module DBus
