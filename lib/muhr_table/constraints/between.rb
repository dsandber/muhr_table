module MuhrTable
  class Between < Constraint
    def initialize(name, val1, val2)
      self.name = name
      self.val1 = val1
      self.val2 = val2
    end
  end
end
