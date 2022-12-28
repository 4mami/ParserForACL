class EvalVisitor
  def initialize(output_file=nil)
    @output_file = output_file
  end

  def visit(node)
    case node
    when Num
      return node.val
    when Bool
      return node.val
    when Id
      if node.val.val.nil?
        msg = "Runtime error! : You cannot use the variable that is not initialized."
        puts msg
        puts "Abort."
        writeMsg(@output_file, msg)
        exit(1)
      end
      return node.val.accept(self) # 左のselfはEvalVisitorクラスのインスタンス
    when Not
      return !(node.val.accept(self))
    when Plus
      return node.left.accept(self) + node.right.accept(self)
    when Minus
      return node.left.accept(self) - node.right.accept(self)
    when Mult
      return node.left.accept(self) * node.right.accept(self)
    when Div
      return node.left.accept(self) / node.right.accept(self)
    when Andand
      return node.left.accept(self) && node.right.accept(self)
    when Oror
      return node.left.accept(self) || node.right.accept(self)
    when Lt
      return node.left.accept(self) < node.right.accept(self)
    when Gt
      return node.left.accept(self) > node.right.accept(self)
    when Le
      return node.left.accept(self) <= node.right.accept(self)
    when Ge
      return node.left.accept(self) >= node.right.accept(self)
    when Ne
      return node.left.accept(self) != node.right.accept(self)
    when Ee
      return node.left.accept(self) == node.right.accept(self)
    when Assign
      node.left.val.val = node.right.accept(self)
    when Print
      ret = node.val.accept(self)
      puts ret
      writeMsg(@output_file, ret, 'a')
    when Statements
      node.stmts.each do |stmt|
        stmt.accept(self)
      end
    end
  end

  private

  def writeMsg(output_file, msg, mode='w')
    # 出力用ファイルがnilじゃなかったら、ファイルにも出力を書き込む
    if !(output_file.nil?)
      File.open("./output/#{output_file}", mode) do |f|
        f.puts msg
      end
    end
  end
end
