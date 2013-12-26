module MuhrTable
  class IsNull < Constraint
    attr_reader :name, :is_null

    def initialize(name, is_null)
      @name=name
      @is_null = is_null
    end
  end
end
