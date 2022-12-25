class Parser
  def initialize(lexer)
    @lexime = ''
    @lexer = lexer
    @id_table = {} # => {"var_a"=>[:int, 1], "var_b"=>[:bool, true]}
  end

  def parse
    @lexer.lex { |t, l|
      @lexime = l
      @token = t
    }
    program
  end

  private

  def program
    declpart
    stmtpart
  end

  def declpart
    case @token
    when :var
      checktoken(:var)
      while @token == :id
        decl
      end
      checktoken(:end)
    else

    end
  end

  def decl
    tmp_ids = ids
    checktoken(:colon)
    # 型情報（シンボル）を取得
    token = @token
    type
    checktoken(:semi)

    tmp_ids.each do |id|
      @id_table[id][0] = token
    end
  end

  def ids
    tmp_ids = []
    tmp_ids.push(@lexime)
    addId
    while @token == :comma
      checktoken(:comma)
      tmp_ids.push(@lexime)
      addId
    end
    tmp_ids
  end

  def type
    case @token
    when :int
      checktoken(:int)
    when :bool
      checktoken(:bool)
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :int, :bool)
    end
  end

  def stmtpart
    checktoken(:begin)
    stmt
    while @token == :id || @token == :write
      stmt
    end
    checktoken(:end)
  end

  def stmt
    case @token
    when :id
      assignst
    when :write
      printst
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :id, :write)
    end
  end

  def assignst
    checkId
    checktoken(:coleq)
    expression
    checktoken(:semi)
  end

  def printst
    checktoken(:write)
    expression
    checktoken(:semi)
  end

  def expression
    sexp
    exptail
  end

  def exptail
    case @token
    when :lt, :gt, :le, :ge, :ne, :ee
      cop
      sexp
    else

    end
  end

  def cop
    case @token
    when :lt
      checktoken(:lt)
    when :gt
      checktoken(:gt)
    when :le
      checktoken(:le)
    when :ge
      checktoken(:ge)
    when :ne
      checktoken(:ne)
    when :ee
      checktoken(:ee)
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :lt, :gt, :le, :ge, :ne, :ee)
    end
  end

  def sexp
    line_num = @lexer.lineno
    type, value = term
    while @token == :plus || @token == :minus || @token == :oror
      case @token
      when :plus
        checktoken(:plus)
        type2, value2 = term
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Addition', 'integer', value, value2)
        end
        value += value2
      when :minus
        checktoken(:minus)
        type2, value2 = term
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Subtraction', 'integer', value, value2)
        end
        value -= value2
      when :oror
        checktoken(:oror)
        type2, value2 = term
        if type != :bool || type2 != :bool
          semanticErrormsg(__method__, line_num, 'Logical operation(||)', 'bool', value, value2)
        end
        value = value || value2
      end
    end
    return type, value
  end

  def term
    line_num = @lexer.lineno
    type, value = factor
    while @token == :mult || @token == :div || @token == :andand
      case @token
      when :mult
        checktoken(:mult)
        type2, value2 = factor
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Multiplication', 'integer', value, value2)
        end
        value *= value2
      when :div
        checktoken(:div)
        type2, value2 = factor
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Division', 'integer', value, value2)
        end
        value /= value2
      when :andand
        checktoken(:andand)
        type2, value2 = factor
        if type != :bool || type2 != :bool
          semanticErrormsg(__method__, line_num, 'Logical operation(&&)', 'bool', value, value2)
        end
        value = value && value2
      end
    end
    return type, value
  end

  def factor
    case @token
    when :id
      lexime = @lexime
      line_num = @lexer.lineno
      checkId
      # 識別子が右辺に登場する場合は、既に代入されていないといけない
      if !@id_table[lexime][1]
        puts "Runtime error! (line: #{line_num})(func: factor) : This variable(#{lexime}) is not initialized."
        puts "Abort."
        exit(1)
      end
      return @id_table[lexime][0], @id_table[lexime][1]
    when :num
      lexime = @lexime
      checktoken(:num)
      return :int, lexime.to_i
    when :true
      checktoken(:true)
      return :bool, true
    when :false
      checktoken(:false)
      return :bool, false
    when :lpar
      checktoken(:lpar)
      type, value = expression
      checktoken(:rpar)
      return type, value
    when :not
      checktoken(:not)
      type, value = factor
      if type == :bool
        return :bool, !value
      else
        # TODO: 整数を反転させた結果を返す
      end
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :id, :num, :true, :false, :lpar, :not)
    end
  end

  def addId
    lexime = @lexime
    line_num = @lexer.lineno
    checktoken(:id, 1)
    if @id_table.has_key?(lexime)
      puts "Semantic error! (line: #{line_num})(func: #{caller[0][/`([^']*)'/, 1]}) : This variable(#{lexime}) is already declared."
      puts "Abort."
      exit(1)
    else
      @id_table[lexime] = Array.new(2)
    end
  end

  def checkId
    lexime = @lexime
    line_num = @lexer.lineno
    checktoken(:id, 1)
    if !(@id_table.has_key?(lexime))
      puts "Semantic error! (line: #{line_num})(func: #{caller[0][/`([^']*)'/, 1]}) : This variable(#{lexime}) is not declared."
      puts "Abort."
      exit(1)
    end
  end

  def checktoken(expected, prev_func_num=0)
    if @token == expected
      @lexer.lex { |t, l|
        @lexime = l
        @token = t
      }
    else
      prev_func = caller[prev_func_num][/`([^']*)'/, 1]
      line_num = @lexer.lineno
      errormsg(prev_func, line_num, @lexime, @token, expected)
    end
  end

  def errormsg(func_name, line_num, current_lexime, current_token, *tokens)
    tks = tokens.join(' or ')
    puts "Syntax error! (line: #{line_num})(func: #{func_name})(cr lexime: #{current_lexime})(cr token: #{current_token}) : #{tks} is expected."
    exit(1)
  end

  def semanticErrormsg(func_name, line_num, opr_name, type_name, value, value2)
    puts "Semantic error! (line: #{line_num})(func: #{func_name}) : #{opr_name} cannot be done because #{value} or #{value2} is not #{type_name}."
    puts "Abort."
    exit(1)
  end
end
