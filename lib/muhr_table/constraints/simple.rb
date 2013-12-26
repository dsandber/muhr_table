module MuhrTable
  class Simple < Constraint
    OPERATORS=['<','>','<=','>=','=','!=','like','ilike','not like', 'not ilike']
    attr_reader :name, :operand, :operator

    def initialize(name, operator, operand)
      raise MuhrException.new("invalid operator: #{operator}") if not OPERATORS.include?(operator)
      
      @name=name
      @operator=operator
      @operand=operand
    end
  end
end
