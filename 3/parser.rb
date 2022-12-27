require './nodes'
require './evalvisitor'
require './typevisitor'

class Parser
  def initialize(lexer, output_file=nil)
    @lexime = ''
    @lexer = lexer
    @id_table = {} # => {"var_a"=>object(Id), "var_b"=>object(Id)}
    @typevisitor = TypeVisitor.new
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
    program.accept(EvalVisitor.new(@output_file))
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
      # イプシロン
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
      if token == :int
        @id_table[id].val = Num.new(nil)
      else
        @id_table[id].val = Bool.new(nil)
      end
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
    tmp_stmts = []
    tmp_stmts.push(stmt)
    while @token == :id || @token == :write
      tmp_stmts.push(stmt)
    end
    checktoken(:end)
    return Statements.new(tmp_stmts)
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
    node = expression
    if @id_table[lexime].accept(@typevisitor) != node.accept(@typevisitor)
      semanticErrormsg(__method__, line_num, 'Assignation', 'same type', lexime, node.accept(@typevisitor))
    end
    checktoken(:semi)
    return Assign.new(@id_table[lexime], node)
  end

  def printst
    checktoken(:write)
    ret = expression
    checktoken(:semi)
    return Print.new(ret)
  end

  def expression
    line_num = @lexer.lineno
    node = sexp
    case @token
    when :lt, :gt, :le, :ge, :ne, :ee
      case @token
      when :lt # <
        checktoken(:lt)
        node2 = sexp
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(<)', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Lt.new(node, node2)
      when :gt # >
        checktoken(:gt)
        node2 = sexp
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(>)', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Gt.new(node, node2)
      when :le # <=
        checktoken(:le)
        node2 = sexp
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(<=)', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Le.new(node, node2)
      when :ge # >=
        checktoken(:ge)
        node2 = sexp
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Comparison operation(>=)', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Ge.new(node, node2)
      when :ne # !=
        checktoken(:ne)
        node2 = sexp
        if node.accept(@typevisitor) != node2.accept(@typevisitor)
          semanticErrormsg(__method__, line_num, 'Comparison operation(!=)', 'same type', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Ne.new(node, node2)
      when :ee # ==
        checktoken(:ee)
        node2 = sexp
        if node.accept(@typevisitor) != node2.accept(@typevisitor)
          semanticErrormsg(__method__, line_num, 'Comparison operation(==)', 'same type', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Ee.new(node, node2)
      end
    else
      # イプシロン
    end
    return node
  end

  def sexp
    line_num = @lexer.lineno
    node = term
    while @token == :plus || @token == :minus || @token == :oror
      case @token
      when :plus
        checktoken(:plus)
        node2 = term
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Addition', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Plus.new(node, node2)
      when :minus
        checktoken(:minus)
        node2 = term
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Subtraction', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Minus.new(node, node2)
      when :oror
        checktoken(:oror)
        node2 = term
        if node.accept(@typevisitor) != :bool || node2.accept(@typevisitor) != :bool
          semanticErrormsg(__method__, line_num, 'Logical operation(||)', 'bool', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Oror.new(node, node2)
      end
    end
    return node
  end

  def term
    line_num = @lexer.lineno
    node = factor
    while @token == :mult || @token == :div || @token == :andand
      case @token
      when :mult
        checktoken(:mult)
        node2 = factor
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Multiplication', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Mult.new(node, node2)
      when :div
        checktoken(:div)
        node2 = factor
        if node.accept(@typevisitor) != :int || node2.accept(@typevisitor) != :int
          semanticErrormsg(__method__, line_num, 'Division', 'integer', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Div.new(node, node2)
      when :andand
        checktoken(:andand)
        node2 = factor
        if node.accept(@typevisitor) != :bool || node2.accept(@typevisitor) != :bool
          semanticErrormsg(__method__, line_num, 'Logical operation(&&)', 'bool', node.accept(@typevisitor), node2.accept(@typevisitor))
        end
        node = Andand.new(node, node2)
      end
    end
    return node
  end

  def factor
    line_num = @lexer.lineno
    case @token
    when :id
      lexime = @lexime
      checkId
      return @id_table[lexime]
    when :num
      lexime = @lexime
      checktoken(:num)
      return Num.new(lexime.to_i)
    when :true
      checktoken(:true)
      return Bool.new(true)
    when :false
      checktoken(:false)
      return Bool.new(false)
    when :lpar
      checktoken(:lpar)
      node = expression
      checktoken(:rpar)
      return node
    when :not
      checktoken(:not)
      node = factor
      if node.accept(@typevisitor) == :bool
        return Not.new(node)
      else
        semanticErrormsg(__method__, line_num, 'Logical operation(!)', 'bool', node.accept(@typevisitor), '')
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
      writeErrormsg(@output_file, msg)
      exit(1)
    else
      @id_table[lexime] = Id.new(nil)
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
      writeErrormsg(@output_file, msg)
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
    writeErrormsg(@output_file, msg)
    exit(1)
  end

  def semanticErrormsg(func_name, line_num, opr_name, type_name, value, value2)
    msg = "Semantic error! (line: #{line_num})(func: #{func_name}) : #{opr_name} cannot be done because #{value} and/or #{value2} is not #{type_name}."
    puts msg
    puts "Abort."
    writeErrormsg(@output_file, msg)
    exit(1)
  end

  def writeErrormsg(output_file, msg)
    # 出力用ファイルがnilじゃなかったら、ファイルにも出力を書き込む
    if !(output_file.nil?)
      File.open("./output/#{output_file}", 'w') do |f|
        f.puts msg
      end
    end
  end
end
