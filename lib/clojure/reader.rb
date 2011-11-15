require 'set'

module Clojure
  class Reader
    MACROS = {
      '"' => :read_string,
      '\\' => :read_character,
      '[' => :read_vector,
      '(' => :read_list,
      '{' => :read_map,
      '#' => :read_dispatch
    }

    DISPATCH_MACROS = {
      '{' => :read_set
    }

    def read_char(io)
      io.readchar.chr
    end

    def read_to_nonwhitespace_char(io)
      begin
        next_char = read_char(io)
      end while whitespace?(next_char)
      next_char
    end

    def push_char(io, char)
      io.ungetc(char[0])
    end

    def number?(b)
      b =~ /[0-9]/
    end

    def whitespace?(b)
      b =~ /\s/
    end

    def read(io)
      next_char = read_to_nonwhitespace_char(io)

      if number?(next_char)
        read_number(io, next_char)
      else
        reader_method = MACROS[next_char]
        unless reader_method.nil?
          send(reader_method, io)
        else
          read_token(io, next_char)
        end
      end
    end

    def read_string(io)
      s = ""
      next_char = read_char(io)
      until next_char == '"'
        s << next_char
        next_char = read_char(io)
      end
      s
    end

    def read_character(io)
      read_char(io)
    end

    def read_number(io, first_digit)
      s = first_digit
      next_char = read_char(io)
      until not number?(next_char)
        s << next_char
        break if io.eof?
        next_char = read_char(io)
      end
      Integer(s)
    end

    def _read_delimited_list(io, delimiter)
      list = []
      next_char = read_to_nonwhitespace_char(io)
      until next_char == delimiter
        reader_method = MACROS[next_char]
        unless reader_method.nil?
          list << send(reader_method, io)
        else
          push_char(io, next_char)
          list << read(io)
        end
        break if io.eof?
        next_char = read_to_nonwhitespace_char(io)
      end
      list
    end

    def read_list(io)
      _read_delimited_list(io, ')')
    end

    def read_vector(io)
      _read_delimited_list(io, ']')
    end

    def read_map(io)
      list = _read_delimited_list(io, '}')
      alist = Enumerable::Enumerator.new(list, :each_cons, 2).map { |k,v| [k,v] }
      Hash[alist]
    end

    def read_token(io, char)
      s = char
      next_char = read_char(io)
      until whitespace?(next_char)
        s << next_char
        break if io.eof?
        next_char = read_char(io)
      end
      interpret_token(s)
    end

    def interpret_token(s)
      case s
      when "nil" then nil
      when "true" then true
      when "false" then false
      when /:(\w+)/ then $1.to_sym
      else raise "unknown token: #{s}"
      end
    end

    def read_dispatch(io)
      macro = DISPATCH_MACROS[read_char(io)]
      send(macro, io)
    end

    def read_set(io)
      list = _read_delimited_list(io, '}')
      Set.new(list)
    end
  end
end
