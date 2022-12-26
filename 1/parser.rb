class Parser
  def initialize(lexer, output_file=nil)
    @lexime = ''
    @lexer = lexer
    @output_file = output_file
  end

  def parse
    if !(@output_file.nil?)
      f = File.new("./output/#{@output_file}", 'a')
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
    ids
    checktoken(:colon)
    type
    checktoken(:semi)
  end

  def ids
    checktoken(:id)
    while @token == :comma
      checktoken(:comma)
      checktoken(:id)
    end
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
    checktoken(:id)
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
    term
    while @token == :plus || @token == :minus || @token == :oror
      aop
      term
    end
  end

  def aop
    case @token
    when :plus
      checktoken(:plus)
    when :minus
      checktoken(:minus)
    when :oror
      checktoken(:oror)
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :plus, :minus, :oror)
    end
  end

  def term
    factor
    while @token == :mult || @token == :div || @token == :andand
      mop
      factor
    end
  end

  def mop
    case @token
    when :mult
      checktoken(:mult)
    when :div
      checktoken(:div)
    when :andand
      checktoken(:andand)
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :mult, :div, :andand)
    end
  end

  def factor
    case @token
    when :id
      checktoken(:id)
    when :num
      checktoken(:num)
    when :true
      checktoken(:true)
    when :false
      checktoken(:false)
    when :lpar
      checktoken(:lpar)
      expression
      checktoken(:rpar)
    when :not
      checktoken(:not)
      factor
    else
      errormsg(__method__, @lexer.lineno, @lexime, @token, :id, :num, :true, :false, :lpar, :not)
    end
  end

  def checktoken(expected)
    if @token == expected
      @lexer.lex { |t, l|
        @lexime = l
        @token = t
      }
    else
      prev_func = caller[0][/`([^']*)'/, 1]
      line_num = @lexer.lineno
      errormsg(prev_func, line_num, @lexime, @token, expected)
    end
  end

  def errormsg(func_name, line_num, current_lexime, current_token, *tokens)
    tks = tokens.join(' or ')
    msg = "Syntax error! (line: #{line_num})(func: #{func_name})(cr lexime: #{current_lexime})(cr token: #{current_token}) : #{tks} is expected."
    puts msg
    # 出力用ファイルがnilじゃなかったら、ファイルにも出力を書き込む
    if !(@output_file.nil?)
      File.open("./output/#{@output_file}", 'w') do |f|
        f.puts msg
      end
    end
    exit(1)
  end
end
