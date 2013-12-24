module MuhrTable
  class Simple(Constraint)
    OPERANDS=['<','>','<=','>=','=','!=','LIKE']

    def initialize(operator, operand)
      raise WiceException.new("invalid operator: #{operator}") if not OPERANDS.include?(operand)
      
      self.operator=operator
      self.operand=operand
    end
  end
end
