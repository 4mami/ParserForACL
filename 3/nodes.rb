class Num
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Bool
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Id
  attr_accessor :val

  def initialize(val)
    @val = val
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Not
  attr_reader :val

  def initialize(val)
    @val = val
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Plus
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Minus
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Mult
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Div
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Andand
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Oror
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Lt
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Gt
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Le
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Ge
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Ne
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Ee
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Assign
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Print
  attr_reader :val

  def initialize(val)
    @val = val
  end

  def accept(visitor)
    visitor.visit(self)
  end
end

class Statements
  attr_reader :stmts

  def initialize(stmts)
    @stmts = stmts
  end

  def accept(visitor)
    visitor.visit(self)
  end
end
