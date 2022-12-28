class Parser
  def initialize(lexer, output_file=nil)
    @lexime = ''
    @lexer = lexer
    @id_table = {} # => {"var_a"=>[:int, 1], "var_b"=>[:bool, true]}
    @output_file = output_file
  end

  def parse
    # 出力用ファイル名が指定されているなら
    if !(@output_file.nil?)
      if File.exist?("./output/#{@output_file}")
        File.delete("./output/#{@output_file}")
      end
      f = File.new("./output/#{@output_file}", 'w')
      f.close
    end

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
    line_num = @lexer.lineno
    lexime = @lexime

    checkId
    checktoken(:coleq)
    type, value = expression
    if @id_table[lexime][0] != type
      semanticErrormsg(__method__, line_num, 'Assignation', 'same type', lexime, value)
    end
    checktoken(:semi)
    @id_table[lexime][1] = value
  end

  def printst
    checktoken(:write)
    ret = expression
    checktoken(:semi)
    puts ret.last
    writeMsg(@output_file, ret.last, 'a')
  end

  def expression
    line_num = @lexer.lineno
    type, value = sexp
    case @token
    when :lt, :gt, :le, :ge, :ne, :ee
      case @token
      when :lt # <
        checktoken(:lt)
        type2, value2 = sexp
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(<)', 'integer', value, value2)
        end
        type = :bool
        value = value < value2
      when :gt # >
        checktoken(:gt)
        type2, value2 = sexp
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(>)', 'integer', value, value2)
        end
        type = :bool
        value = value > value2
      when :le # <=
        checktoken(:le)
        type2, value2 = sexp
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(<=)', 'integer', value, value2)
        end
        type = :bool
        value = value <= value2
      when :ge # >=
        checktoken(:ge)
        type2, value2 = sexp
        if type != :int || type2 != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(>=)', 'integer', value, value2)
        end
        type = :bool
        value = value >= value2
      when :ne # !=
        checktoken(:ne)
        type2, value2 = sexp
        if type != type2
          semanticErrormsg(__method__, line_num, 'Comparison operation(!=)', 'same type', value, value2)
        end
        type = :bool
        value = value != value2
      when :ee # ==
        checktoken(:ee)
        type2, value2 = sexp
        if type != type2
          semanticErrormsg(__method__, line_num, 'Comparison operation(==)', 'same type', value, value2)
        end
        type = :bool
        value = value == value2
      end
    else
      # イプシロン
    end
    return type, value
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
      if @id_table[lexime][1].nil?
        msg = "Runtime error! (line: #{line_num})(func: factor) : This variable(#{lexime}) is not initialized."
        puts msg
        puts "Abort."
        writeMsg(@output_file, msg)
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
        semanticErrormsg(__method__, line_num, 'Logical operation(!)', 'bool', value, '')
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
      msg = "Semantic error! (line: #{line_num})(func: #{caller[0][/`([^']*)'/, 1]}) : This variable(#{lexime}) is already declared."
      puts msg
      puts "Abort."
      writeMsg(@output_file, msg)
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
      msg = "Semantic error! (line: #{line_num})(func: #{caller[0][/`([^']*)'/, 1]}) : This variable(#{lexime}) is not declared."
      puts msg
      puts "Abort."
      writeMsg(@output_file, msg)
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
    msg = "Syntax error! (line: #{line_num})(func: #{func_name})(cr lexime: #{current_lexime})(cr token: #{current_token}) : #{tks} is expected."
    puts msg
    writeMsg(@output_file, msg)
    exit(1)
  end

  def semanticErrormsg(func_name, line_num, opr_name, type_name, value, value2)
    msg = "Semantic error! (line: #{line_num})(func: #{func_name}) : #{opr_name} cannot be done because #{value} and/or #{value2} is not #{type_name}."
    puts msg
    puts "Abort."
    writeMsg(@output_file, msg)
    exit(1)
  end

  def writeMsg(output_file, msg, mode='w')
    # 出力用ファイルがnilじゃなかったら、ファイルにも出力を書き込む
    if !(output_file.nil?)
      File.open("./output/#{output_file}", mode) do |f|
        f.puts msg
      end
    end
  end
end
