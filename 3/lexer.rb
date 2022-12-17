#!/usr/local/bin/ruby

class Lexer
  
  def initialize(f)
    @srcfile=f
    @line = ""
    @lineno = 0
  end

  attr_reader :lineno

  def lex()
    if @line == nil
      false
    else
      if /^\s+/ =~ @line 
        @line = $'
      end
      while @line.empty?  do
        @line = @srcfile.gets()
        if @line == nil 
          return false
        end
        @lineno += 1
        if /^\s+/ =~ @line 
          @line = $'
        end
      end

      case @line
      when /\A\(/
        yield :lpar, $&
        @line = $'
      when /\A\)/
        yield :rpar, $&
        @line = $'
      when /\A\,/
        yield :comma, $&
        @line = $'
      when /\A\;/
        yield :semi, $&
        @line = $'
      when /\A\+/
        yield :plus, $&
        @line = $'
      when /\A\-/
        yield :minus, $&
        @line = $'
      when /\A\*/
        yield :mult, $&
        @line = $'
      when /\A\&\&/
        yield :andand, $&
        @line = $'
      when /\A\|\|/
        yield :oror, $&
        @line = $'
      when /\A\!/
        yield :not, $&
        @line = $'
      when /\A\//
        yield :div, $&
        @line = $'
      when /\A:=/
        yield :coleq, $&
        @line = $'
      when /\A:/
        yield :colon, $&
        @line = $'
      when /\A</
        yield :lt, $&
        @line = $'
      when /\A>/
        yield :gt, $&
        @line = $'
      when /\A<=/
        yield :le, $&
        @line = $'
      when /\A>=/
        yield :ge, $&
        @line = $'
      when /\A==/
        yield :ee, $&
        @line = $'
      when /\A[a-zA-Z_][a-zA-Z_0-9]*/
        @line = $'
        case $&
        when "begin"
          yield :begin, $&
        when "end"
          yield :end, $&
        when "var"
          yield :var, $&
        when "write"
          yield :write, $&
        when "true"
          yield :true, $&
        when "false"
          yield :false, $&
        when "int"
          yield :int, $&
        when "bool"
          yield :bool, $&
        else
          yield :id, $&
        end
#        @line = $' + @line
      when /\A[0-9]+/
        yield :num, $&
        @line = $'
      when /\A./
        yield :other, $&
        @line = $'
      end
      true
    end
  end
end  
  
