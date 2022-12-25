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
      left.val.val = right.accept(self)
    when Print
    when Statements
    end
  end
end
