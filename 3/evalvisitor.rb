class EvalVisitor
  def initialize
  end

  def visit(node)
    case node
    when Num
      return node.val
    when Bool
      return node.val
    when Id
      return node.val.accept(self) # 左のselfはEvalVisitorクラスのインスタンス
    when Not
    when Plus
    when Minus
    when Mult
    when Div
    when Andand
    when Oror
    when Lt
    when Gt
    when Le
    when Ge
    when Ne
    when Ee
    when Assign
      node.left.val.val = node.right.accept(self)
    when Print
      puts node.val.accept(self)
    when Statements
      node.stmts.each do |stmt|
        stmt.accept(self)
      end
    end
  end
end
