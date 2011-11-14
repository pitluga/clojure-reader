module Clojure
  class Reader
    MACROS = {
      '"' => :read_string,
      '[' => :read_vector,
      '(' => :read_list,
      '{' => :read_map
    }

    def read_char(io)
      io.readchar.chr
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
      next_char = read_char(io)
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
      v = []
      next_char = read_char(io)
      until next_char == delimiter
        reader_method = MACROS[next_char]
        unless reader_method.nil?
          v << send(reader_method, io)
        else
          push_char(io, next_char)
          v << read(io)
        end
        break if io.eof?
        next_char = read_char(io)
      end
      v
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
      when "true" then true
      when "false" then false
      when /:(\w+)/ then $1.to_sym
      end
    end
  end
end
