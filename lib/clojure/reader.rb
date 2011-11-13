module Clojure
  class Reader
    MACROS = {
      '"'[0] => :read_string,
      '['[0] => :read_vector,
      '('[0] => :read_list,
      '{'[0] => :read_map
    }

    def number?(b)
      b.chr =~ /[0-9]/
    end

    def whitespace?(b)
      b.chr =~ /\s/
    end

    def read(io)
      next_char = io.readchar
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
      next_char = io.readchar
      until next_char == '"'[0]
        s << next_char
        next_char = io.readchar
      end
      s
    end

    def read_number(io, first_digit)
      s = first_digit.chr
      next_char = io.readchar
      until not number?(next_char)
        s << next_char
        break if io.eof?
        next_char = io.readchar
      end
      Integer(s)
    end

    def _read_delimited_list(io, delimiter)
      v = []
      next_char = io.readchar
      until next_char == delimiter
        reader_method = MACROS[next_char]
        unless reader_method.nil?
          v << send(reader_method, io)
        else
          io.ungetc(next_char)
          v << read(io)
        end
        break if io.eof?
        next_char = io.readchar
      end
      v
    end

    def read_list(io)
      _read_delimited_list(io, ')'[0])
    end

    def read_vector(io)
      _read_delimited_list(io, ']'[0])
    end

    def read_map(io)
      list = _read_delimited_list(io, '}'[0])
      alist = Enumerable::Enumerator.new(list, :each_cons, 2).map { |k,v| [k,v] }
      Hash[alist]
    end

    def read_token(io, char)
      s = char.chr
      next_char = io.readchar
      until whitespace?(next_char)
        s << next_char
        break if io.eof?
        next_char = io.readchar
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
