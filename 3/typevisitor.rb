class TypeVisitor
  def initialize
  end

  def visit(node)
    case node
    when Num
      return :int
    when Bool
      return :bool
    when Id
      return node.val.accept(self) # 左のselfはTypeVisitorクラスのインスタンス
    when Not
      return :bool
    when Plus
      return :int
    when Minus
      return :int
    when Mult
      return :int
    when Div
      return :int
    when Andand
      return :bool
    when Oror
      return :bool
    when Lt
      return :bool
    when Gt
      return :bool
    when Le
      return :bool
    when Ge
      return :bool
    when Ne
      return :bool
    when Ee
      return :bool
    else
      return nil
    end
  end
end
