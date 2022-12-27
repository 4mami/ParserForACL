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
      if node.val.val.nil?
        puts "Runtime error! : You cannot use the variable that is not initialized."
        puts "Abort."
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
      puts node.val.accept(self)
    when Statements
      node.stmts.each do |stmt|
        stmt.accept(self)
      end
    end
  end
end
